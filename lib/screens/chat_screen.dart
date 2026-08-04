import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final threads = chatProvider.threads;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Messages & Inquiries",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkInk : AppColors.ink,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => chatProvider.fetchConversations(),
        child: _buildBody(context, isDark, chatProvider, threads),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool isDark,
    ChatProvider chatProvider,
    List threads,
  ) {
    if (chatProvider.isLoading && threads.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (threads.isEmpty) {
      // Wrap in a scroll view so pull-to-refresh works on the empty state too.
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.message_square,
                      size: 60,
                      color: isDark ? AppColors.darkMuted : AppColors.muted),
                  const SizedBox(height: 16),
                  Text(
                    "No Conversations Yet",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkInk : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Inquire about a property to chat with landlords directly.",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: threads.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 72,
        color: isDark ? AppColors.darkLine : AppColors.line,
      ),
      itemBuilder: (context, index) {
        final thread = threads[index];
        final hasUnread = thread.unreadCount > 0;
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: thread.agentAvatar.isNotEmpty
                    ? NetworkImage(thread.agentAvatar)
                    : null,
                child: thread.agentAvatar.isEmpty
                    ? const Icon(LucideIcons.user, size: 22)
                    : null,
              ),
              if (thread.online)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                DateFormat('hh:mm a').format(thread.lastMessageTime),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                "Re: ${thread.propertyTitle}",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.terracotta,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      thread.lastMessage,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            hasUnread ? FontWeight.bold : FontWeight.normal,
                        color: hasUnread
                            ? (isDark ? AppColors.darkInk : AppColors.ink)
                            : (isDark ? AppColors.darkMuted : AppColors.muted),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      constraints: const BoxConstraints(minWidth: 20),
                      decoration: const BoxDecoration(
                        color: AppColors.terracotta,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Text(
                        thread.unreadCount > 99
                            ? "99+"
                            : "${thread.unreadCount}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(threadId: thread.id),
              ),
            );
          },
        );
      },
    );
  }
}
