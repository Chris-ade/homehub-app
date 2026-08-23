import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/chat_model.dart';
import '../../providers/chat_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/inputs/search_input_field.dart';
import 'message_view.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory =
      "All"; // "All", "Inquiries", "Bookings", "Landlords", "Support"
  bool _isSubFilterActive = false;
  bool _filterUnreadOnly = false;
  bool _filterStarredOnly = false;
  final Set<String> _selectedTripStages = {};

  final List<String> _tripStageOptions = const [
    "Inquiry Sent",
    "Inspection Scheduled",
    "Active Lease",
    "Past Lease",
    "Cancelled",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = "All";
      _isSubFilterActive = false;
      _filterUnreadOnly = false;
      _filterStarredOnly = false;
      _selectedTripStages.clear();
      _searchController.clear();
    });
  }

  List<ChatThread> _getFilteredThreads(List<ChatThread> allThreads) {
    var list = allThreads;

    // Filter by search query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((t) {
        return t.agentName.toLowerCase().contains(query) ||
            t.propertyTitle.toLowerCase().contains(query) ||
            t.lastMessage.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by unread
    if (_filterUnreadOnly) {
      list = list.where((t) => t.unreadCount > 0).toList();
    }

    // Filter by category
    if (_selectedCategory == "Inquiries") {
      list = list
          .where(
            (t) =>
                t.lastMessage.toLowerCase().contains("inquir") ||
                t.lastMessage.toLowerCase().contains("hello") ||
                t.lastMessage.toLowerCase().contains("hi"),
          )
          .toList();
    } else if (_selectedCategory == "Bookings") {
      list = list.where((t) => t.propertyTitle.isNotEmpty).toList();
    } else if (_selectedCategory == "Landlords") {
      list = list
          .where(
            (t) =>
                t.agentName.isNotEmpty &&
                !t.agentName.toLowerCase().contains("support"),
          )
          .toList();
    } else if (_selectedCategory == "Support") {
      list = list
          .where((t) => t.agentName.toLowerCase().contains("support"))
          .toList();
    }

    return list;
  }

  void _showMessagingSettingsModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with title and close button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Messaging settings",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    LucideIcons.message_square_text,
                    size: 20,
                  ),
                  title: const Text("Manage quick replies"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Quick replies settings opened"),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.sparkles, size: 20),
                  title: const Text("Suggested replies"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Suggested replies settings opened"),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.archive, size: 20),
                  title: const Text("Archived"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Archived messages opened")),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    LucideIcons.message_square_plus,
                    size: 20,
                  ),
                  title: const Text("Give feedback"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Feedback option selected")),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTripStageModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Lease stage",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 8),

                    // Checkbox Options
                    ..._tripStageOptions.map((stage) {
                      final isSelected = _selectedTripStages.contains(stage);
                      return CheckboxListTile(
                        value: isSelected,
                        activeColor: isDark
                            ? AppColors.surfaceAlt
                            : AppColors.textPrimary,
                        checkColor: isDark ? AppColors.textPrimary : Colors.white,
                        title: Text(
                          stage,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (val) {
                          setModalState(() {
                            if (val == true) {
                              _selectedTripStages.add(stage);
                            } else {
                              _selectedTripStages.remove(stage);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Bottom Actions Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedTripStages.clear();
                            });
                            setState(() {});
                          },
                          child: Text(
                            "Clear all",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            foregroundColor: isDark
                                ? AppColors.textPrimary
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Apply",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final allThreads = chatProvider.threads;
    final threads = _getFilteredThreads(allThreads);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar (Normal Mode vs Search Mode)
            if (_isSearchActive)
              _buildSearchHeader(isDark)
            else
              _buildNormalHeader(isDark),

            // Category & Filter Pills Bar
            _buildFilterPills(isDark),

            const SizedBox(height: 8),

            // Body Feed (List vs Empty State)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => chatProvider.fetchConversations(),
                child: _buildBody(
                  context,
                  isDark,
                  chatProvider,
                  threads,
                  allThreads.isNotEmpty,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Messages",
            style: TextStyle(
              fontSize: AppFontSizes.displaySmall,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  LucideIcons.search,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  size: 22,
                ),
                onPressed: () => setState(() => _isSearchActive = true),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.settings,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  size: 22,
                ),
                onPressed: () => _showMessagingSettingsModal(context, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SearchInputField(
              controller: _searchController,
              isDark: isDark,
              hintText: "Search all messages",
              onChanged: (_) => setState(() {}),
              onClear: () => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _isSearchActive = false;
                _searchController.clear();
              });
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills(bool isDark) {
    if (_isSubFilterActive) {
      return SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            // Back button to exit sub-filter mode
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSubFilterActive = false;
                  _selectedCategory = "All";
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
                ),
                child: Icon(
                  LucideIcons.arrow_left,
                  size: 16,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ),

            // Active category pill
            _buildPill(
              label: _selectedCategory,
              isSelected: true,
              isDark: isDark,
              onTap: () {},
            ),

            // Unread filter pill
            _buildPill(
              label: "Unread",
              isSelected: _filterUnreadOnly,
              isDark: isDark,
              onTap: () {
                setState(() {
                  _filterUnreadOnly = !_filterUnreadOnly;
                });
              },
            ),

            // Trip stage dropdown pill
            GestureDetector(
              onTap: () => _showTripStageModal(context, isDark),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _selectedTripStages.isNotEmpty
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                      : (isDark
                            ? AppColors.darkSurfaceAlt
                            : AppColors.surfaceAlt),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedTripStages.isEmpty
                          ? "Lease stage"
                          : "Lease stage (${_selectedTripStages.length})",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _selectedTripStages.isNotEmpty
                            ? (isDark ? AppColors.textPrimary : Colors.white)
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      LucideIcons.chevron_down,
                      size: 16,
                      color: _selectedTripStages.isNotEmpty
                          ? (isDark ? AppColors.textPrimary : Colors.white)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),

            // Starred filter pill
            _buildPill(
              label: "Starred",
              isSelected: _filterStarredOnly,
              isDark: isDark,
              onTap: () {
                setState(() {
                  _filterStarredOnly = !_filterStarredOnly;
                });
              },
            ),
          ],
        ),
      );
    }

    // Default primary category pills
    final categories = ["All", "Inquiries", "Bookings", "Landlords", "Support"];
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return _buildPill(
            label: cat,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () {
              setState(() {
                _selectedCategory = cat;
                if (cat != "All") {
                  _isSubFilterActive = true;
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.white : AppColors.primary)
              : (isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.labelMedium,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? (isDark ? AppColors.surface : Colors.white)
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool isDark,
    ChatProvider chatProvider,
    List<ChatThread> threads,
    bool hasAnyOverallThreads,
  ) {
    if (chatProvider.isLoading && threads.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (threads.isEmpty) {
      final isFiltered =
          _isSubFilterActive ||
          _filterUnreadOnly ||
          _selectedTripStages.isNotEmpty ||
          _searchController.text.isNotEmpty;

      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceAlt
                            : AppColors.surfaceAlt,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.mail,
                        size: 40,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isFiltered
                          ? "We couldn't find any messages"
                          : "You don't have any messages",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isFiltered
                          ? "Try removing or adjusting your filters."
                          : "When you receive a new message, it will appear here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    if (isFiltered) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          foregroundColor: isDark
                              ? AppColors.textPrimary
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _resetFilters,
                        child: Text(
                          hasAnyOverallThreads
                              ? "Clear all filters"
                              : "Show all messages",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
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
        color: isDark ? AppColors.darkBorder : AppColors.border,
      ),
      itemBuilder: (context, index) {
        final thread = threads[index];
        final hasUnread = thread.unreadCount > 0;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
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
                  fontSize: AppFontSizes.bodyLarge,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              Text(
                DateFormat('hh:mm a').format(thread.lastMessageTime),
                style: TextStyle(
                  fontSize: AppFontSizes.labelMedium,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
                style: TextStyle(
                  fontSize: AppFontSizes.labelMedium,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkAccent : AppColors.accent,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      thread.lastMessage,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodyMedium,
                        fontWeight: hasUnread
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: hasUnread
                            ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(minWidth: 20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkAccent : AppColors.accent,
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
