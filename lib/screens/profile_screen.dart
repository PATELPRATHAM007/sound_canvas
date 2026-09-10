import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../ads/banner_ad_widget.dart';
import '../ads/interstitial_ad_manager.dart';
import '../ads/ad_manager.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBackButton;
  const ProfileScreen({super.key, this.showBackButton = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;
  int _clickCounter = 0;

  final List<String> _tabs = ['Posts', 'Liked', 'Saved', 'Playlists'];

  final List<Map<String, String>> _userPosts = [
    {
      'title': 'Cyberpunk Beats Vol. 4',
      'category': 'Music',
      'duration': '3:12',
      'likes': '4.2k',
      'views': '18.9k',
      'icon': '🎵',
    },
    {
      'title': 'Neon Horizon Artwork',
      'category': 'Art',
      'duration': 'Photo',
      'likes': '8.1k',
      'views': '32.0k',
      'icon': '🎨',
    },
    {
      'title': 'Studio Gear 2026 Setup',
      'category': 'Tech',
      'duration': '12:45',
      'likes': '2.9k',
      'views': '14.5k',
      'icon': '💻',
    },
    {
      'title': 'Lo-Fi Chill Sessions Live',
      'category': 'Music',
      'duration': '45:00',
      'likes': '15.6k',
      'views': '89.2k',
      'icon': '🎧',
    },
  ];

  void _handleActionWithInterstitial(VoidCallback action, String actionName) {
    _clickCounter++;
    debugPrint('[ProfileScreen] Action clicked ($actionName). Count: $_clickCounter/2');
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

  void _openSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassContainer(
          borderRadius: 32,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Settings & Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.bug_report_rounded, color: Color(0xFF5B46F6)),
                title: const Text('Launch LevelPlay Test Suite'),
                subtitle: const Text('Inspect mediation ad units & network status'),
                onTap: () {
                  Navigator.pop(context);
                  AdManager.instance.launchTestSuite();
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active_rounded, color: Color(0xFF5B46F6)),
                title: const Text('Push Notification Preferences'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.security_rounded, color: Color(0xFF5B46F6)),
                title: const Text('Privacy & Security Settings'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.showBackButton)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      )
                    else
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary, size: 26),
                      onPressed: () {
                        _handleActionWithInterstitial(_openSettingsModal, 'Settings Modal');
                      },
                    ),
                  ],
                ),
              ),

              // Profile Card Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassContainer(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar & Name
                      Row(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5B46F6).withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🎧', style: TextStyle(fontSize: 38)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Text(
                                      'Alex Vance',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(Icons.verified_rounded, color: Color(0xFF5B46F6), size: 20),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '@alex_vance',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5B46F6).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'PRO CREATOR',
                                    style: TextStyle(
                                      color: Color(0xFF5B46F6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // User Bio
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Digital Sound Architect & Music Producer 🎧 | Synthesizing future electronic vibes ⚡ | Tokyo / NYC',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Followers', '12.4k'),
                          Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.3)),
                          _buildStatItem('Following', '380'),
                          Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.3)),
                          _buildStatItem('Total Likes', '142.5k'),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Action Buttons (Edit Profile, Share)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B46F6),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                _handleActionWithInterstitial(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Edit profile clicked'),
                                      backgroundColor: const Color(0xFF5B46F6),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  );
                                }, 'Edit Profile');
                              },
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GlassContainer(
                            borderRadius: 16,
                            padding: const EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () {
                                _handleActionWithInterstitial(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Profile link copied to clipboard'),
                                      backgroundColor: const Color(0xFF5B46F6),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  );
                                }, 'Share Profile');
                              },
                              child: const Icon(Icons.share_rounded, color: AppColors.textPrimary, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Banner Ad Widget
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: BannerAdWidget(),
              ),

              const SizedBox(height: 16),

              // Profile Content Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_tabs.length, (index) {
                    final isSelected = _selectedTab == index;
                    return GestureDetector(
                      onTap: () {
                        _handleActionWithInterstitial(() {
                          setState(() {
                            _selectedTab = index;
                          });
                        }, 'Profile Tab ${_tabs[index]}');
                      },
                      child: Column(
                        children: [
                          Text(
                            _tabs[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF5B46F6) : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 3,
                            width: 24,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF5B46F6) : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // Posts List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _userPosts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = _userPosts[index];
                    return GlassContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(post['icon']!, style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['title']!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${post['category']} • ${post['duration']} • ${post['views']} views',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                post['likes']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
