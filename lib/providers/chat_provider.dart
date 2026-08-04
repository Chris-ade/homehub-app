import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/chat_model.dart';
import '../services/api_client.dart';
import '../services/chat_socket.dart';
import 'user_provider.dart';

/// Live chat backed by the Go backend: REST for conversation/message
/// persistence (`/api/messages/*`) and a WebSocket for realtime pushes
/// (new messages, typing indicators, read receipts).
///
/// Auth is driven by [UserProvider] via [bindUser], called from the
/// `ChangeNotifierProxyProvider` in main.dart on every auth change: it connects
/// the socket + loads conversations on login and tears everything down on logout.
class ChatProvider extends ChangeNotifier {
  final ApiClient _api;

  ChatProvider(this._api);

  final List<ChatThread> _threads = [];

  String _currentUserId = "";
  bool _loadingThreads = false;
  String? _error;

  ChatSocket? _socket;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _disposed = false;

  // Which conversation is currently on screen — inbound messages for it are
  // auto-marked read instead of bumping an unread badge.
  String? _activeConversationId;

  // conversationId -> whether the counterparty is currently typing.
  final Map<String, bool> _typingByConversation = {};

  // Getters
  List<ChatThread> get threads => _threads;
  bool get isLoading => _loadingThreads;
  String? get error => _error;
  int get totalUnread =>
      _threads.fold(0, (sum, t) => sum + t.unreadCount);

  bool isTyping(String conversationId) =>
      _typingByConversation[conversationId] == true;

  ChatThread? getThreadById(String id) {
    for (final t in _threads) {
      if (t.id == id) return t;
    }
    return null;
  }

  // --- Auth lifecycle (called by the proxy provider) ---------------------

  void bindUser(UserProvider user) {
    final token = user.accessToken;
    final loggedIn =
        user.isLoggedIn && token != null && token.isNotEmpty && user.id.isNotEmpty;

    if (loggedIn) {
      // New login or a different account than we're currently bound to.
      if (_currentUserId != user.id) {
        _currentUserId = user.id;
        _threads.clear();
        _typingByConversation.clear();
        fetchConversations();
        _connectSocket();
      } else if (_socket == null || !_socket!.isConnected) {
        // Same user but socket dropped (e.g. after a token refresh) — reconnect.
        _connectSocket();
      }
    } else {
      // Logged out.
      if (_currentUserId.isNotEmpty || _threads.isNotEmpty) {
        clearChats();
      }
    }
  }

  void setActiveConversation(String? conversationId) {
    _activeConversationId = conversationId;
  }

  // --- REST ---------------------------------------------------------------

