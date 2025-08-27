import 'dart:ui';
import 'package:flutter/material.dart';

/// Kartu glassmorphism ala iOS (tanpa aset gambar)
/// - Backdrop blur
/// - Tint transparan
/// - Border putih tipis
/// - Soft outer shadow
/// - Highlight liquid di sisi atas
///
/// Pakai:
/// LiquidGlassCard(
///   height: 120,
///   borderRadius: BorderRadius.circular(24),
///   padding: const EdgeInsets.all(20),
///   child: ...
/// )
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    this.height,
    this.width,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.blurSigma = 16,
    this.tintColor = const Color(0xFFFFFFFF),
    this.tintOpacity = .08,
    this.borderOpacity = .28,
    this.shadowOpacity = .25,
    this.child,
  });

  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;

  /// Seberapa blur latar belakang
  final double blurSigma;

  /// Warna tint (biasanya putih) & opasitasnya
  final Color tintColor;
  final double tintOpacity;

  /// Opasitas garis border putih
  final double borderOpacity;

  /// Opasitas shadow luar
  final double shadowOpacity;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            // Tint transparan (gradien tipis bikin lebih “liquid”)
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tintColor.withOpacity(tintOpacity + .04),
                tintColor.withOpacity(tintOpacity),
                tintColor.withOpacity(tintOpacity - .02),
              ],
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 1.2,
            ),
            boxShadow: [
              // soft shadow bawah agar terangkat
              BoxShadow(
                color: Colors.black.withOpacity(shadowOpacity),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Highlight “liquid” di bagian atas (seperti iOS)
              Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  widthFactor: .96,
                  child: Container(
                    height: (height ?? 120) * .42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: (borderRadius.topLeft),
                        topRight: (borderRadius.topRight),
                        bottomLeft: Radius.circular(
                            (borderRadius.bottomLeft.x) * .9),
                        bottomRight: Radius.circular(
                            (borderRadius.bottomRight.x) * .9),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(.38),
                          Colors.white.withOpacity(.08),
                          Colors.white.withOpacity(0),
                        ],
                        stops: const [0, .55, 1],
                      ),
                    ),
                  ),
                ),
              ),

              // Gloss kecil di pojok kanan–bawah (nuansa liquid)
              Positioned(
                right: 16,
                bottom: 14,
                child: Container(
                  width: 80,
                  height: 26,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withOpacity(.10),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),

              // Konten pengguna
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }
}
