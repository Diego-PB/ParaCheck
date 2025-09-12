import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  const LogoWidget({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipOval(
        child: Image.asset(
          'assets/Paracheck_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover, // zoom sur le centre
        ),
      ),
    );
  }
}
