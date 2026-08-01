class ChatMessage {
  final String id;
  final String senderName;
  final String senderAvatar;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    required this.timestamp,
    required this.isMe,
  });
}

class ChatThread {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String agentName;
  final String agentAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<ChatMessage> messages;

  ChatThread({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.agentName,
    required this.agentAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    required this.messages,
  });
}
