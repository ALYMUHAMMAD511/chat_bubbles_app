import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../constants.dart';

class CustomCircleIconButton extends StatelessWidget {
  const CustomCircleIconButton({super.key, required this.onPressed, required this.icon});

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white12,
        ),
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 25,
            color: HexColor(kSecondaryColor),
          ),
        ),
      ],
    );
  }
}
