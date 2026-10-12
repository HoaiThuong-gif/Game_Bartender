import 'dart:async';

import 'package:flutter/material.dart';

import '../data/gacha_rewards.dart';
import '../models/gacha_reward.dart';
import '../services/gacha_collection.dart';
import '../services/cat_equipment.dart';
import '../../../screens/home/lobby_cats.dart';
import '../../../screens/home/widgets/lobby_cat_layer.dart';
import 'gacha_colors.dart';
import 'reward_icon.dart';

class GachaInventoryDialog extends StatefulWidget {
  const GachaInventoryDialog({super.key, required this.collection});

  final GachaCollection collection;

  @override
  State<GachaInventoryDialog> createState() => _GachaInventoryDialogState();
}

class _GachaInventoryDialogState extends State<GachaInventoryDialog> {
  late final _equipment = identical(widget.collection, GachaCollection.instance)
      ? CatEquipment.instance
      : CatEquipment(collection: widget.collection);
  CatType _previewColor = CatType.black;
  bool _selectedHat = false;
  bool _saving = false;

  Future<void> _toggleHat() async {
    setState(() => _saving = true);
    final saved = _equipment.head == CatEquipment.nonLa
        ? await _equipment.unequip()
        : await _equipment.equip();
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa lưu được trang bị. Hãy thử lại.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(widget.collection.load());
    unawaited(_equipment.load());
  }

  @override
  void dispose() {
    if (!identical(_equipment, CatEquipment.instance)) _equipment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    key: const ValueKey('gacha-inventory-dialog'),
    backgroundColor: GachaColors.paper,
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: GachaColors.brick, width: 3),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: Listenable.merge([widget.collection, _equipment]),
          builder: (context, _) {
            final collection = widget.collection;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tủ đồ',
                        style: TextStyle(
                          color: GachaColors.brick,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('gacha-inventory-close'),
                      tooltip: 'Đóng',
                      color: GachaColors.ink,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(color: GachaColors.brick),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (collection.error != null)
                          Column(
                            children: [
                              const Text(
                                'Chưa thể đọc hoặc lưu Tủ đồ.',
                                style: TextStyle(color: GachaColors.brick),
                              ),
                              TextButton(
                                key: const ValueKey('gacha-inventory-retry'),
                                onPressed: () => unawaited(collection.load()),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        if (!collection.isLoaded && collection.error == null)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: GachaColors.brick,
                            ),
                          ),
                        if (collection.isLoaded) ...[
                          Text(
                            'Đã sưu tập ${collection.unlockedCount}/${gachaRewards.length}',
                            key: const ValueKey('gacha-collection-count'),
                            style: const TextStyle(
                              color: GachaColors.ink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedHat &&
                              collection.owns(CatEquipment.rewardNumber)) ...[
                            DropdownButton<CatType>(
                              value: _previewColor,
                              items: [
                                for (final type in CatType.values)
                                  DropdownMenuItem(
                                    value: type,
                                    child: Text(type.name),
                                  ),
                              ],
                              onChanged: (type) =>
                                  setState(() => _previewColor = type!),
                            ),
                            Wrap(
                              spacing: 8,
                              children: [
                                for (final pose in CatPose.values)
                                  SizedBox(
                                    width: 110,
                                    height: 132,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: 110,
                                          height: 110,
                                          child: CatSprite(
                                            cat: LobbyCat(_previewColor, pose),
                                            wearHead: true,
                                          ),
                                        ),
                                        Text('Pose ${pose.index + 1}'),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            TextButton(
                              key: const ValueKey('non-la-equip'),
                              onPressed: _saving ? null : _toggleHat,
                              child: Text(
                                _equipment.head == CatEquipment.nonLa
                                    ? 'Tháo'
                                    : 'Trang bị',
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth >= 440
                                  ? 3
                                  : 2;
                              final cellWidth =
                                  (constraints.maxWidth - (columns - 1) * 12) /
                                  columns;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  for (final reward in gachaRewards)
                                    SizedBox(
                                      width: cellWidth,
                                      child: GestureDetector(
                                        onTap:
                                            reward.number ==
                                                    CatEquipment.rewardNumber &&
                                                collection.owns(reward.number)
                                            ? () => setState(
                                                () => _selectedHat =
                                                    !_selectedHat,
                                              )
                                            : null,
                                        child: _CollectionItem(
                                          reward: reward,
                                          owned: collection.owns(reward.number),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _CollectionItem extends StatelessWidget {
  const _CollectionItem({required this.reward, required this.owned});

  final GachaReward reward;
  final bool owned;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${reward.name}, ${owned ? 'Đã sở hữu' : 'Chưa sở hữu'}',
    child: DecoratedBox(
      key: ValueKey('gacha-collection-item-${reward.number}'),
      decoration: BoxDecoration(
        color: owned
            ? Colors.white.withValues(alpha: .55)
            : GachaColors.ink.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: owned
              ? GachaColors.brick
              : GachaColors.ink.withValues(alpha: .2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: owned ? 1 : .35,
                  child: RewardIcon(reward: reward, size: 64),
                ),
                if (!owned)
                  Icon(
                    Icons.lock_outline,
                    key: ValueKey('gacha-collection-locked-${reward.number}'),
                    color: GachaColors.ink,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reward.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GachaColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              owned ? 'Đã sở hữu' : 'Chưa sở hữu',
              style: const TextStyle(color: GachaColors.brick, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
