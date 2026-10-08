import 'dart:math';

import 'package:flutter/material.dart';

import '../data/gacha_rewards.dart';
import '../models/gacha_reward.dart';
import '../models/gacha_ticket_state.dart';
import 'gacha_colors.dart';
import 'reward_board.dart';
import 'reward_icon.dart';
import 'tear_ticket.dart';

/// Sizes are relative to the available content above the navigation bar.
class GachaScene extends StatelessWidget {
  const GachaScene({
    super.key,
    required this.state,
    required this.reward,
    required this.result,
    required this.progress,
    this.tearProgress,
    this.simplePaperMask = false,
    required this.tearFromLeft,
    required this.canTear,
    required this.canDraw,
    required this.onDraw,
    this.onShowRates,
    this.onShowResult,
    this.onShowInventory,
    required this.onTear,
    required this.onTearEnd,
    required this.onDisappearEnd,
  });

  final GachaTicketState state;
  final GachaReward? reward;
  final GachaReward? result;
  final double progress;
  final ValueNotifier<double>? tearProgress;
  final bool simplePaperMask;
  final bool tearFromLeft;
  final bool canTear;
  final bool canDraw;
  final VoidCallback onDraw;
  final VoidCallback? onShowRates;
  final VoidCallback? onShowResult;
  final VoidCallback? onShowInventory;
  final ValueChanged<double> onTear;
  final VoidCallback onTearEnd;
  final VoidCallback onDisappearEnd;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final viewportWidth = constraints.maxWidth;
      final viewportHeight = constraints.maxHeight;
      // Only the interactive composition fits the viewport. The background
      // and counter fill the screen independently of this content width.
      final w = min(viewportWidth, viewportHeight / 2.17);
      final h = w * 2.17;
      final contentLeft = (viewportWidth - w) / 2;
      final contentTop = (viewportHeight - h) / 2;
      final boardWidth = w * .60;
      final boardHeight = boardWidth * 1402 / 1122;
      // Match the background's centered cover crop so the board's hanging hooks
      // stay below the lamp across aspect ratios, including letterboxed content.
      final backgroundScale = max(viewportWidth / 941, viewportHeight / 1672);
      final backgroundTop = (viewportHeight - 1672 * backgroundScale) / 2;
      final lampBottom = backgroundTop + 275 * backgroundScale;
      final boardTop = max(h * .145, lampBottom - contentTop + h * .003);
      final sideWidth = w * .16;
      final sideHeight = sideWidth * 1536 / 1024;
      final sideGap = w * .034;
      final boxWidth = w * .42;
      final priceWidth = w * .30;
      // Keep the box and price at their existing positions when moving the board.
      final counterArtTop = h * .17 + boardHeight + h * .012;
      final guideHeight = h * .038;
      final guideTop = h * .724;
      // Paper uses the viewport, independently of the fitted shop composition.
      final ticketWidth = min(viewportWidth * .82, viewportHeight * .72 * 1.4);
      final ticketHeight = ticketWidth / 1.4;
      final lookingUp =
          state == GachaTicketState.prizeLookup ||
          state == GachaTicketState.itemReveal;

