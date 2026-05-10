import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:druk/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 0.0, // Reduced for clearer solid-look containers
    this.opacity = 0.06, // Slightly more opaque for clear distinction
    this.borderRadius = 28.0, // More rounded per iOS 17 style
    this.padding = const EdgeInsets.all(20.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        // Using iOS-style secondary background color for Dark Mode
        color: const Color(0xFF1C1C1E), 
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