  Future<void> fetchConversations() async {
    _loadingThreads = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/messages/conversations', auth: true);
      if (res.ok) {
        final list = _extractList(res.data);
        if (list != null) {
          final fetched = <ChatThread>[];
          for (final item in list) {
            if (item is Map) {
              try {
                fetched.add(ChatThread.fromPreviewJson(item,
                    currentUserId: _currentUserId));
              } catch (_) {}
            }
          }
          // Preserve any already-loaded message lists across a refresh.
          for (final t in fetched) {
            final existing = getThreadById(t.id);
            if (existing != null && existing.messages.isNotEmpty) {
              t.messages.addAll(existing.messages);
            }
          }
          _threads
            ..clear()
            ..addAll(fetched);
        }
      } else {
        _error = "Could not load conversations.";
      }
    } catch (_) {
      _error = "Could not reach the chat server.";
    } finally {
      _loadingThreads = false;
      notifyListeners();
    }
  }

  /// Loads (and marks read) the messages of a conversation.
  Future<void> openConversation(String conversationId) async {
    try {
      final res = await _api.get('/messages/conversations/$conversationId',
          auth: true);
      if (!res.ok) return;

      final list = _extractList(res.data);
      if (list == null) return;

      final msgs = <ChatMessage>[];
      for (final item in list) {
        if (item is Map) {
          try {
            msgs.add(ChatMessage.fromJson(item, currentUserId: _currentUserId));
          } catch (_) {}
        }
      }

      final thread = getThreadById(conversationId);
      if (thread != null) {
        thread.messages
          ..clear()
          ..addAll(msgs);
        thread.unreadCount = 0; // server marks read as a side effect
        if (msgs.isNotEmpty) {
          thread.lastMessage = msgs.last.content;
          thread.lastMessageTime = msgs.last.timestamp;
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Gets-or-creates a conversation with [participantId] and returns its id.
  Future<String?> startConversation({
    required String participantId,
    String? propertyId,
    required String propertyTitle,
    required String agentName,
    required String agentAvatar,
  }) async {
    if (participantId.isEmpty) return null;

    try {
      final res = await _api.post(
        '/messages/conversations',
        body: {
          'participantId': participantId,
          if (propertyId != null) 'propertyId': propertyId,
        },
        auth: true,
      );

      if (!res.isSuccess) return null;

      final data = res.data;
      String? conversationId;
      if (data is Map && data['data'] is Map) {
        conversationId = (data['data']['conversationId'] ??
                data['data']['conversation_id'])
            ?.toString();
      }
      if (conversationId == null || conversationId.isEmpty) return null;

      // Ensure a local thread exists so the detail screen has something to show.
      if (getThreadById(conversationId) == null) {
        _threads.insert(
          0,
          ChatThread(
            id: conversationId,
            participantId: participantId,
            propertyId: propertyId,
            propertyTitle: propertyTitle,
            agentName: agentName,
            agentAvatar: agentAvatar,
            lastMessage: "Conversation started",
            lastMessageTime: DateTime.now(),
          ),
        );
        notifyListeners();
      }

      // Load existing history (if the conversation already existed).
      await openConversation(conversationId);
      return conversationId;
    } catch (_) {
      return null;
    }
  }

  /// Sends [content] optimistically. Returns an error string on failure (e.g.
  /// the backend's content-filter 400) so the UI can surface it.
  Future<({bool ok, String? error})> sendMessage(
    String conversationId,
    String content,
  ) async {
    final thread = getThreadById(conversationId);
    if (thread == null) return (ok: false, error: "Conversation not found.");

    final tempId = "temp-${DateTime.now().microsecondsSinceEpoch}";
    final optimistic = ChatMessage(
      id: tempId,
      conversationId: conversationId,
      senderId: _currentUserId,
      senderName: "You",
      senderAvatar: "",
      content: content,
      timestamp: DateTime.now(),
      read: false,
      isMe: true,
    );
    thread.messages.add(optimistic);
    thread.lastMessage = content;
    thread.lastMessageTime = optimistic.timestamp;
    notifyListeners();

    try {
      final res = await _api.post(
        '/messages/conversations/$conversationId',
        body: {'content': content},
        auth: true,
      );

      if (res.isSuccess) {
        final data = res.data;
        if (data is Map && data['data'] is Map) {
          final confirmed = ChatMessage.fromJson(
            data['data'] as Map,
            currentUserId: _currentUserId,
          );
          final i = thread.messages.indexWhere((m) => m.id == tempId);
          if (i != -1) {
            thread.messages[i] = confirmed;
          }
          thread.lastMessage = confirmed.content;
          thread.lastMessageTime = confirmed.timestamp;
          notifyListeners();
        }
        return (ok: true, error: null);
      }

      // Failure — drop the optimistic bubble and surface the server message.
      _removeMessage(thread, tempId);
      notifyListeners();
      return (
        ok: false,
        error: res.message ?? "Message could not be sent.",
      );
    } catch (_) {
      _removeMessage(thread, tempId);
      notifyListeners();
      return (ok: false, error: "Could not reach the chat server.");
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _api.post('/messages/conversations/$conversationId/read',
          auth: true);
    } catch (_) {}
  }

  void sendTyping(String conversationId, bool isTyping) {
    _socket?.send({
      'type': isTyping ? 'typing:start' : 'typing:stop',
      'data': {'conversationId': conversationId},
    });
  }

  // --- WebSocket ----------------------------------------------------------

  void _connectSocket() {
    _reconnectTimer?.cancel();
    final token = _api.authProvider?.accessToken;
    if (token == null || token.isEmpty) return;

    // Tear down any previous socket before opening a fresh one.
    _socket?.close();
    final socket = ChatSocket();
    _socket = socket;
    socket.events.listen(_onSocketEvent);
    socket.connect(token, onDone: _scheduleReconnect);
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    // Only reconnect while still authenticated.
    final token = _api.authProvider?.accessToken;
    if (_currentUserId.isEmpty || token == null || token.isEmpty) return;

    _reconnectAttempts++;
    final delaySeconds =
        (1 << (_reconnectAttempts - 1)).clamp(1, 30); // 1,2,4,…,30
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_disposed) return;
      _connectSocket();
    });
  }

  void _onSocketEvent(Map<String, dynamic> event) {
    final type = event['type']?.toString();
    final data = event['data'];
    if (type == null) return;

    switch (type) {
      case 'connection:established':
        _reconnectAttempts = 0;
        break;

      case 'message:new':
        if (data is Map && data['message'] is Map) {
          _handleIncomingMessage(data['message'] as Map);
        }
        break;

      case 'message:read':
        if (data is Map) {
          final convId =
              (data['conversationId'] ?? data['conversation_id'])?.toString();
          if (convId != null) _handleReadReceipt(convId);
        }
        break;

      case 'typing:start':
      case 'typing:stop':
        if (data is Map) {
          final convId =
              (data['conversationId'] ?? data['conversation_id'])?.toString();
          if (convId != null && getThreadById(convId) != null) {
            _typingByConversation[convId] = type == 'typing:start';
            notifyListeners();
          }
        }
        break;
    }
  }

  void _handleIncomingMessage(Map raw) {
    final msg = ChatMessage.fromJson(raw, currentUserId: _currentUserId);
    if (msg.conversationId.isEmpty) return;

    final thread = getThreadById(msg.conversationId);
    if (thread == null) {
      // A conversation we don't know about yet — refresh the list to pick it up.
      fetchConversations();
      return;
    }

    // Ignore echoes of our own already-present messages.
    final exists = thread.messages.any((m) => m.id == msg.id);
    if (!exists) {
      thread.messages.add(msg);
    }
    thread.lastMessage = msg.content;
    thread.lastMessageTime = msg.timestamp;

    // Typing implicitly stops when a message arrives.
    _typingByConversation[msg.conversationId] = false;

    if (!msg.isMe) {
      if (_activeConversationId == msg.conversationId) {
        // Thread is open — mark read on the server rather than badging.
        markAsRead(msg.conversationId);
      } else {
        thread.unreadCount += 1;
      }
    }

    notifyListeners();
  }

  void _handleReadReceipt(String conversationId) {
    final thread = getThreadById(conversationId);
    if (thread == null) return;
    var changed = false;
    for (var i = 0; i < thread.messages.length; i++) {
      final m = thread.messages[i];
      if (m.isMe && !m.read) {
        thread.messages[i] = m.copyWith(read: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  // --- Teardown -----------------------------------------------------------

  void clearChats() {
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    _socket?.close();
    _socket = null;
    _currentUserId = "";
    _activeConversationId = null;
    _threads.clear();
    _typingByConversation.clear();
    _error = null;
    notifyListeners();
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _socket?.close();
    _socket = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _disconnect();
    super.dispose();
  }

  // --- helpers ------------------------------------------------------------

  List? _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return null;
  }

  void _removeMessage(ChatThread thread, String messageId) {
    thread.messages.removeWhere((m) => m.id == messageId);
    if (thread.messages.isNotEmpty) {
      thread.lastMessage = thread.messages.last.content;
      thread.lastMessageTime = thread.messages.last.timestamp;
    }
  }
}
