import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/discover_header.dart';
import '../widgets/search_section.dart';
import '../widgets/category_tabs.dart';
import '../widgets/hero_card.dart';
import '../widgets/creator_section.dart';
import '../widgets/trending_section.dart';
import '../ads/ad_manager.dart';
import '../ads/banner_ad_widget.dart';
import '../ads/interstitial_ad_manager.dart';
import 'notifications_screen.dart';
import 'messages_screen.dart';
import 'search_screen.dart';
import 'content_detail_screen.dart';
import 'creator_detail_screen.dart';
import '../services/service_locator.dart';
import '../services/audio_player_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'For You';
  int _clickCounter = 0; // Tracks user action clicks for 2-click interstitial trigger

  final List<String> _categories = [
    'For You',
    'Music',
    'Art',
    'Fashion',
    'Tech',
  ];

  @override
  void initState() {
    super.initState();
    if (!AdManager.instance.isInitialized) {
      AdManager.instance.initialize();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5B46F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Triggers Interstitial Ad after user clicks any button / clickable item 2 times.
  /// Click 1 -> Executes action directly.
  /// Click 2 -> Triggers Interstitial Ad then executes action. (Resets counter to 0)
  void _handleActionWithInterstitial(VoidCallback action, String actionName) {
    _clickCounter++;
    debugPrint('[DiscoverScreen] User action clicked ($actionName). Click count: $_clickCounter/2');

    if (_clickCounter >= 2) {
      _clickCounter = 0; // Reset counter
      debugPrint('[DiscoverScreen] 2nd click reached -> Triggering Interstitial Ad');
      InterstitialAdManager.instance.showInterstitialWithFallback(
        onProceed: () {
          action();
        },
        context: context,
      );
    } else {
      // 1st click: execute action immediately without ad
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // 1. Header (Menu, Notifications, Messages)
              DiscoverHeader(
                onMenuPressed: () {
                  AdManager.instance.launchTestSuite();
                  _showSnackBar('Launching LevelPlay Test Suite...');
                },
                onNotificationPressed: () {
                  _handleActionWithInterstitial(
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen(showBackButton: true)),
                      );
                    },
                    'Notifications Button',
                  );
                },
                onMessagePressed: () {
                  _handleActionWithInterstitial(
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MessagesScreen(showBackButton: true)),
                      );
                    },
                    'Messages Button',
                  );
                },
              ),
              const SizedBox(height: 22),

              // 2. Page Title & Subtitle with SoundCanvas Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B46F6).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.music_note_rounded,
                            color: Color(0xFF5B46F6),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SoundCanvas',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.6,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Where Sound Meets Vision',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 3. Search Section (Navigates to SearchScreen)
              SearchSection(
                controller: _searchController,
                onFilterPressed: () {
                  _handleActionWithInterstitial(
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen(showBackButton: true)),
                      );
                    },
                    'Search Section Button',
                  );
                },
              ),
              const SizedBox(height: 14),

              // 4. Banner Ad Widget (Placed directly below SearchSection)
              const BannerAdWidget(),
              const SizedBox(height: 14),

              // 5. Category Tabs
              CategoryTabs(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  _handleActionWithInterstitial(
                    () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    'Category $category',
                  );
                },
              ),
              const SizedBox(height: 22),

              // 6. Featured Hero Card (Navigates to ContentDetailScreen)
              HeroCard(
                onPlayPressed: () {
                  _handleActionWithInterstitial(
                    () {
                      ServiceLocator.audioPlayer.playTrack(
                        const TrackModel(
                          id: 'New Wave Synth',
                          title: 'New Wave Synth',
                          artist: 'Synth Wave Collective',
                          category: 'Music',
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContentDetailScreen(
                            title: 'New Wave Synth',
                            creator: 'Synth Wave Collective',
                            category: 'Music',
                          ),
                        ),
                      );
                    },
                    'Play Hero Music',
                  );
                },
                onTap: () {
                  _handleActionWithInterstitial(
                    () {
                      ServiceLocator.audioPlayer.playTrack(
                        const TrackModel(
                          id: 'New Wave Synth',
                          title: 'New Wave Synth',
                          artist: 'Synth Wave Collective',
                          category: 'Music',
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContentDetailScreen(
                            title: 'New Wave Synth',
                            creator: 'Synth Wave Collective',
                            category: 'Music',
                          ),
                        ),
                      );
                    },
                    'Open Hero Card',
                  );
                },
              ),
              const SizedBox(height: 26),

              // 7. "Creators To Watch" Section (Navigates to CreatorDetailScreen & SearchScreen)
              CreatorSection(
                onSeeAllPressed: () {
                  _handleActionWithInterstitial(
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen(showBackButton: true)),
                      );
                    },
                    'See All Creators',
                  );
                },
                onCreatorPressed: (creator) {
                  _handleActionWithInterstitial(
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreatorDetailScreen(
                            name: creator.name,
                            avatar: creator.avatar,
                            role: creator.genre,
                            followers: creator.followersCount,
                          ),
                        ),
                      );
                    },
                    'Creator Profile ${creator.name}',
                  );
                },
              ),
              const SizedBox(height: 28),

              // 8. "Trending Now" Section (Navigates to ContentDetailScreen)
              TrendingSection(
                onItemTap: (title) {
                  _handleActionWithInterstitial(
                    () {
                      ServiceLocator.audioPlayer.playTrack(
                        TrackModel(
                          id: title,
                          title: title,
                          artist: 'Trending Artist',
                          category: 'Music',
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContentDetailScreen(
                            title: title,
                            creator: 'Trending Artist',
                            category: 'Music',
                          ),
                        ),
                      );
                    },
                    'Trending Item $title',
                  );
                },
              ),

              // Bottom padding spacer for floating nav
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}
