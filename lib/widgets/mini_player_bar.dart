import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../theme/app_colors.dart';
import 'glass_container.dart';
import '../screens/content_detail_screen.dart';

class MiniPlayerBar extends StatelessWidget {
  final VoidCallback? onExpandPlayer;

  const MiniPlayerBar({super.key, this.onExpandPlayer});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ServiceLocator.audioPlayer,
      builder: (context, _) {
        final audio = ServiceLocator.audioPlayer;
        final track = audio.currentTrack;

        if (!audio.hasTrack || track == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: GestureDetector(
            onTap: () {
              if (onExpandPlayer != null) {
                onExpandPlayer!();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContentDetailScreen(
                      title: track.title,
                      creator: track.artist,
                      category: track.category,
                    ),
                  ),
                );
              }
            },
            child: GlassContainer(
              useBlur: true,
              borderRadius: 22,
              padding: const EdgeInsets.all(8),
              backgroundColor: Colors.white.withValues(alpha: 0.92),
              borderColor: const Color(0xFF5B46F6).withValues(alpha: 0.4),
              borderWidth: 1.5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Linear Progress Bar Line
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: audio.progressPercent,
                      minHeight: 3,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B46F6)),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Track Controls Row
                  Row(
                    children: [
                      // Icon Badge
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            track.coverIcon,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Title & Artist & Timer
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${track.artist} • ${audio.formattedPosition} / ${audio.formattedDuration}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Play/Pause Button
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        icon: Icon(
                          audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: const Color(0xFF5B46F6),
                          size: 26,
                        ),
                        onPressed: audio.togglePlayPause,
                      ),

                      const SizedBox(width: 4),

                      // Close / Cross (X) Button
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          audio.stop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
