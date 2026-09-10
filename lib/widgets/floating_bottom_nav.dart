import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FloatingBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onAddPressed;

  const FloatingBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    const double navHeight = 82.0;
    const double addButtonSize = 62.0;

    return Padding(
      padding: EdgeInsets.only(
        left: 18.0,
        right: 18.0,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 14.0,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Water Glass Navigation Bar Container
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                // Liquid Caustics Ambient Glow
                BoxShadow(
                  color: const Color(0xFF5B46F6).withValues(alpha: 0.18),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: navHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    // Multi-layer Liquid Water Gradient Fill
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.65),
                        const Color(0xFFEEF3FF).withValues(alpha: 0.40),
                        const Color(0xFFDDE6FD).withValues(alpha: 0.50),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.80),
                      width: 1.6,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Specular Water Highlight Sheen Line on Top Rim
                      Positioned(
                        top: 0,
                        left: 20,
                        right: 20,
                        height: 1.5,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.95),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Navigation Bar Content Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Tab 0: Home
                          _buildNavItem(
                            index: 0,
                            icon: Icons.home_rounded,
                            label: 'Home',
                          ),

                          // Tab 1: Search
                          _buildNavItem(
                            index: 1,
                            icon: Icons.search_rounded,
                            label: 'Search',
                          ),

                          // Spacer for Center Water Add Button
                          const SizedBox(width: addButtonSize - 8),

                          // Tab 2: Activity
                          _buildNavItem(
                            index: 2,
                            icon: Icons.notifications_none_rounded,
                            label: 'Activity',
                          ),

                          // Tab 3: Profile
                          _buildNavItem(
                            index: 3,
                            icon: Icons.person_outline_rounded,
                            label: 'Profile',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Central Floating Action Water Plus Button
          Positioned(
            top: -18,
            child: GestureDetector(
              onTap: onAddPressed,
              child: Container(
                width: addButtonSize,
                height: addButtonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xFFF0F4FF),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B46F6).withValues(alpha: 0.30),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: addButtonSize - 6,
                    height: addButtonSize - 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.textPrimary,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = selectedIndex == index;

    if (isSelected) {
      return GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          width: 74,
          height: 66,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.40),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B46F6).withValues(alpha: 0.40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: SizedBox(
        width: 60,
        height: 66,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.95),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
