import 'package:flutter/material.dart';

import '../models/rubik_face.dart';
import '../models/cube_state.dart';

class RubikPalette extends StatelessWidget {
  const RubikPalette({
    super.key,
    required this.state,
    required this.selected,
    required this.onSelected,
  });
  final CubeState state;
  final RubikColor? selected;
  final ValueChanged<RubikColor>? onSelected;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final face in CubeState.definitionOrder)
        Expanded(
          child: Semantics(
            selected: selected == face.centerColor,
            label:
                '${face.centerColor.label} ${state.count(face.centerColor)}/9',
            child: Tooltip(
              message: face.centerColor.label,
              child: InkWell(
                key: ValueKey('palette-${face.code}'),
                borderRadius: BorderRadius.circular(12),
                onTap: onSelected == null
                    ? null
                    : () => onSelected!(face.centerColor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 2,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: face.centerColor.paint,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected == face.centerColor
                                ? const Color(0xFF3346A8)
                                : const Color(0xFFB7C1D3),
                            width: selected == face.centerColor ? 4 : 1,
                          ),
                        ),
                        child: selected == face.centerColor
                            ? const Icon(
                                Icons.check,
                                color: Colors.black87,
                                size: 24,
                              )
                            : state.count(face.centerColor) == 9
                            ? const Icon(
                                Icons.done_all,
                                color: Colors.black54,
                                size: 18,
                              )
                            : null,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${state.count(face.centerColor)}/9',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: state.count(face.centerColor) == 9
                              ? const Color(0xFF21816A)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

extension RubikColorDisplay on RubikColor {
  Color get paint => switch (this) {
    RubikColor.white => Colors.white,
    RubikColor.yellow => Colors.yellow,
    RubikColor.red => Colors.red,
    RubikColor.orange => Colors.orange,
    RubikColor.green => Colors.green,
    RubikColor.blue => Colors.blue,
  };

  String get label => switch (this) {
    RubikColor.white => 'Trắng',
    RubikColor.yellow => 'Vàng',
    RubikColor.red => 'Đỏ',
    RubikColor.orange => 'Cam',
    RubikColor.green => 'Xanh lá',
    RubikColor.blue => 'Xanh dương',
  };
}

extension RubikFaceDisplay on RubikFace {
  String get label => switch (this) {
    RubikFace.up => 'Up — Trên',
    RubikFace.down => 'Down — Dưới',
    RubikFace.front => 'Front — Trước',
    RubikFace.back => 'Back — Sau',
    RubikFace.left => 'Left — Trái',
    RubikFace.right => 'Right — Phải',
  };

  String get topEdge =>
      '${topFace.code} (${topFace.centerColor.label.toLowerCase()})';
}
