import 'dart:convert';

import '../controllers/bartender_controller.dart';
import '../models/game_item.dart';
import '../models/order.dart';
import '../models/processing_rules.dart';
import '../models/recipe_pool.dart';
import '../models/station.dart';

/// The renderer displays state and requests actions. Game rules stay in Dart.
/// Pointer positions never cross the bridge or go to Firebase.
class BartenderSceneBridge {
  BartenderSceneBridge(this.controller);

  final BartenderController controller;

  Map<String, Object?> get snapshot => {
    'round': controller.room?.currentRound?.number,
    'station': controller.myStation?.name,
    'stationName': controller.myStation?.displayName ?? 'Trạm điều phối',
    'busy': controller.isBusy || !controller.isGameplayActive,
    'active': controller.isGameplayActive,
    'preparationId': controller.isMatchPreparing
        ? controller.room!.timer!.startedAt
        : null,
    'items': [
      for (final item in controller.myItems)
        {
          'id': item.id,
          'kind': item.itemId,
          'processable':
              controller.myStation != null &&
              processItem(item.itemId, controller.myStation!) != null,
        },
    ],
    'orders': [
      for (final order in controller.myOrders)
        if (!order.isCompleted) {'id': order.id, 'product': _productFor(order)},
    ],
  };

  /// Includes only game state, so clock ticks do not resend the scene.
  String get encodedSnapshot => jsonEncode(snapshot);

  Future<bool> handle(String raw, {bool allowShake = false}) async {
    if (!controller.isGameplayActive || controller.isBusy) return false;
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return false;
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['round'] != controller.room?.currentRound?.number) {
      return false;
    }
    final itemId = decoded['id'];
    final orderId = decoded['order'];
    final items = controller.myItems.where((i) => i.id == itemId);
    if (items.isEmpty) return false; // Item left the inbox while being dragged.
    final item = items.first;
    switch (decoded['action']) {
      case 'left':
        if (controller.leftNeighbor == null) return false;
        await controller.swipeItemLeft(item);
      case 'right':
        if (controller.rightNeighbor == null) return false;
        await controller.swipeItemRight(item);
      case 'trash':
        await controller.trashItem(item);
      case 'process':
        final station = controller.myStation;
        if (station == null ||
            (station == StationType.shaker && !allowShake) ||
            processItem(item.itemId, station) == null) {
          return false;
        }
        await controller.processItemAtStation(item);
      case 'submit':
        final orders = controller.myOrders.where(
          (o) => o.id == orderId && !o.isCompleted,
        );
        if (orders.isEmpty ||
            item.type != GameItemType.product ||
            _productFor(orders.first) != item.itemId) {
          return false;
        }
        await controller.submitOrder(orders.first, item);
      default:
        return false;
    }
    return true;
  }

  static String _productFor(Order order) {
    final recipes = RecipePool.allRecipes.where((r) => r.id == order.recipeId);
    return recipes.isEmpty ? order.recipeId : recipes.first.productId;
  }
}
