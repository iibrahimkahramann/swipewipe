import 'package:flutter/material.dart';

Widget swipeBackground({
  required Color color,
  required IconData icon,
  required String label,
  required Alignment alignment,
}) {
  return Container(
    color: color,
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    ),
  );
}
