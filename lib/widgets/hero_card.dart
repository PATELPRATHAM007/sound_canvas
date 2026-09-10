import 'package:flutter/material.dart';
import 'glass_container.dart';

class HeroCard extends StatelessWidget {
  final VoidCallback? onPlayPressed;
  final VoidCallback? onTap;

  const HeroCard({
    super.key,
    this.onPlayPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      height: 250,
      child: GlassContainer(
        borderRadius: 28,
        padding: EdgeInsets.zero,
        borderColor: Colors.white.withValues(alpha: 0.55),
        borderWidth: 1.2,
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Artist Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/images/hero_artist.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF532B88), Color(0xFF2F1B41), Color(0xFF162544)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Gradient Overlay for Readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),

            // Bottom Content Row
            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'New Wave',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rising Artists You Need To Know',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.90),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Circular Glass Play Button
                  GlassContainer(
                    width: 56,
                    height: 56,
                    borderRadius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.32),
                    borderColor: Colors.white.withValues(alpha: 0.75),
                    onTap: onPlayPressed,
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
