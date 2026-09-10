import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_container.dart';

class SearchSection extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;

  const SearchSection({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    const double searchHeight = 58.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // Expanded Search Field
          Expanded(
            child: GlassContainer(
              height: searchHeight,
              borderRadius: 30,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search creators, music, topics...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Circular Filter Button
          GlassContainer(
            width: searchHeight,
            height: searchHeight,
            borderRadius: searchHeight / 2,
            onTap: onFilterPressed,
            child: const Center(
              child: Icon(
                Icons.tune_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
