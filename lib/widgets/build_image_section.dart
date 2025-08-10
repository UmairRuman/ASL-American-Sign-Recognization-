import 'dart:io';

import 'package:flutter/material.dart';

Widget buildImageSection(
  Animation<Offset> slideAnimation,
  Animation<double> fadeAnimation,
  File? selectedImage,
  bool isLoading,
  Animation<double> pulseAnimation,
) {
  return SlideTransition(
    position: slideAnimation,
    child: FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
                selectedImage != null
                    ? const Color(0xFF00D4AA)
                    : Colors.white24,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child:
              selectedImage != null
                  ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(selectedImage!, fit: BoxFit.cover),
                      if (isLoading)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF00D4AA),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Analyzing...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                  : AnimatedBuilder(
                    animation: pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: pulseAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 64,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select an image to analyze',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Camera or Gallery',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ),
    ),
  );
}
