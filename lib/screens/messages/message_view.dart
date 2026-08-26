import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:homehub_app/widgets/app_toast.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/chat_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/property_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/inputs/chat_input_field.dart';
import '../property/property_view.dart';

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

  bool _typingSent = false;
  Timer? _typingTimer;
  int _lastMessageCount = 0;
  bool _lastTyping = false;
  bool _openingProperty = false;
  bool _loadingMessages = true; // true while conversation history is fetching
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = context.read<ChatProvider>();
      chat.setActiveConversation(widget.threadId);
      chat.openConversation(widget.threadId).whenComplete(() {
        if (mounted) setState(() => _loadingMessages = false);
        _scrollToBottom();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = context.read<ChatProvider>();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    // Stop typing + clear the active conversation on the way out using cached provider.
    if (_typingSent) _chatProvider.sendTyping(widget.threadId, false);
    _chatProvider.setActiveConversation(null);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Defer to after this frame: the list may not be attached yet (e.g. on the
    // first build while messages are still loading, hasClients is false and
    // maxScrollExtent is only valid once layout has run).
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
    if (text.isEmpty) return;

    final chat = context.read<ChatProvider>();

    // Typing implicitly stops when a message is sent.
    _typingTimer?.cancel();
    if (_typingSent) {
      _typingSent = false;
      chat.sendTyping(widget.threadId, false);
    }

    // Fire-and-forget: the bubble appears instantly with a pending clock and
    // uploads in the background — the field stays usable so you can keep
    // sending. No awaiting, no disabling.
    chat.enqueueMessage(widget.threadId, text);
    _msgController.clear();
    _scrollToBottom();
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

  // --- header actions -----------------------------------------------------

  Future<void> _viewProperty(ChatThread thread) async {
    final propertyId = thread.propertyId;
    if (propertyId == null || propertyId.isEmpty || _openingProperty) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _openingProperty = true);
    final property = await context
        .read<PropertyProvider>()
        .fetchPropertyDetailFromApi(propertyId);

    if (!mounted) return;
    setState(() => _openingProperty = false);
    if (property == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Could not open the property."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    navigator.push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(property: property),
      ),
    );
  }

  Future<void> _archive(ChatThread thread) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await context.read<ChatProvider>().archiveConversation(
      thread.id,
    );
    if (!mounted) return;
    if (ok) {
      navigator.pop(); // thread is gone from the list
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Conversation archived"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Could not archive the conversation."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(ChatThread thread) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete conversation?"),
        content: const Text(
          "This permanently removes the conversation and its messages.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await context.read<ChatProvider>().deleteConversation(thread.id);
    if (!mounted) return;
    if (ok) {
      navigator.pop();
      AppToast.showSuccess(context, message: "Conversation deleted");
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Could not delete the conversation."),
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
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: thread.online
                              ? Colors.green
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        thread.online ? "Active now" : "Offline",
                        style: TextStyle(
                          fontSize: 11,
                          color: thread.online
                              ? Colors.green
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.ellipsis_vertical),
            onSelected: (value) {
              switch (value) {
                case 'archive':
                  _archive(thread);
                  break;
                case 'delete':
                  _confirmDelete(thread);
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(LucideIcons.archive, size: 18),
                      SizedBox(width: 10),
                      Text("Archive conversation"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(LucideIcons.trash_2, size: 18, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "Delete conversation",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (thread.propertyId != null && thread.propertyId!.isNotEmpty)
            _buildPropertyBanner(isDark, thread),

          // Messages Feed
          Expanded(
            child: _loadingMessages && messages.isEmpty
                // History is still fetching and there's nothing to show yet.
                ? Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: isDark ? AppColors.darkAccent : AppColors.primary,
                    ),
                  )
                : (messages.isEmpty && !isTyping)
                ? Center(
                    child: Text(
                      "No messages yet. Say hello 👋",
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
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
                        context,
                        isDark,
                        thread,
                        messages,
                        index,
                      );
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

    final groupedWithPrev =
        prev != null &&
        prev.senderId == msg.senderId &&
        !showDateSeparator &&
        msg.timestamp.difference(prev.timestamp).abs() <= _kGroupWindow;

    final groupedWithNext =
        next != null &&
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
            ? AppColors.primary
            : (isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt),
        borderRadius: radius,
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            msg.content,
            style: TextStyle(
              color: isMe
                  ? Colors.white
                  : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
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
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  fontSize: 10,
                ),
              ),
              if (isMe) ...[const SizedBox(width: 4), _statusIcon(msg)],
            ],
          ),
        ],
      ),
    );

    // Failed messages are tappable to retry / surface the reason.
    final Widget bubbleWrapped = msg.failed
        ? GestureDetector(onTap: () => _onFailedTap(msg), child: bubble)
        : bubble;

    // Received messages carry the sender avatar, but only on the bottom-most
    // bubble of a group; a spacer keeps earlier bubbles aligned.
    final Widget row = Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          groupedWithNext
              ? const SizedBox(width: 28)
              : _Avatar(url: thread.agentAvatar, radius: 14),
          const SizedBox(width: 8),
        ],
        Flexible(child: bubbleWrapped),
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

  /// WhatsApp-style delivery status: clock (pending) → single check (sent) →
  /// circle-check (read); a red alert when a send failed.
  Widget _statusIcon(ChatMessage msg) {
    if (msg.pending) {
      return const Icon(LucideIcons.clock, size: 11, color: Colors.white70);
    }
    if (msg.failed) {
      return const Icon(
        LucideIcons.circle_alert,
        size: 12,
        color: Color(0xFFFFC1B6),
      );
    }
    return Icon(
      msg.read ? LucideIcons.circle_check : LucideIcons.check,
      size: 12,
      color: Colors.white70,
    );
  }

  void _onFailedTap(ChatMessage msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.failReason ?? "Message not delivered."),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "Retry",
          onPressed: () => context.read<ChatProvider>().retryMessage(
            widget.threadId,
            msg.id,
          ),
        ),
      ),
    );
  }

  Widget _dateSeparator(bool isDark, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Text(
            _dateLabel(date),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  /// Fixed banner under the header linking to the property this chat is about.
  Widget _buildPropertyBanner(bool isDark, ChatThread thread) {
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      child: InkWell(
        onTap: () => _viewProperty(thread),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.building_2,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enquiry about",
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      thread.propertyTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _openingProperty
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "View",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            LucideIcons.arrow_right,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
            ],
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
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      child: ChatInputField(
        controller: _msgController,
        onSend: _send,
        isDark: isDark,
        onChanged: _onTextChanged,
        onSubmitted: (_) => _send(),
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
      child: url.isEmpty ? Icon(LucideIcons.user, size: radius) : null,
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
                  : AppColors.surfaceAlt,
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
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
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
