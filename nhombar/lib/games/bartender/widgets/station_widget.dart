import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/game_item.dart';
import '../models/processing_rules.dart';
import '../models/station.dart';
import '../services/shake_detector.dart';

/// Hiển thị trạm chế biến được phân cho người chơi trong round hiện tại.
///
/// Xem PROJECT_SPEC.md & DECISIONS.md D5 & D6:
/// - Màn hình của mỗi người chỉ hiển thị MỘT trạm cố định cho round đó.
/// - Có thể không có trạm nào (null) — lúc này người chơi đóng vai trò điều phối/chuyền đồ.
/// - Trạm shaker sử dụng cảm biến lắc điện thoại (sensors_plus).
/// - Có nút "Lắc giả lập" khi cảm biến không khả dụng (emulator / widget test).
class StationWidget extends StatefulWidget {
  const StationWidget({
    super.key,
    required this.station,
    required this.items,
    required this.onProcessItem,
    required this.isBusy,
    this.isSensorAvailable,
    this.shakeDetector,
    this.accelerometerStream,
  });

  final StationType? station;
  final List<GameItem> items;
  final void Function(GameItem item) onProcessItem;
  final bool isBusy;

  /// Cho phép ép tính khả dụng của cảm biến trong widget test hoặc emulator.
  final bool? isSensorAvailable;

  /// ShakeDetector tùy chỉnh (hoặc inject trong test).
  final ShakeDetector? shakeDetector;

  /// Accelerometer stream tùy chỉnh (cho test).
  final Stream<UserAccelerometerEvent>? accelerometerStream;

  @override
  State<StationWidget> createState() => _StationWidgetState();
}

class _StationWidgetState extends State<StationWidget> {
  StreamSubscription<UserAccelerometerEvent>? _sensorSub;
  late final ShakeDetector _shakeDetector;
  bool _sensorAvailable = true;

  @override
  void initState() {
    super.initState();
    _shakeDetector = widget.shakeDetector ?? ShakeDetector();
    _setupSensors();
  }

  @override
  void didUpdateWidget(covariant StationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.station != widget.station ||
        oldWidget.isSensorAvailable != widget.isSensorAvailable) {
      _setupSensors();
    }
  }

  void _setupSensors() {
    _sensorSub?.cancel();
    _sensorSub = null;

    if (widget.station != StationType.shaker) return;

    if (widget.isSensorAvailable != null) {
      _sensorAvailable = widget.isSensorAvailable!;
    } else if (ShakeSensorConfig.isSensorAvailableOverride != null) {
      _sensorAvailable = ShakeSensorConfig.isSensorAvailableOverride!;
    } else {
      final binding = WidgetsBinding.instance.runtimeType.toString();
      _sensorAvailable =
          !binding.contains('Test') && !binding.contains('Automated');
    }

    if (!_sensorAvailable) return;

    final stream =
        widget.accelerometerStream ??
        ShakeSensorConfig.customStream ??
        userAccelerometerEventStream();

    _sensorSub = stream.listen(
      (event) {
        if (!mounted || widget.isBusy) return;
        final nowMs = event.timestamp.millisecondsSinceEpoch;
        final didShake = _shakeDetector.addSample(
          event.x,
          event.y,
          event.z,
          nowMs,
        );
        if (didShake) {
          final processable = widget.items
              .where(
                (item) => processItem(item.itemId, StationType.shaker) != null,
              )
              .toList();
          if (processable.isNotEmpty) {
            widget.onProcessItem(processable.first);
          }
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() {
            _sensorAvailable = false;
          });
        }
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.station == null) {
      return _buildNoStationBanner();
    }

    final currentStation = widget.station!;

    // Lọc ra các item có thể chế biến tại trạm này
    final processableItems = widget.items
        .where((item) => _canProcess(item, currentStation))
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE8BD), Color(0xFFFFD69C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFC47B39), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Color(0x3B763B15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tiêu đề trạm
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFFB9672D),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        currentStation.iconEmoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentStation.displayName.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF51250F),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Thao tác: ${currentStation.actionVerb}',
                            style: const TextStyle(
                              color: Color(0xFF91643D),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isBusy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF8C4319),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Vùng tương tác chế biến
          if (processableItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0x1E7D4518),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0x44A7642C)),
              ),
              child: Text(
                'Chưa có nguyên liệu phù hợp để ${currentStation.actionVerb.toLowerCase()}.\n'
                'Nhận hoặc xin từ đồng đội!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF91643D), fontSize: 11),
              ),
            )
          else ...[
            Text(
              'Có ${processableItems.length} món có thể ${currentStation.actionVerb.toLowerCase()}:',
              style: const TextStyle(
                color: Color(0xFF8C4319),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            if (currentStation == StationType.shaker && _sensorAvailable)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFF8DAA5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(0xFF8C4319).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.vibration,
                      color: Color(0xFF8C4319),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        '📱 Lắc điện thoại để pha chế!\n(${processableItems.map((i) => i.itemId).join(', ')})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF51250F),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (currentStation == StationType.shaker && !_sensorAvailable)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    key: const Key('simulate-shake-button'),
                    onPressed: widget.isBusy
                        ? null
                        : () => widget.onProcessItem(processableItems.first),
                    icon: const Text('🫨', style: TextStyle(fontSize: 16)),
                    label: const Text('Lắc giả lập'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      foregroundColor: Color(0xFF51250F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: processableItems.map((item) {
                  return ElevatedButton.icon(
                    onPressed: widget.isBusy
                        ? null
                        : () => widget.onProcessItem(item),
                    icon: Text(
                      currentStation.iconEmoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    label: Text('${currentStation.actionVerb} ${item.itemId}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC37B3A),
                      foregroundColor: Color(0xFFFFF2D7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoStationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFFFFE6BD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFEBA66E),
              shape: BoxShape.circle,
            ),
            child: const Text('🚫', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROUND NÀY BẠN KHÔNG CÓ TRẠM',
                  style: TextStyle(
                    color: Color(0xFF995019),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hãy điều phối và vuốt chuyền nguyên liệu cho đồng đội bên trái hoặc bên phải!',
                  style: TextStyle(color: Color(0xFF7A4A27), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canProcess(GameItem item, StationType station) {
    return processItem(item.itemId, station) != null;
  }
}
