import 'dart:ui';
import 'package:flutter/material.dart';

/// Kartu putih dengan efek blur (frosted glass)
class WhiteBlurCard extends StatelessWidget {
  const WhiteBlurCard({
    super.key,
    this.height,
    this.width,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.blurSigma = 29,   // kemulusan blur
    this.opacity = .1,    // putihnya (0..1)
    this.showBorder = true,
    this.showShadow = true,
    this.child,
  });

  final double? height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blurSigma;
  final double opacity;
  final bool showBorder;
  final bool showShadow;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: showBorder
                ? Border.all(color: Colors.white.withOpacity(.7), width: 1)
                : null,
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
