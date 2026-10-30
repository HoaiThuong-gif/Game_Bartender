import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/rubik/models/cube_state.dart';
import 'package:nhom_bar/games/rubik/models/rubik_face.dart';
import 'package:nhom_bar/games/rubik/services/rubik_preview_bridge.dart';

void main() {
  test('buffers latest before page load; serializes rapid changes; skips duplicates', () async {
    final commands = <String>[];
    final first = Completer<void>();
    final bridge = RubikPreviewBridge((script) async {
      commands.add(script);
      if (commands.length == 1) await first.future;
    });
    final empty = CubeState.empty();
    bridge.setState(CubeState.solved());
    bridge.setState(empty);
    expect(commands, isEmpty);
    bridge.pageReady();
    expect(
      commands.single,
      contains(empty.toFaceletDefinition(allowIncomplete: true)),
    );
    bridge.setState(empty.withSticker(RubikFace.up, 0, RubikColor.red));
    final latest = empty.withSticker(RubikFace.back, 8, RubikColor.green);
    bridge.setState(latest);
    first.complete();
    await Future<void>.delayed(Duration.zero);
    expect(commands, hasLength(2));
    expect(
      commands.last,
      contains(latest.toFaceletDefinition(allowIncomplete: true)),
    );
    bridge.setState(latest);
    expect(commands, hasLength(2));
    bridge.pageStarted();
    bridge.pageReady();
    await Future<void>.delayed(Duration.zero);
    expect(commands, hasLength(3));
    bridge.dispose();
    bridge.setState(empty);
    expect(commands, hasLength(3));
  });
}
