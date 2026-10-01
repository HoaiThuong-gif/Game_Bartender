import 'package:flutter/material.dart';
import '../controllers/solution_controller.dart';
import '../helpers/rubik_move_helper.dart';

class SolutionMoveList extends StatelessWidget {
  const SolutionMoveList({super.key, required this.controller});
  final SolutionController controller;

  @override
  Widget build(BuildContext context) => SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 8, 8, 8), child: Row(children: [
      const Expanded(child: Text('TẤT CẢ CÁC BƯỚC', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      IconButton(tooltip: 'Đóng danh sách', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
    ])),
    Expanded(child: controller.moves.isEmpty ? const Center(child: Text('Không cần xoay thêm.')) : ListView.builder(
      itemCount: controller.moves.length,
      itemBuilder: (context, index) {
        final move = controller.moves[index];
        return ListTile(
          key: ValueKey('move-row-$index'),
          selected: controller.currentMoveIndex == index,
          selectedTileColor: const Color(0xFFD7EFEC),
          leading: Text('${index + 1}'.padLeft(2, '0')),
          title: Text(move.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(move.description),
          trailing: index < controller.completed ? const Icon(Icons.check, size: 18) : null,
          onTap: controller.busy ? null : () { controller.seek(index); Navigator.pop(context); },
        );
      },
    )),
  ]));
}
