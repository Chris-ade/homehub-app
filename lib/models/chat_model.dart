import '../config/app_config.dart';

/// Parses the backend's `"2006-01-02 15:04:05"` timestamps (space-separated,
/// no timezone) as well as ISO-8601 strings. Falls back to now on failure.
DateTime _parseTimestamp(dynamic raw) {
  if (raw == null) return DateTime.now();
  final s = raw.toString();
  if (s.isEmpty) return DateTime.now();
  return DateTime.tryParse(s.replaceFirst(' ', 'T'))?.toLocal() ??
      DateTime.now();
}

/// Prefixes server-relative asset paths with the API host.
String _resolveAsset(String? url) {
  if (url == null || url.isEmpty) return "";
  if (url.startsWith('/')) return "${AppConfig.apiHost}$url";
  return url;
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final DateTime timestamp;
  final bool read;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    required this.timestamp,
    required this.read,
    required this.isMe,
  });

  /// Tolerant of both the REST DTO (snake_case: `sender_id`, `conversation_id`)
  /// and the WebSocket `message:new` payload (camelCase: `senderId`,
  /// `conversationId`).
  factory ChatMessage.fromJson(
    Map json, {
    required String currentUserId,
  }) {
    final senderId =
        (json['sender_id'] ?? json['senderId'] ?? '').toString();
    final conversationId =
        (json['conversation_id'] ?? json['conversationId'] ?? '').toString();

    String senderName = "";
    String senderAvatar = "";
    final sender = json['sender'];
    if (sender is Map) {
      final first = (sender['first_name'] ?? sender['firstName'] ?? '')
          .toString();
      final last =
          (sender['last_name'] ?? sender['lastName'] ?? '').toString();
      senderName = "$first $last".trim();
      senderAvatar = _resolveAsset(sender['avatar']?.toString());
    }

    return ChatMessage(
      id: (json['id'] ?? '').toString(),
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: (json['content'] ?? '').toString(),
      timestamp: _parseTimestamp(json['created_at'] ?? json['createdAt']),
      read: json['read'] == true,
      isMe: senderId.isNotEmpty && senderId == currentUserId,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    DateTime? timestamp,
    bool? read,
    bool? isMe,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      isMe: isMe ?? this.isMe,
    );
  }
}

class ChatThread {
  final String id; // conversationId
  final String participantId; // the OTHER user's id
  final String? propertyId;
  final String propertyTitle;
  final String agentName;
  final String agentAvatar;
  String lastMessage;
  DateTime lastMessageTime;
  int unreadCount;
  bool online;
  final List<ChatMessage> messages;

  ChatThread({
    required this.id,
    required this.participantId,
    this.propertyId,
    required this.propertyTitle,
    required this.agentName,
    required this.agentAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.online = false,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];

  String get conversationId => id;

  /// Builds a thread from a `ConversationPreviewDTO`. Picks the participant that
  /// isn't the current user as the "agent"/counterparty shown in the UI.
  factory ChatThread.fromPreviewJson(
    Map json, {
    required String currentUserId,
  }) {
    // Resolve the counterparty participant.
    String participantId = "";
    String agentName = "";
    String agentAvatar = "";
    bool online = false;

    final participants = json['participants'];
    if (participants is List) {
      for (final p in participants) {
        if (p is! Map) continue;
        final user = p['user'];
        if (user is! Map) continue;
        final uid = (user['id'] ?? '').toString();
        if (uid.isEmpty || uid == currentUserId) continue;
        final first =
            (user['first_name'] ?? user['firstName'] ?? '').toString();
        final last = (user['last_name'] ?? user['lastName'] ?? '').toString();
        participantId = uid;
        agentName = "$first $last".trim();
        agentAvatar = _resolveAsset(user['avatar']?.toString());
        online = p['online'] == true;
        break;
      }
    }

    if (agentName.isEmpty) agentName = "HomeHub User";

    final last = json['last_message'] ?? json['lastMessage'];
    String lastMessage = "Conversation started";
    DateTime lastTime = _parseTimestamp(json['created_at'] ?? json['createdAt']);
    if (last is Map) {
      lastMessage = (last['content'] ?? lastMessage).toString();
      lastTime = _parseTimestamp(last['created_at'] ?? last['createdAt']);
    }

    return ChatThread(
      id: (json['id'] ?? '').toString(),
      participantId: participantId,
      propertyId: (json['property_id'] ?? json['propertyId'])?.toString(),
      propertyTitle:
          (json['property_title'] ?? json['propertyTitle'] ?? 'Property Inquiry')
              .toString(),
      agentName: agentName,
      agentAvatar: agentAvatar,
      lastMessage: lastMessage,
      lastMessageTime: lastTime,
      unreadCount: (json['unread_count'] ?? json['unreadCount'] ?? 0) is int
          ? (json['unread_count'] ?? json['unreadCount'] ?? 0) as int
          : int.tryParse(
                  (json['unread_count'] ?? json['unreadCount'] ?? '0')
                      .toString()) ??
              0,
      online: online,
      messages: [],
    );
  }
}
