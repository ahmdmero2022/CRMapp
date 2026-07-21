import 'package:flutter/material.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.text,
    required this.colorHex,
    this.radius = 20,
  });

  final String text;
  final String colorHex;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16));
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withOpacity(0.18),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}
