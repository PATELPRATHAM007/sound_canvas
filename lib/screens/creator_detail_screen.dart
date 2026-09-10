import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../ads/banner_ad_widget.dart';
import '../ads/interstitial_ad_manager.dart';
import 'content_detail_screen.dart';

class CreatorDetailScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final String role;
  final String followers;

  const CreatorDetailScreen({
    super.key,
    required this.name,
    required this.avatar,
    required this.role,
    required this.followers,
  });

  @override
  State<CreatorDetailScreen> createState() => _CreatorDetailScreenState();
}

class _CreatorDetailScreenState extends State<CreatorDetailScreen> {
  bool _isFollowing = false;
  int _clickCounter = 0;

  final List<Map<String, String>> _creatorTracks = [
    {
      'title': 'Neon Horizon Odyssey',
      'duration': '3:42',
      'plays': '48.2k',
      'category': 'Music',
      'icon': '🎵',
    },
    {
      'title': 'Cyberpunk Soundscapes Live',
      'duration': '14:20',
      'plays': '92.1k',
      'category': 'Audio',
      'icon': '🎧',
    },
    {
      'title': 'Future Synth Masterclass',
      'duration': '25:10',
      'plays': '18.4k',
      'category': 'Tutorial',
      'icon': '💻',
    },
  ];

  void _handleActionWithInterstitial(VoidCallback action, String actionName) {
    _clickCounter++;
    debugPrint('[CreatorDetailScreen] Action clicked ($actionName). Count: $_clickCounter/2');
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Creator Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
                      onPressed: () {
                        _handleActionWithInterstitial(() {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Creator options for ${widget.name}'),
                              backgroundColor: const Color(0xFF5B46F6),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        }, 'Creator Options');
                      },
                    ),
                  ],
                ),
              ),

              // Creator Profile Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GlassContainer(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar Badge
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5B46F6).withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.avatar,
                            style: const TextStyle(fontSize: 42),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Name & Verified Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: Color(0xFF5B46F6), size: 22),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.role} • ${widget.followers} Followers',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Follow Button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing ? Colors.white : const Color(0xFF5B46F6),
                            elevation: _isFollowing ? 0 : 2,
                            side: BorderSide(
                              color: const Color(0xFF5B46F6),
                              width: _isFollowing ? 1.5 : 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            _handleActionWithInterstitial(() {
                              setState(() {
                                _isFollowing = !_isFollowing;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isFollowing ? 'You are now following ${widget.name}' : 'Unfollowed ${widget.name}',
                                  ),
                                  backgroundColor: const Color(0xFF5B46F6),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                            }, 'Follow Toggle ${_isFollowing ? 'Unfollow' : 'Follow'}');
                          },
                          child: Text(
                            _isFollowing ? 'Following ✓' : '+ Follow Creator',
                            style: TextStyle(
                              color: _isFollowing ? const Color(0xFF5B46F6) : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Banner Ad Widget
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: BannerAdWidget(),
              ),

              const SizedBox(height: 16),

              // Top Tracks & Releases Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Releases',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _creatorTracks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final track = _creatorTracks[index];
                        return GestureDetector(
                          onTap: () {
                            _handleActionWithInterstitial(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ContentDetailScreen(
                                    title: track['title']!,
                                    creator: widget.name,
                                    category: track['category']!,
                                  ),
                                ),
                              );
                            }, 'Open Track ${track['title']}');
                          },
                          child: GlassContainer(
                            borderRadius: 20,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(track['icon']!, style: const TextStyle(fontSize: 20)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track['title']!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${track['duration']} • ${track['plays']} plays',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF5B46F6), size: 36),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
