import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../controllers/gacha_controller.dart';
import '../data/gacha_rewards.dart';
import '../models/gacha_ticket_state.dart';
import '../services/gacha_audio_service.dart';
import '../services/gacha_collection.dart';
import '../services/gacha_wallet.dart';
import '../widgets/gacha_inventory_dialog.dart';
import '../widgets/gacha_colors.dart';
import '../widgets/gacha_scene.dart';
import '../widgets/gacha_rates_dialog.dart';
import '../widgets/gacha_result_panel.dart';

class GachaScreen extends StatefulWidget {
  const GachaScreen({
    super.key,
    this.random,
    this.isActive = true,
    this.viewerBuilder,
    this.collection,
    this.wallet,
    this.simplePaperMask = false,
  });
  @visibleForTesting
  final Widget Function(ModelViewer viewer)? viewerBuilder;
  final Random? random;
  final bool isActive;
  final GachaCollection? collection;
  final GachaWallet? wallet;
  final bool simplePaperMask;
  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> with WidgetsBindingObserver {
  late final _controller = GachaController(
    collection: widget.collection ?? GachaCollection.instance,
    wallet: widget.wallet ?? GachaWallet.instance,
    random: widget.random,
  );
  final _audio = GachaAudioService();
  GachaTicketState _lastState = GachaTicketState.idle;
  String? _lastMessage;
  bool _resumed = true;
  Timer? _numberSound;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.active = widget.isActive;
    _controller.addListener(_changed);
    unawaited(_controller.initialize());
  }

  void _changed() {
    final state = _controller.state;
    if (state != _lastState && _controller.active) {
      switch (state) {
        case GachaTicketState.paperFocus:
          _audio.play(GachaSound.paperPick);
        case GachaTicketState.tearing:
          unawaited(HapticFeedback.selectionClick());
          _audio.play(GachaSound.paperRustle);
        case GachaTicketState.numberReveal:
          unawaited(HapticFeedback.lightImpact());
          _audio.play(GachaSound.paperTear);
          _numberSound?.cancel();
          _numberSound = Timer(const Duration(milliseconds: 150), () {
            if (mounted && _controller.active) {
              _audio.play(GachaSound.numberReveal);
            }
          });
        case GachaTicketState.prizeLookup:
          _audio.play(GachaSound.prizeHit);
        case GachaTicketState.result:
          unawaited(HapticFeedback.lightImpact());
          _audio.play(GachaSound.itemReveal);
        default:
          break;
      }
    }
    _lastState = state;
    if (_controller.message != null && _lastMessage != _controller.message) {
      _lastMessage = _controller.message;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _lastMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(_lastMessage!)));
        }
      });
    }
    if (_controller.message == null) _lastMessage = null;
    if (mounted) setState(() {});
  }

  void _draw() {
    unawaited(_controller.draw());
  }

  void _close() => _controller.closeResult();
  Future<void> _claim() async {
    await _controller.collect();
    if (mounted && _controller.saved) _close();
  }

  @override
  void didUpdateWidget(covariant GachaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _controller.setActive(widget.isActive && _resumed);
      if (!widget.isActive) _audio.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _controller.setActive(widget.isActive && _resumed);
    if (!_resumed) _audio.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_changed);
    _controller.dispose();
    _numberSound?.cancel();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_controller.resultVisible,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _controller.resultVisible) _close();
    },
    child: Scaffold(
      backgroundColor: GachaColors.ink,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SizedBox(
                key: const ValueKey('gacha-scene-canvas'),
                child: GachaScene(
                  state: _controller.state,
                  reward: _controller.reward,
                  result: _controller.result,
                  progress: _controller.progress,
                  tearProgress: _controller.tearProgress,
                  simplePaperMask: widget.simplePaperMask,
                  tearFromLeft: _controller.tearFromLeft,
                  canTear: _controller.canTear,
                  canDraw: _controller.canDraw,
                  onDraw: _draw,
                  onShowResult:
                      _controller.state == GachaTicketState.result &&
                          _controller.active
                      ? _controller.reopenResult
                      : null,
                  onShowInventory: _controller.active
                      ? () => showDialog<void>(
                          context: context,
                          builder: (_) => GachaInventoryDialog(
                            collection: _controller.collection,
                          ),
                        )
                      : null,
                  onShowRates: _controller.active
                      ? () => showDialog<void>(
                          context: context,
                          builder: (_) =>
                              const GachaRatesDialog(pool: gachaRewardPool),
                        )
                      : null,
                  onTear: _controller.tear,
                  onTearEnd: _controller.endTear,
                  onDisappearEnd: _controller.finishReveal,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: GachaColors.paper,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    '${_controller.wallet.balance} cá',
                    key: const ValueKey('gacha-fish-balance'),
                  ),
                ),
              ),
            ),
            if (_controller.resultVisible &&
                _controller.active &&
                _controller.result != null) ...[
              ModalBarrier(
                color: Colors.black54,
                dismissible: true,
                onDismiss: _close,
              ),
              GachaResultPanel(
                reward: _controller.result!,
                viewerBuilder: widget.viewerBuilder,
                duplicate: _controller.duplicate,
                busy: _controller.collecting,
                onClose: () => unawaited(_claim()),
                onDrawNext: _draw,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
