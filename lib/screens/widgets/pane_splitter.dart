// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class PaneSplitter extends StatelessWidget {
  const PaneSplitter({
    super.key,
    required this.onDelta,
    required this.onReset,
  });

  final ValueChanged<double> onDelta;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDelta(details.delta.dx),
        onDoubleTap: onReset,
        child: const SizedBox(
          width: 6,
          child: Center(
            child: SizedBox(
                width: 1,
                height: double.infinity,
                child: ColoredBox(color: Colors.grey)),
          ),
        ),
      ),
    );
  }
}
