import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BackgroundCircles extends StatelessWidget {
  const BackgroundCircles({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          top: -size.width * 0.2,
          right: -size.width * 0.2,
          child: _Circle(diameter: size.width * 0.6),
        ),
        Positioned(
          bottom: -size.width * 0.25,
          left: -size.width * 0.2,
          child: _Circle(diameter: size.width * 0.65),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final double diameter;
  const _Circle({required this.diameter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: kWhiteColor.withOpacity(0.06),
          width: 1.5,
        ),
      ),
    );
  }
}