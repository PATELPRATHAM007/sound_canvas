import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../ads/banner_ad_widget.dart';
import '../ads/interstitial_ad_manager.dart';
import '../services/service_locator.dart';
import '../services/audio_player_service.dart';

class ContentDetailScreen extends StatefulWidget {
  final String title;
  final String creator;
  final String category;

  const ContentDetailScreen({
    super.key,
    required this.title,
    required this.creator,
    required this.category,
  });

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  int _clickCounter = 0;
  final TextEditingController _commentController = TextEditingController();

  final List<Map<String, String>> _comments = [
    {'name': 'Sophia M.', 'comment': 'This synth drop is incredible! 🔥', 'time': '5m ago'},
    {'name': 'Marcus K.', 'comment': 'Top tier production quality as always.', 'time': '12m ago'},
    {'name': 'Elena R.', 'comment': 'Listening to this on repeat while working! ✨', 'time': '1h ago'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = ServiceLocator.audioPlayer;
      if (audio.currentTrack?.title != widget.title) {
        audio.playTrack(
          TrackModel(
            id: widget.title,
            title: widget.title,
            artist: widget.creator,
            category: widget.category,
          ),
        );
      }
    });
  }

  void _handleActionWithInterstitial(VoidCallback action, String actionName) {
    _clickCounter++;
    debugPrint('[ContentDetailScreen] Action clicked ($actionName). Count: $_clickCounter/2');
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
    _commentController.dispose();
    super.dispose();
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
              // Top Navigation Bar
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      widget.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B46F6),
                        letterSpacing: 1.2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary),
                      onPressed: () {
                        _handleActionWithInterstitial(() {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sharing "${widget.title}"'),
                              backgroundColor: const Color(0xFF5B46F6),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        }, 'Share Content');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Player Hero Cover Art
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B46F6), Color(0xFF8E37F5), Color(0xFFE100FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B46F6).withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ListenableBuilder(
                        listenable: ServiceLocator.audioPlayer,
                        builder: (context, _) {
                          final audio = ServiceLocator.audioPlayer;
                          return Center(
                            child: Icon(
                              audio.isPlaying ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                              size: 100,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 16,
                        top: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'HD AUDIO',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title, Creator & Like Button Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.creator,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListenableBuilder(
                      listenable: ServiceLocator.contentStore,
                      builder: (context, _) {
                        final store = ServiceLocator.contentStore;
                        final isLiked = store.isLiked(widget.title);
                        return Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isLiked ? Colors.redAccent : AppColors.textPrimary,
                                size: 28,
                              ),
                              onPressed: () {
                                _handleActionWithInterstitial(() {
                                  store.toggleLike(widget.title);
                                }, 'Like Track Toggle');
                              },
                            ),
                            Text(
                              isLiked ? '1,421' : '1,420',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Scrubber Progress Slider (Local ListenableBuilder Update)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListenableBuilder(
                  listenable: ServiceLocator.audioPlayer,
                  builder: (context, _) {
                    final audio = ServiceLocator.audioPlayer;
                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            activeTrackColor: const Color(0xFF5B46F6),
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.8),
                            thumbColor: const Color(0xFF5B46F6),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                          ),
                          child: Slider(
                            value: audio.progressPercent,
                            onChanged: (val) {
                              audio.seekPercent(val);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                audio.formattedPosition,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              Text(
                                audio.formattedDuration,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Player Controls (Previous, Play/Pause, Next)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle_rounded, color: AppColors.textSecondary, size: 24),
                    onPressed: () {
                      _handleActionWithInterstitial(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Shuffle enabled'),
                            backgroundColor: const Color(0xFF5B46F6),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }, 'Shuffle Button');
                    },
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 36),
                    onPressed: () {
                      _handleActionWithInterstitial(() {
                        ServiceLocator.audioPlayer.skipPrevious();
                      }, 'Previous Track');
                    },
                  ),
                  const SizedBox(width: 16),

                  // Play / Pause Circle with Localized ListenableBuilder
                  ListenableBuilder(
                    listenable: ServiceLocator.audioPlayer,
                    builder: (context, _) {
                      final audio = ServiceLocator.audioPlayer;
                      return GestureDetector(
                        onTap: () {
                          _handleActionWithInterstitial(() {
                            audio.togglePlayPause();
                          }, 'Play Pause Toggle');
                        },
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5B46F6).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 36),
                    onPressed: () {
                      _handleActionWithInterstitial(() {
                        ServiceLocator.audioPlayer.skipNext();
                      }, 'Next Track');
                    },
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.repeat_rounded, color: AppColors.textSecondary, size: 24),
                    onPressed: () {
                      _handleActionWithInterstitial(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Repeat enabled'),
                            backgroundColor: const Color(0xFF5B46F6),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }, 'Repeat Button');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Banner Ad Widget
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: BannerAdWidget(),
              ),

              const SizedBox(height: 20),

              // Comments Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassContainer(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${_comments.length} Comments',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Comment Input Row
                      Row(
                        children: [
                          Expanded(
                            child: GlassContainer(
                              borderRadius: 16,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              child: TextField(
                                controller: _commentController,
                                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                decoration: const InputDecoration(
                                  hintText: 'Add a comment...',
                                  hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: Color(0xFF5B46F6)),
                            onPressed: () {
                              if (_commentController.text.trim().isNotEmpty) {
                                _handleActionWithInterstitial(() {
                                  setState(() {
                                    _comments.insert(0, {
                                      'name': 'You',
                                      'comment': _commentController.text.trim(),
                                      'time': 'Just now',
                                    });
                                    _commentController.clear();
                                  });
                                }, 'Post Comment');
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Comments List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final c = _comments[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF5B46F6).withValues(alpha: 0.2),
                                child: Text(
                                  c['name']![0],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5B46F6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          c['name']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          c['time']!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c['comment']!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
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
