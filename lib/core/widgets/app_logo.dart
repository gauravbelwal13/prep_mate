import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 250,
    this.height = 80,
    this.alignment = Alignment.center,
  });

  /// Width of the complete logo image.
  final double width;

  /// Height of the complete logo image.
  final double height;

  /// Alignment of the logo inside its available space.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}