import 'package:flutter/material.dart';

Widget buildActionButton({
  required IconData icon,
  required String label,
  required VoidCallback? onPressed,
  required Gradient gradient,
  bool isFullWidth = false,
}) {
  return Container(
    width: isFullWidth ? double.infinity : null,
    height: 60,
    decoration: BoxDecoration(
      gradient:
          onPressed != null
              ? gradient
              : const LinearGradient(
                colors: [Color(0xFF3C4055), Color(0xFF2A2D3A)],
              ),
      borderRadius: BorderRadius.circular(30),
      boxShadow:
          onPressed != null
              ? [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
              : null,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: onPressed != null ? Colors.white : Colors.white38,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: onPressed != null ? Colors.white : Colors.white38,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
