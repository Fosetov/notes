import 'package:flutter/material.dart';
import 'dart:ui';

class GlowingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final double size;

  const GlowingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.color,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(size / 4),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 4),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(size / 4),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                splashColor: color.withOpacity(0.3),
                highlightColor: color.withOpacity(0.2),
                child: Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: size * 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
