import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../ads/banner_ad_widget.dart';
import '../ads/interstitial_ad_manager.dart';

class NotificationsScreen extends StatefulWidget {
  final bool showBackButton;
  const NotificationsScreen({super.key, this.showBackButton = true});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';
  int _clickCounter = 0;

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Alex Vance liked your track "Synth Wave"',
      'subtitle': '2 minutes ago',
      'type': 'Likes',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFFF4B4B),
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Elena Rostova started following you',
      'subtitle': '15 minutes ago',
      'type': 'Mentions',
      'icon': Icons.person_add_rounded,
      'color': Color(0xFF5B46F6),
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'LevelPlay SDK Update Available',
      'subtitle': '1 hour ago',
      'type': 'System',
      'icon': Icons.system_security_update_good_rounded,
      'color': Color(0xFF00C853),
      'isRead': true,
    },
    {
      'id': '4',
      'title': 'Marcus Vance commented: "Awesome vibes!"',
      'subtitle': '3 hours ago',
      'type': 'Mentions',
      'icon': Icons.chat_bubble_rounded,
      'color': Color(0xFF8E37F5),
      'isRead': true,
    },
    {
      'id': '5',
      'title': 'Weekly Discover Digest is ready for you',
      'subtitle': 'Yesterday',
      'type': 'System',
      'icon': Icons.auto_awesome_rounded,
      'color': Color(0xFFFF9100),
      'isRead': true,
    },
  ];

  void _handleActionWithInterstitial(VoidCallback action, String actionName) {
    _clickCounter++;
    debugPrint('[NotificationsScreen] Action clicked ($actionName). Count: $_clickCounter/2');
    if (_clickCounter >= 2) {
      _clickCounter = 0;
      InterstitialAdManager.instance.showInterstitialWithFallback(
        onProceed: action,
        context: context,
      );
    } else {
      action();
    }
  }

  void _markAllRead() {
    setState(() {
      for (var item in _notifications) {
        item['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read'),
        backgroundColor: const Color(0xFF5B46F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredList {
    if (_selectedFilter == 'All') return _notifications;
    return _notifications.where((n) => n['type'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
              child: Row(
                children: [
                  if (widget.showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  const Expanded(
                    child: Text(
                      'Activity & Alerts',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _handleActionWithInterstitial(_markAllRead, 'Mark All Read');
                    },
                    icon: const Icon(Icons.done_all_rounded, size: 18, color: Color(0xFF5B46F6)),
                    label: const Text(
                      'Read All',
                      style: TextStyle(color: Color(0xFF5B46F6), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['All', 'Likes', 'Mentions', 'System'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(filter),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      selectedColor: const Color(0xFF5B46F6),
                      backgroundColor: Colors.white.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF5B46F6) : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      onSelected: (_) {
                        _handleActionWithInterstitial(() {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }, 'Filter Notifications $filter');
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // Banner Ad
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: BannerAdWidget(),
            ),

            const SizedBox(height: 12),

            // Notification List
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _filteredList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _filteredList[index];
                  final isRead = item['isRead'] as bool;

                  return GestureDetector(
                    onTap: () {
                      _handleActionWithInterstitial(() {
                        setState(() {
                          item['isRead'] = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opened: ${item['title']}'),
                            backgroundColor: const Color(0xFF5B46F6),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }, 'Click Notification ${item['id']}');
                    },
                    child: GlassContainer(
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      backgroundColor: isRead
                          ? Colors.white.withValues(alpha: 0.45)
                          : Colors.white.withValues(alpha: 0.85),
                      borderColor: isRead
                          ? Colors.white.withValues(alpha: 0.6)
                          : const Color(0xFF5B46F6).withValues(alpha: 0.8),
                      borderWidth: isRead ? 1.2 : 2.0,
                      child: Row(
                        children: [
                          // Type Icon Badge
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: item['color'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Title and Subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['subtitle'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Unread Indicator Dot
                          if (!isRead)
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF5B46F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
