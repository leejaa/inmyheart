import 'package:flutter/material.dart';

class VerificationHeader extends StatelessWidget {
  const VerificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.pink[50],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  size: 80,
                  color: Colors.pink[300],
                ),
                const Icon(
                  Icons.favorite,
                  size: 60,
                  color: Colors.white,
                ),
                Icon(
                  Icons.favorite,
                  size: 40,
                  color: Colors.pink[300],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'IN MY ❤️',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.pink[400],
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          '환영합니다!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          '휴대폰 번호로 간편하게 시작하세요',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
