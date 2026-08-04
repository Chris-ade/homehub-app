import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/chat_model.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

/// Messages from the same sender within this window are visually grouped
/// (tighter spacing, shared bubble corners, avatar only on the last one).
const Duration _kGroupWindow = Duration(minutes: 10);

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
  bool _lastTyping = false;

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

  // --- grouping helpers ---------------------------------------------------

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    return DateFormat('MMMM d, yyyy').format(d);
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
    // Keep the typing bubble in view when it first appears.
    if (isTyping != _lastTyping) {
      _lastTyping = isTyping;
      if (isTyping) _scrollToBottom();
    }
    final messages = thread.messages;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            _Avatar(url: thread.agentAvatar, radius: 16),
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
                    thread.propertyTitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
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
          // Messages Feed
          Expanded(
            child: (messages.isEmpty && !isTyping)
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    // One extra slot for the typing bubble at the bottom.
                    itemCount: messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= messages.length) {
                        return _TypingBubble(
                          avatarUrl: thread.agentAvatar,
                          isDark: isDark,
                        );
                      }
                      return _buildMessageRow(
                          context, isDark, thread, messages, index);
                    },
                  ),
          ),

          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageRow(
    BuildContext context,
    bool isDark,
    ChatThread thread,
    List<ChatMessage> messages,
    int index,
  ) {
    final msg = messages[index];
    final isMe = msg.isMe;
    final prev = index > 0 ? messages[index - 1] : null;
    final next = index < messages.length - 1 ? messages[index + 1] : null;

    final showDateSeparator =
        prev == null || !_isSameDay(msg.timestamp, prev.timestamp);

    final groupedWithPrev = prev != null &&
        prev.senderId == msg.senderId &&
        !showDateSeparator &&
        msg.timestamp.difference(prev.timestamp).abs() <= _kGroupWindow;

    final groupedWithNext = next != null &&
        next.senderId == msg.senderId &&
        _isSameDay(msg.timestamp, next.timestamp) &&
        next.timestamp.difference(msg.timestamp).abs() <= _kGroupWindow;

    // Dynamic bubble corners: the flush (edge) side collapses between
    // consecutive bubbles so a group reads as one stack.
    const big = Radius.circular(16);
    const small = Radius.circular(5);
    final BorderRadius radius = isMe
        ? BorderRadius.only(
            topLeft: big,
            bottomLeft: big,
            topRight: groupedWithPrev ? small : big,
            bottomRight: groupedWithNext ? small : big,
          )
        : BorderRadius.only(
            topRight: big,
            bottomRight: big,
            topLeft: groupedWithPrev ? small : big,
            bottomLeft: groupedWithNext ? small : big,
          );

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isMe
            ? (isDark ? AppColors.terracotta : AppColors.forest)
            : (isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt),
        borderRadius: radius,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            msg.content,
            style: TextStyle(
              color: isMe
                  ? Colors.white
                  : (isDark ? AppColors.darkInk : AppColors.ink),
              fontSize: 14,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('h:mm a').format(msg.timestamp),
                style: TextStyle(
                  color: isMe
                      ? Colors.white70
                      : (isDark ? AppColors.darkMuted : AppColors.muted),
                  fontSize: 10,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  msg.read ? LucideIcons.check_check : LucideIcons.check,
                  size: 12,
                  color: Colors.white70,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    // Received messages carry the sender avatar, but only on the bottom-most
    // bubble of a group; a spacer keeps earlier bubbles aligned.
    final Widget row = Row(
      mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          groupedWithNext
              ? const SizedBox(width: 28)
              : _Avatar(url: thread.agentAvatar, radius: 14),
          const SizedBox(width: 8),
        ],
        Flexible(child: bubble),
      ],
    );

    return Column(
      children: [
        if (showDateSeparator) _dateSeparator(isDark, msg.timestamp),
        Padding(
          padding: EdgeInsets.only(top: groupedWithPrev ? 2 : 10),
          child: row,
        ),
      ],
    );
  }

  Widget _dateSeparator(bool isDark, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkLine : AppColors.line,
            ),
          ),
          child: Text(
            _dateLabel(date),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
            top: BorderSide(color: isDark ? AppColors.darkLine : AppColors.line)),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(LucideIcons.send, color: Colors.white, size: 18),
            onPressed: _sending ? null : _send,
          ),
        ],
      ),
    );
  }
}

/// Circular avatar that falls back to a user glyph when no image is available.
class _Avatar extends StatelessWidget {
  final String url;
  final double radius;

  const _Avatar({required this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
          ? Icon(LucideIcons.user, size: radius)
          : null,
    );
  }
}

/// The "… is typing" bubble with three bouncing dots, shown in-feed.
class _TypingBubble extends StatefulWidget {
  final String avatarUrl;
  final bool isDark;

  const _TypingBubble({required this.avatarUrl, required this.isDark});

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Avatar(url: widget.avatarUrl, radius: 14),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.darkSurfaceAlt
                  : AppColors.creamAlt,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    // Stagger each dot's bounce phase.
                    final t = (_controller.value - i * 0.2) % 1.0;
                    final scale = 0.6 + 0.4 * (1 - (2 * t - 1).abs());
                    return Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? AppColors.darkMuted
                                : AppColors.muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
