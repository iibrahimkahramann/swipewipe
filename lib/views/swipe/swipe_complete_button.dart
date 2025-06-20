import 'package:flutter/material.dart';

class SwipeCompleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SwipeCompleteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Listeyi tekrar başlat'),
    );
  }
}
