import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/rubik/controllers/solution_controller.dart';
import 'package:nhom_bar/games/rubik/helpers/rubik_move_helper.dart';
import 'package:nhom_bar/games/rubik/models/cube_state.dart';
import 'package:nhom_bar/games/rubik/models/rubik_face.dart';
import 'package:nhom_bar/games/rubik/models/rubik_move.dart';
import 'package:nhom_bar/games/rubik/screens/solution_screen.dart';
import 'package:nhom_bar/games/rubik/services/cube_move_service.dart';

Widget preview(BuildContext context, CubeState state) =>
    Text(state.toFaceletDefinition(), key: const ValueKey('guide-preview'));

void main() {
  test('all 18 move descriptions and inverses', () {
    const service = CubeMoveService();
    final initial = CubeState.solved();
    for (final face in RubikFace.values) {
      for (final turn in RubikTurn.values) {
        final move = RubikMove(face, turn);
        expect(describeMove(move.toString()), contains(face.vietnameseName));
        expect(
          describeMove(move.toString()),
          contains(turn == RubikTurn.half ? '180°' : '90°'),
        );
        expect(
          service
              .apply(service.apply(initial, move), move.inverse)
              .toFaceletDefinition(),
          initial.toFaceletDefinition(),
        );
      }
    }
  });

  test(
    'guide advances exact state, undoes, completes and guards bounds',
    () async {
      final r = RubikMove.parse('R');
      final initial = const CubeMoveService().apply(CubeState.solved(), r);
      final guide = SolutionController(
        initialState: initial,
        moves: [r.inverse],
      );
      await guide.previous();
      expect(guide.completed, 0);
      await guide.next();
      expect(guide.isComplete, isTrue);
      expect(
        guide.state.toFaceletDefinition(),
        CubeState.solved().toFaceletDefinition(),
      );
      await guide.next();
      expect(guide.completed, 1);
      await guide.previous();
      expect(guide.state.toFaceletDefinition(), initial.toFaceletDefinition());
      expect(guide.lastUndo.toString(), 'R');
      guide.dispose();
    },
  );

  testWidgets(
    'step guide shows Vietnamese, accurate preview, inverse and legend',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final initial = const CubeMoveService().apply(
        CubeState.solved(),
        RubikMove.parse('R'),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: SolutionScreen(
            moves: [RubikMove.parse("R'")],
            initialState: initial,
            previewBuilder: preview,
          ),
        ),
      );
      expect(find.text('MẶT PHẢI'), findsOneWidget);
      expect(find.text('Xoay 90° ngược chiều kim đồng hồ'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('next-step')));
      await tester.pumpAndSettle();
      expect(find.text('Rubik đã được giải!'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('guide-preview'))).data,
        CubeState.solved().toFaceletDefinition(),
      );
      await tester.tap(find.byKey(const ValueKey('previous-step')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('guide-preview'))).data,
        initial.toFaceletDefinition(),
      );
      await tester.ensureVisible(find.text('Xem chú thích'));
      await tester.tap(find.text('Xem chú thích'));
      await tester.pumpAndSettle();
      expect(find.text('CHÚ THÍCH KÝ HIỆU'), findsOneWidget);
      expect(find.textContaining('Chiều xoay được tính'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