      Widget at(
        String key,
        double left,
        double top,
        double width,
        double height,
        Widget child,
      ) => Positioned(
        left: contentLeft + left,
        top: contentTop + top,
        width: width,
        height: height,
        child: SizedBox(key: ValueKey(key), child: child),
      );
      Widget art(String name) => Image.asset(
        'assets/images/gacha/ui/$name.png',
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      );
      final opened =
          state == GachaTicketState.revealed ||
          state == GachaTicketState.highlighting ||
          state == GachaTicketState.disappearing;
      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/gacha/ui/background.png',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          Positioned(
            left: contentLeft,
            top: contentTop,
            width: w,
            height: h,
            child: const IgnorePointer(
              child: SizedBox(key: ValueKey('gacha-content-bounds')),
            ),
          ),
          // Reuse the existing counter art at its native ratio. Its transparent
          // upper 480 px let the wall and lamp remain visible; the tabletop starts
          // at 58% of the content height, directly behind the ticket and price.
          at(
            'gacha-counter',
            -viewportWidth * .50 - contentLeft,
            h * .58 - viewportWidth * 2 * 480 / 1448,
            viewportWidth * 2,
            viewportWidth * 2 * 1086 / 1448,
            art('ban'),
          ),
          at(
            'gacha-board',
            w * .25,
            boardTop,
            boardWidth,
            boardHeight,
            RewardBoard(
              rewards: gachaRewards,
              selectedNumber: state == GachaTicketState.revealed
                  ? null
                  : result?.number,
              emphasizeSelection: state == GachaTicketState.highlighting,
            ),
          ),
          at(
            'gacha-ticket-box',
            w * .01,
            counterArtTop - (boxWidth - w * .28) * 1024 / 1536,
            boxWidth,
            boxWidth * 1024 / 1536,
            Semantics(
              button: true,
              enabled: canDraw,
              label: 'Chạm hộp để bốc 1 gói – 100 cá',
              child: GestureDetector(
                key: const ValueKey('gacha-draw-button'),
                behavior: HitTestBehavior.opaque,
                onTap: canDraw ? onDraw : null,
                child: Opacity(
                  opacity: canDraw ? 1 : .55,
                  child: art('hop_phieu'),
                ),
              ),
            ),
          ),
          at(
            'gacha-price',
            w * .69,
            counterArtTop,
            priceWidth,
            priceWidth * 1024 / 1536,
            art('bang_gia'),
          ),
          if (reward != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: lookingUp ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: const ColoredBox(color: Color(0x38000000)),
                ),
              ),
            ),
          if (reward != null)
            AnimatedPositioned(
              key: const ValueKey('gacha-ticket-area'),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              left: (viewportWidth - ticketWidth) / 2,
              top:
                  (lookingUp
                      ? min(
                          viewportHeight * .76,
                          viewportHeight * .96 - ticketHeight * .41,
                        )
                      : viewportHeight * .50) -
                  ticketHeight / 2,
              width: ticketWidth,
              height: ticketHeight,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                builder: (_, value, child) => Transform.translate(
                  offset: Offset(
                    -w * .25 * (1 - value),
                    -h * .08 * (1 - value),
                  ),
                  child: Transform.scale(
                    scale: .65 + .35 * value,
                    child: Opacity(opacity: value, child: child),
                  ),
                ),
                child: RepaintBoundary(
                  child: IgnorePointer(
                    ignoring: !canTear,
                    child: AnimatedOpacity(
                      opacity: state == GachaTicketState.disappearing ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      onEnd: onDisappearEnd,
                      child: AnimatedScale(
                        scale: state == GachaTicketState.disappearing
                            ? .72
                            : lookingUp
                            ? .82
                            : state == GachaTicketState.tearing
                            ? 1.015
                            : 1,
                        duration: const Duration(milliseconds: 300),
                        child: TearTicket(
                          reward: reward!,
                          progress: progress,
                          progressListenable: tearProgress,
                          simpleMask: simplePaperMask,
                          revealed: opened,
                          tearFromLeft: tearFromLeft,
                          onDrag: onTear,
                          onDragEnd: onTearEnd,
                          enabled: canTear,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          at(
            'gacha-rates',
            w * .79,
            h * .22,
            sideWidth,
            sideHeight,
            Semantics(
              label: 'Tỷ lệ',
              button: true,
              enabled: onShowRates != null,
              child: GestureDetector(
                key: const ValueKey('gacha-rates-button'),
                behavior: HitTestBehavior.opaque,
                onTap: onShowRates,
                child: art('nut_ty_le'),
              ),
            ),
          ),
          at(
            'gacha-inventory',
            w * .79,
            h * .22 + sideHeight + sideGap,
            sideWidth,
            sideHeight,
            Semantics(
              label: 'Tủ đồ',
              button: true,
              enabled: onShowInventory != null,
              child: GestureDetector(
                key: const ValueKey('gacha-inventory-button'),
                behavior: HitTestBehavior.opaque,
                onTap: onShowInventory,
                child: art('nut_tu_do'),
              ),
            ),
          ),
          at(
            'gacha-guidance',
            w * .06,
            guideTop,
            w * .88,
            guideHeight,
            GestureDetector(
              key: const ValueKey('gacha-show-result'),
              onTap: onShowResult,
              child: Semantics(
                liveRegion: true,
                child:
                    result != null &&
                        (state == GachaTicketState.itemReveal ||
                            state == GachaTicketState.result)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RewardIcon(
                            key: const ValueKey('gacha-revealed-icon'),
                            reward: result!,
                            size: guideHeight,
                          ),
                          SizedBox(width: w * .02),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Số ${result!.displayNumber} · ${result!.name}',
                                style: TextStyle(
                                  color: GachaColors.paper,
                                  fontSize: w * .041,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          switch (state) {
                            GachaTicketState.idle => 'Chạm vào hộp để bốc giấy',
                            GachaTicketState.selecting ||
                            GachaTicketState.paperFocus => 'Đang bốc giấy…',
                            GachaTicketState.numberReveal =>
                              'Số ${result?.displayNumber ?? ''}',
                            GachaTicketState.prizeLookup =>
                              'Dò số ${result?.displayNumber ?? ''} trên bảng…',
                            _ => 'Vuốt ngang để xé',
                          },
                          style: TextStyle(
                            color: GachaColors.paper,
                            fontSize: w * .041,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
