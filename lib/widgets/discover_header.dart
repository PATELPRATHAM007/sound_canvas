import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_container.dart';

class DiscoverHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onMessagePressed;

  const DiscoverHeader({
    super.key,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onMessagePressed,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 58.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Menu Button (2 Horizontal Lines)
          GlassContainer(
            width: buttonSize,
            height: buttonSize,
            borderRadius: buttonSize / 2,
            onTap: onMenuPressed,
            child: Center(
              child: CustomPaint(
                size: const Size(20, 10),
                painter: TwoLinesPainter(color: AppColors.textPrimary),
              ),
            ),
          ),

          // Right: Notification & Message Buttons
          Row(
            children: [
              // Bell / Notification Button
              GlassContainer(
                width: buttonSize,
                height: buttonSize,
                borderRadius: buttonSize / 2,
                onTap: onNotificationPressed,
                child: const Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textPrimary,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Chat / Message Button
              GlassContainer(
                width: buttonSize,
                height: buttonSize,
                borderRadius: buttonSize / 2,
                onTap: onMessagePressed,
                child: const Center(
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TwoLinesPainter extends CustomPainter {
  final Color color;

  TwoLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // Line 1 (Top line)
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width, size.height * 0.2),
      paint,
    );

    // Line 2 (Bottom line)
    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width, size.height * 0.8),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
