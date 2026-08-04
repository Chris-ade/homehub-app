import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

class ChatDetailScreen extends StatefulWidget {
  final String threadId;

  const ChatDetailScreen({super.key, required this.threadId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _sending = false;
  bool _typingSent = false;
  Timer? _typingTimer;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = context.read<ChatProvider>();
      chat.setActiveConversation(widget.threadId);
      chat.openConversation(widget.threadId).then((_) => _scrollToBottom());
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    // Stop typing + clear the active conversation on the way out.
    final chat = context.read<ChatProvider>();
    if (_typingSent) chat.sendTyping(widget.threadId, false);
    chat.setActiveConversation(null);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _onTextChanged(String value) {
    final chat = context.read<ChatProvider>();
    if (value.trim().isNotEmpty) {
      if (!_typingSent) {
        _typingSent = true;
        chat.sendTyping(widget.threadId, true);
      }
      // Reset the idle timer: stop typing after ~2s of no keystrokes.
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (_typingSent) {
          _typingSent = false;
          chat.sendTyping(widget.threadId, false);
        }
      });
    } else if (_typingSent) {
      _typingTimer?.cancel();
      _typingSent = false;
      chat.sendTyping(widget.threadId, false);
    }
  }

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _sending) return;

    final chat = context.read<ChatProvider>();

    // Typing implicitly stops when a message is sent.
    _typingTimer?.cancel();
    if (_typingSent) {
      _typingSent = false;
      chat.sendTyping(widget.threadId, false);
    }

    setState(() => _sending = true);
    _msgController.clear();
    _scrollToBottom();

    final result = await chat.sendMessage(widget.threadId, text);

    if (!mounted) return;
    setState(() => _sending = false);

    if (result.ok) {
      _scrollToBottom();
    } else {
      // Restore the text so the user can retry, and surface the reason.
      _msgController.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? "Message could not be sent."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final thread = chatProvider.getThreadById(widget.threadId);

    if (thread == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Chat not found")),
      );
    }

    // Auto-scroll when new messages arrive (inbound or reconciled).
    if (thread.messages.length != _lastMessageCount) {
      _lastMessageCount = thread.messages.length;
      _scrollToBottom();
    }

    final isTyping = chatProvider.isTyping(widget.threadId);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: thread.agentAvatar.isNotEmpty
                  ? NetworkImage(thread.agentAvatar)
                  : null,
              child: thread.agentAvatar.isEmpty
                  ? const Icon(LucideIcons.user, size: 16)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.agentName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkInk : AppColors.ink,
                    ),
                  ),
                  Text(
                    isTyping ? "typing…" : thread.propertyTitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                      color: isTyping
                          ? AppColors.forest
                          : (isDark ? AppColors.darkMuted : AppColors.muted),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: thread.messages.isEmpty
                ? Center(
                    child: Text(
                      "No messages yet. Say hello 👋",
                      style: TextStyle(
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: thread.messages.length,
                    itemBuilder: (context, index) {
                      final msg = thread.messages[index];
                      return Align(
                        alignment: msg.isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isMe
                                ? (isDark
                                    ? AppColors.terracotta
                                    : AppColors.forest)
                                : (isDark
                                    ? AppColors.darkSurfaceAlt
                                    : AppColors.creamAlt),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: msg.isMe
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              bottomRight: msg.isMe
                                  ? Radius.zero
                                  : const Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: msg.isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.content,
                                style: TextStyle(
                                  color: msg.isMe
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.darkInk
                                          : AppColors.ink),
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('hh:mm a').format(msg.timestamp),
                                    style: TextStyle(
                                      color: msg.isMe
                                          ? Colors.white70
                                          : (isDark
                                              ? AppColors.darkMuted
                                              : AppColors.muted),
                                      fontSize: 10,
                                    ),
                                  ),
                                  if (msg.isMe) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      msg.read
                                          ? LucideIcons.check_check
                                          : LucideIcons.check,
                                      size: 12,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Message Input Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              border: Border(
                  top: BorderSide(
                      color: isDark ? AppColors.darkLine : AppColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    onChanged: _onTextChanged,
                    onSubmitted: (_) => _send(),
                    textInputAction: TextInputAction.send,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    shape: const CircleBorder(),
                  ),
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(LucideIcons.send,
                          color: Colors.white, size: 18),
                  onPressed: _sending ? null : _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
