import 'package:flutter/material.dart';

Widget buildPredictionSection(String prediction) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            prediction.isNotEmpty
                ? [const Color(0xFF00D4AA), const Color(0xFF007991)]
                : [const Color(0xFF1D1E33), const Color(0xFF2A2D3A)],
      ),
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color:
              prediction.isNotEmpty
                  ? const Color(0xFF00D4AA).withOpacity(0.3)
                  : Colors.black26,
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(
          prediction.isNotEmpty ? Icons.psychology : Icons.search,
          size: 32,
          color: Colors.white,
        ),
        const SizedBox(height: 12),
        Text(
          'Prediction Result',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            prediction.isEmpty ? 'No prediction yet' : prediction,
            key: ValueKey(prediction),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    ),
  );
}
