import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final ShapeBorder? customShape;
  final bool useBlur;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.2,
    this.onTap,
    this.customShape,
    this.useBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? Colors.white.withValues(alpha: 0.70);
    final effectiveBorderColor = borderColor ?? AppColors.glassBorder;

    Widget containerContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: customShape == null ? BorderRadius.circular(borderRadius) : null,
        shape: customShape != null ? BoxShape.circle : BoxShape.rectangle,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (useBlur) {
      if (customShape != null) {
        containerContent = ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: containerContent,
          ),
        );
      } else {
        containerContent = ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: containerContent,
          ),
        );
      }
    } else {
      if (customShape != null) {
        containerContent = ClipOval(child: containerContent);
      } else {
        containerContent = ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: containerContent,
        );
      }
    }

    if (margin != null) {
      containerContent = Padding(
        padding: margin!,
        child: containerContent,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: containerContent,
      );
    }

    return containerContent;
  }
}
