import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CreatorItemData {
  final String name;
  final String category;
  final String? imagePath;
  final bool isDefaultAvatar;
  final String avatar;
  final String followersCount;

  const CreatorItemData({
    required this.name,
    required this.category,
    this.imagePath,
    this.isDefaultAvatar = false,
    this.avatar = '🎨',
    this.followersCount = '14.2k',
  });

  String get genre => category;
}

class CreatorSection extends StatelessWidget {
  final VoidCallback? onSeeAllPressed;
  final ValueChanged<CreatorItemData>? onCreatorPressed;

  const CreatorSection({
    super.key,
    this.onSeeAllPressed,
    this.onCreatorPressed,
  });

  static const List<CreatorItemData> creators = [
    CreatorItemData(
      name: 'Luna Hill',
      category: 'Music',
      imagePath: 'assets/images/creator_luna.png',
      avatar: '👩‍🎤',
      followersCount: '45.2k',
    ),
    CreatorItemData(
      name: 'Zayn Park',
      category: 'Visual Artist',
      isDefaultAvatar: true,
      avatar: '🎨',
      followersCount: '28.1k',
    ),
    CreatorItemData(
      name: 'Maya Chen',
      category: 'Photographer',
      imagePath: 'assets/images/creator_maya.png',
      avatar: '📸',
      followersCount: '19.8k',
    ),
    CreatorItemData(
      name: 'Luna H...',
      category: 'Designer',
      imagePath: 'assets/images/creator_luna2.png',
      avatar: '✨',
      followersCount: '12.4k',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Creators To Watch',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              GestureDetector(
                onTap: onSeeAllPressed,
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal Creator List
        SizedBox(
          height: 155,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: creators.length,
            separatorBuilder: (context, index) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final item = creators[index];
              return _buildCreatorCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorCard(BuildContext context, CreatorItemData item) {
    const double avatarRadius = 48.0;

    return GestureDetector(
      onTap: () => onCreatorPressed?.call(item),
      child: Column(
        children: [
          // Circular Avatar Container
          Container(
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: item.isDefaultAvatar || item.imagePath == null
                  ? Container(
                      color: const Color(0xFF90B5DC),
                      child: Center(
                        child: Text(
                          item.avatar,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    )
                  : Image.asset(
                      item.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF90B5DC),
                          child: Center(
                            child: Text(
                              item.avatar,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 10),

          // Creator Name
          Text(
            item.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),

          // Creator Category
          Text(
            item.category,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
