import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_container.dart';

class TrendingSection extends StatelessWidget {
  final void Function(String title)? onItemTap;
  const TrendingSection({super.key, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Trending Now',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal Trending Cards
        SizedBox(
          height: 190,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              // Card 1
              _buildTrendingCard(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF7BBF),
                    Color(0xFF9D4EDD),
                    Color(0xFF5A189A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                title: 'Acoustic Sessions',
                subtitle: '12.4k listeners',
              ),
              const SizedBox(width: 16),

              // Card 2
              _buildTrendingCard(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4EA8DE),
                    Color(0xFF5E60CE),
                    Color(0xFF7400B8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                title: 'Electronic Vibes',
                subtitle: '28.9k listeners',
              ),
              const SizedBox(width: 16),

              // Card 3
              _buildTrendingCard(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF9E00),
                    Color(0xFFFF0054),
                    Color(0xFF9E0059),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                title: 'Indie Discoveries',
                subtitle: '8.1k listeners',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard({
    required LinearGradient gradient,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: onItemTap != null ? () => onItemTap!(title) : null,
      child: Container(
        width: 230,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GlassContainer(
          borderRadius: 24,
          padding: EdgeInsets.zero,
          borderColor: Colors.white.withValues(alpha: 0.65),
          child: Stack(
            children: [
              // Background Gradient
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: gradient,
                ),
              ),

              // Content Overlay
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
