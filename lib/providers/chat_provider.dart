import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../data/mock_data.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatThread> _threads = List.from(MockData.initialChats);

  List<ChatThread> get threads => _threads;

  ChatThread? getThreadById(String id) {
    try {
      return _threads.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  ChatThread? getThreadByPropertyId(String propertyId) {
    try {
      return _threads.firstWhere((t) => t.propertyId == propertyId);
    } catch (_) {
      return null;
    }
  }

  ChatThread startOrGetThread({
    required String propertyId,
    required String propertyTitle,
    required String agentName,
    required String agentAvatar,
  }) {
    final existing = getThreadByPropertyId(propertyId);
    if (existing != null) return existing;

    final newThread = ChatThread(
      id: "ch-${DateTime.now().millisecondsSinceEpoch}",
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      agentName: agentName,
      agentAvatar: agentAvatar,
      lastMessage: "Conversation started",
      lastMessageTime: DateTime.now(),
      messages: [],
    );

    _threads.insert(0, newThread);
    notifyListeners();
    return newThread;
  }

  void sendMessage(String threadId, String messageText) {
    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      final message = ChatMessage(
        id: "msg-${DateTime.now().millisecondsSinceEpoch}",
        senderName: "Chris",
        senderAvatar: "",
        message: messageText,
        timestamp: DateTime.now(),
        isMe: true,
      );

      _threads[index].messages.add(message);
      _threads[index] = ChatThread(
        id: _threads[index].id,
        propertyId: _threads[index].propertyId,
        propertyTitle: _threads[index].propertyTitle,
        agentName: _threads[index].agentName,
        agentAvatar: _threads[index].agentAvatar,
        lastMessage: messageText,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        messages: _threads[index].messages,
      );

      notifyListeners();

      // Simulate automated response after 1.5 seconds
      Future.delayed(const Duration(milliseconds: 1500), () {
        _simulateAgentResponse(threadId, messageText);
      });
    }
  }

  void _simulateAgentResponse(String threadId, String userMessage) {
    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      String responseText = "Thank you for reaching out! I'm available to answer any questions about the property.";
      final lower = userMessage.toLowerCase();
      if (lower.contains("price") || lower.contains("rent") || lower.contains("cost")) {
        responseText = "The price is non-negotiable for the current listing, but it covers service charge prep for 1 year.";
      } else if (lower.contains("water") || lower.contains("power") || lower.contains("light")) {
        responseText = "Power in this area is steady (18+ hours daily) plus solar inverter installation!";
      } else if (lower.contains("inspect") || lower.contains("view") || lower.contains("time")) {
        responseText = "I am free for inspections tomorrow between 10 AM and 4 PM. Feel free to book a slot directly in the app!";
      }

      final botMsg = ChatMessage(
        id: "msg-bot-${DateTime.now().millisecondsSinceEpoch}",
        senderName: _threads[index].agentName,
        senderAvatar: _threads[index].agentAvatar,
        message: responseText,
        timestamp: DateTime.now(),
        isMe: false,
      );

      _threads[index].messages.add(botMsg);
      _threads[index] = ChatThread(
        id: _threads[index].id,
        propertyId: _threads[index].propertyId,
        propertyTitle: _threads[index].propertyTitle,
        agentName: _threads[index].agentName,
        agentAvatar: _threads[index].agentAvatar,
        lastMessage: responseText,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        messages: _threads[index].messages,
      );
      notifyListeners();
    }
  }
}
