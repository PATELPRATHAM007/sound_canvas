import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../ads/banner_ad_widget.dart';
import '../ads/interstitial_ad_manager.dart';
import 'content_detail_screen.dart';
import '../services/service_locator.dart';
import '../services/audio_player_service.dart';

class SearchScreen extends StatefulWidget {
  final bool showBackButton;
  const SearchScreen({super.key, this.showBackButton = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _clickCounter = 0;

  final List<String> _categories = [
    'All',
    'Music',
    'Podcasts',
    'Art',
    'Fashion',
    'Tech',
  ];

  final List<String> _trendingSearches = [
    '#SynthWave',
    '#LoFiBeats',
    '#DigitalArt',
    '#3DAnimation',
    '#Cyberpunk',
    '#ChillVibes',
  ];

  final List<Map<String, String>> _allResults = [
    {
      'title': 'Midnight Horizon Synth',
      'creator': 'Luna Eclipse',
      'category': 'Music',
      'duration': '3:45',
      'plays': '24.5k',
      'icon': '🎵',
    },
    {
      'title': 'Future of AI Design',
      'creator': 'Tech pulse Daily',
      'category': 'Tech',
      'duration': '18:20',
      'plays': '45.1k',
      'icon': '💻',
    },
    {
      'title': 'Neon City Cyberpunk Art',
      'creator': 'CyberStudio',
      'category': 'Art',
      'duration': 'Photo',
      'plays': '12.8k',
      'icon': '🎨',
    },
    {
      'title': 'Streetwear 2026 Trends',
      'creator': 'Vogue Pulse',
      'category': 'Fashion',
      'duration': '05:12',
      'plays': '8.9k',
      'icon': '✨',
    },
    {
      'title': 'Deep Ambient Soundscapes',
      'creator': 'Acoustic Mind',
      'category': 'Music',
      'duration': '12:00',
      'plays': '67.2k',
      'icon': '🎧',
    },
    {
      'title': 'Web3 & Beyond Podcast',
      'creator': 'Future Talk',
      'category': 'Podcasts',
      'duration': '42:10',
      'plays': '19.4k',
      'icon': '🎙️',
    },
  ];

  void _handleActionWithInterstitial(VoidCallback action, String actionName) {
    _clickCounter++;
    debugPrint('[SearchScreen] Action clicked ($actionName). Count: $_clickCounter/2');
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredResults {
    return _allResults.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item['category'] == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          item['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['creator']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
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
              padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
              child: Row(
                children: [
                  if (widget.showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  const Text(
                    'Search & Explore',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search creators, music, art...',
                          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Category Horizontal Tabs
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
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
                            _selectedCategory = cat;
                          });
                        }, 'Select Category $cat');
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Banner Ad Widget
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: BannerAdWidget(),
            ),

            const SizedBox(height: 12),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trending Chips Section
                    if (_searchQuery.isEmpty) ...[
                      const Text(
                        'Trending Searches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _trendingSearches.map((tag) {
                          return GestureDetector(
                            onTap: () {
                              _handleActionWithInterstitial(() {
                                _searchController.text = tag.replaceAll('#', '');
                                setState(() {
                                  _searchQuery = tag.replaceAll('#', '');
                                });
                              }, 'Click Trending $tag');
                            },
                            child: GlassContainer(
                              borderRadius: 16,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.trending_up_rounded, size: 16, color: Color(0xFF5B46F6)),
                                  const SizedBox(width: 6),
                                  Text(
                                    tag,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Results Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _searchQuery.isEmpty ? 'Recommended for You' : 'Search Results (${_filteredResults.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _selectedCategory,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Results List
                    if (_filteredResults.isEmpty)
                      GlassContainer(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(32),
                        margin: const EdgeInsets.only(top: 20),
                        child: Center(
                          child: Column(
                            children: const [
                              Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
                              SizedBox(height: 12),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Try searching for another keyword or category.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredResults.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _filteredResults[index];
                          return GestureDetector(
                            onTap: () {
                              _handleActionWithInterstitial(() {
                                ServiceLocator.audioPlayer.playTrack(
                                  TrackModel(
                                    id: item['title']!,
                                    title: item['title']!,
                                    artist: item['creator']!,
                                    category: item['category']!,
                                    coverIcon: item['icon'] ?? '🎵',
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ContentDetailScreen(
                                      title: item['title']!,
                                      creator: item['creator']!,
                                      category: item['category']!,
                                    ),
                                  ),
                                );
                              }, 'Open Search Result ${item['title']}');
                            },
                            child: GlassContainer(
                              borderRadius: 20,
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  // Icon Badge
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item['icon']!,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Text details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item['creator']} • ${item['category']}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Plays & Play Button
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        item['plays']!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF5B46F6),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF5B46F6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
