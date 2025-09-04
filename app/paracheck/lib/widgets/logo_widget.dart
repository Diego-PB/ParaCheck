import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  const LogoWidget({Key? key, this.size = 200}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipOval(
        child: Image.asset(
          'lib/assets/Paracheck_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover, // zoom sur le centre
        ),
      ),
    );
  }
}
