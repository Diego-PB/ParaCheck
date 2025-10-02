/*
 LogoWidget displays the ParaCheck logo as a centered circular image.
 It uses ClipOval to create a circular mask and scales the image
 to the provided size with a center zoom (BoxFit.cover).
 */

import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size; // Diameter of the circular logo image

  const LogoWidget({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipOval(
        child: Image.asset(
          'assets/Paracheck_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover, // Zooms on center of the image
        ),
      ),
    );
  }
}
