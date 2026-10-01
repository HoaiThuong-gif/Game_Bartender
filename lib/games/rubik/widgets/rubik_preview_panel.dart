import 'package:flutter/material.dart';

import '../models/cube_state.dart';
import 'rubik_3d_view.dart';

typedef CubePreviewBuilder = Widget Function(
  BuildContext context,
  CubeState state,
);

/// Preview stays mounted while only the input area scrolls.
class RubikPreviewPanel extends StatelessWidget {
  const RubikPreviewPanel({
    super.key,
    required this.state,
    this.builder,
    this.active = true,
  });
  final CubeState state;
  final CubePreviewBuilder? builder;
  final bool active;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          builder?.call(context, state) ??
              Rubik3DView(cubeState: state, active: active),
          const Positioned(
            left: 12,
            bottom: 8,
            child: IgnorePointer(
              child: Text(
                'Kéo để xoay • Chụm để thu/phóng',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
