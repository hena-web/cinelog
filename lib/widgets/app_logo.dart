import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 38});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.05,
              child: _LogoDot(size * 0.22),
            ),
            Positioned(
              top: size * 0.3,
              child: _LogoDot(size * 0.25),
            ),
            Positioned(
              bottom: size * 0.08,
              child: _LogoDot(size * 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoDot extends StatelessWidget {
  const _LogoDot(this.size);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
