import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

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
      body: threads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.message_square, size: 60, color: isDark ? AppColors.darkMuted : AppColors.muted),
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
            )
          : ListView.separated(
              itemCount: threads.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 72,
                color: isDark ? AppColors.darkLine : AppColors.line,
              ),
              itemBuilder: (context, index) {
                final thread = threads[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(thread.agentAvatar),
                      ),
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
                      Text(
                        thread.lastMessage,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            ),
    );
  }
}
