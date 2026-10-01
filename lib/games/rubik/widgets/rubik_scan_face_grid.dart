import 'package:flutter/material.dart';

import '../models/rubik_face.dart';
import 'rubik_palette.dart';

class RubikScanFaceGrid extends StatelessWidget {
  const RubikScanFaceGrid({
    super.key,
    required this.colors,
    required this.uncertain,
    required this.onEdit,
  });
  final List<RubikColor?> colors;
  final Set<int> uncertain;
  final ValueChanged<int>? onEdit;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: GridView.builder(
      padding: const EdgeInsets.all(4),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 9,
      itemBuilder: (context, i) => Semantics(
        label:
            'Ô ${i + 1}: ${colors[i]?.label ?? "Chưa rõ"}${uncertain.contains(i) ? ", cần kiểm tra" : ""}',
        child: FilledButton(
          key: ValueKey('scan-sticker-$i'),
          onPressed: onEdit == null ? null : () => onEdit!(i),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: colors[i]?.paint ?? const Color(0xFFCBD3DF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(
              color: uncertain.contains(i) ? Colors.black : Colors.black26,
              width: uncertain.contains(i) ? 3 : 1,
            ),
          ),
          child: uncertain.contains(i) || colors[i] == null
              ? const Icon(Icons.question_mark, color: Colors.black, size: 18)
              : null,
        ),
      ),
    ),
  );
}
