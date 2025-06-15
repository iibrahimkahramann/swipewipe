import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';

class DeleteCountBadge extends ConsumerWidget {
  const DeleteCountBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(swipePendingDeleteProvider).length;
    final size = MediaQuery.of(context).size;

    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(size.width * 0.012),
      decoration:
          const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      child: Text(
        '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.03,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
