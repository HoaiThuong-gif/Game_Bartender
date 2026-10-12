import 'dart:math';

import 'package:flutter/material.dart';

import '../models/gacha_reward.dart';
import 'gacha_colors.dart';
import 'paper_tear_mask.dart';

/// The cover stays registered to the base. Only its torn mask advances.
class TearTicket extends StatefulWidget {
  const TearTicket({
    super.key,
    required this.reward,
    required double progress,
    required this.revealed,
    required this.tearFromLeft,
    required this.onDrag,
    required this.onDragEnd,
    this.enabled = true,
    this.progressListenable,
    this.simpleMask = false,
    // Keep the public `progress:` API while exposing the live notifier value.
    // ignore: prefer_initializing_formals
  }) : _progress = progress;
  final GachaReward reward;
  final double _progress;
  double get progress => progressListenable?.value ?? _progress;
  final ValueNotifier<double>? progressListenable;
  final bool revealed;
  final bool tearFromLeft;
  final bool enabled;
  final bool simpleMask;
  final ValueChanged<double> onDrag;
  final VoidCallback onDragEnd;
  static const numberRevealDuration = Duration(milliseconds: 500);
  @override
  State<TearTicket> createState() => _TearTicketState();
}

class _TearTicketState extends State<TearTicket>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: TearTicket.numberRevealDuration,
  );
  double _fingerY = .5;
  double _completeFrom = .65;
  final _frontier = List<double>.filled(25, 0);

  PaperTearGeometry _geometry(double progress, double completion, bool simple) {
    final candidate = PaperTearGeometry(
      progress: widget.revealed ? _completeFrom : progress,
      fromLeft: true,
      fingerY: _fingerY,
      simple: simple,
    ).edge(const Size(1, 1));
    for (var i = 0; i < 25; i++) {
      _frontier[i] = max(_frontier[i], candidate[i].dx);
    }
    // Fixed memory: retain the furthest cut per row, including vertical motion.
    final t = widget.revealed ? Curves.easeOut.transform(completion) : 0.0;
    return PaperTearGeometry(
      progress: progress,
      fromLeft: widget.tearFromLeft,
      fingerY: _fingerY,
      simple: simple,
      frontier: List.generate(
        25,
        (i) => _frontier[i] + (1 - _frontier[i]) * t,
        growable: false,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.progressListenable?.addListener(_progressChanged);
    if (widget.revealed) _reveal.forward();
  }

  void _progressChanged() {
    if (mounted && !widget.revealed) setState(() {});
  }

  @override
  void didUpdateWidget(covariant TearTicket oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progressListenable != oldWidget.progressListenable) {
      oldWidget.progressListenable?.removeListener(_progressChanged);
      widget.progressListenable?.addListener(_progressChanged);
    }
    if (widget.revealed && !oldWidget.revealed) {
      _completeFrom = min(widget.progress, .65);
      _reveal.forward(from: 0);
    }
    if (!widget.revealed && oldWidget.revealed) {
      _reveal.reset();
      _fingerY = .5;
      _frontier.fillRange(0, 25, 0);
    }
  }

  @override
  void dispose() {
    widget.progressListenable?.removeListener(_progressChanged);
    _reveal.dispose();
    super.dispose();
  }

  // Both layers use precisely the same artwork/frame and registration.
  Widget _paperFrame(double width) => ClipRect(
    child: OverflowBox(
      alignment: const Alignment(-1, 0),
      minHeight: width,
      maxHeight: width,
      minWidth: width * 3,
      maxWidth: width * 3,
      child: Image.asset(
        'assets/images/gacha/ui/giay_gacha.png',
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = width / 1.4;
      final direction = widget.tearFromLeft ? 1.0 : -1.0;
      final dragging = widget.enabled && !widget.revealed;
      return Semantics(
        label: widget.revealed
            ? 'Phiếu đã mở, số ${widget.reward.displayNumber}'
            : 'Kéo ngang để xé giấy, thả tay để nghỉ rồi xé tiếp.',
        child: GestureDetector(
          key: const ValueKey('gacha-ticket-drag'),
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: dragging
              ? (details) {
                  _fingerY = (details.localPosition.dy / height).clamp(
                    0.0,
                    1.0,
                  );
                }
              : null,
          onHorizontalDragUpdate: dragging
              ? (details) {
                  final y = (details.localPosition.dy / height).clamp(0.0, 1.0);
                  // Downsample local edge motion at four logical pixels.
                  if ((y - _fingerY).abs() * height >= 4) {
                    setState(() => _fingerY = y);
                  }
                  widget.onDrag(details.delta.dx / width);
                }
              : null,
          onHorizontalDragEnd: dragging ? (_) => widget.onDragEnd() : null,
          onHorizontalDragCancel: dragging ? widget.onDragEnd : null,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _reveal,
              builder: (context, _) {
                final elapsed = _reveal.value * 500;
                final completion = (elapsed / 250).clamp(0.0, 1.0);
                final number = (elapsed / 100).clamp(0.0, 1.0);
                final maskProgress = widget.revealed
                    ? _completeFrom +
                          (1 - _completeFrom) *
                              Curves.easeOut.transform(completion)
                    : widget.progress.clamp(0.0, .65);
                final geometry = _geometry(
                  maskProgress,
                  completion,
                  widget.simpleMask || MediaQuery.disableAnimationsOf(context),
                );
                return AspectRatio(
                  aspectRatio: 1.4,
                  child: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
                      const CustomPaint(painter: _PaperShadowPainter()),
                      _paperFrame(width),
                      const CustomPaint(painter: _PaperBackingPainter()),
                      Center(
                        child: Opacity(
                          key: const ValueKey('gacha-number-reveal'),
                          // Before completion the mask alone hides/reveals the number.
                          opacity: widget.revealed ? .85 + .15 * number : 1,
                          child: Transform.scale(
                            scale: widget.revealed
                                ? .7 + .3 * Curves.easeOutBack.transform(number)
                                : 1,
                            child: FractionallySizedBox(
                              widthFactor: .32,
                              heightFactor: .24,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: GachaColors.paper,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    widget.reward.displayNumber,
                                    style: TextStyle(
                                      fontSize: width * .18,
                                      fontWeight: FontWeight.w800,
                                      color: GachaColors.brick,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!widget.revealed || completion < 1) ...[
                        ClipPath(
                          key: const ValueKey('gacha-paper-cover'),
                          clipper: PaperTearClipper(geometry),
                          clipBehavior: Clip.antiAlias,
                          child: _paperFrame(width),
                        ),
                        CustomPaint(
                          key: const ValueKey('gacha-tear-edge'),
                          painter: PaperTearEdgePainter(geometry),
                        ),
                      ],
                      if (widget.revealed && elapsed < 450)
                        for (var index = 0; index < 4; index++)
                          _scrap(
                            index,
                            width,
                            height,
                            direction,
                            (elapsed / 450).clamp(0.0, 1.0),
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );

  Widget _scrap(
    int index,
    double width,
    double height,
    double direction,
    double t,
  ) => Positioned(
    left:
        width *
            (.3 +
                index * .1 +
                sin(widget.reward.number * 37 + index * 11) * .025) +
        direction * width * t * (.15 + index * .06),
    top:
        height * .35 -
        height * sin(t * pi) * (.12 + index * .025) +
        height * t * t * .6,
    child: Opacity(
      opacity: 1 - t,
      child: Transform.rotate(
        angle: direction * (index + 1) * t * 1.3,
        child: ClipPath(
          clipper: _ScrapClipper(index),
          child: ColoredBox(
            key: ValueKey('gacha-paper-scrap-$index'),
            color: index.isEven ? GachaColors.paper : const Color(0xFFD7AA79),
            child: SizedBox(
              width: width * (.035 + index * .005),
              height: height * .055,
            ),
          ),
        ),
      ),
    ),
  );
}

/// A cheap shadow of the visible paper, without blurring the whole scene.
class _PaperShadowPainter extends CustomPainter {
  const _PaperShadowPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .13, size.height * .20)
      ..lineTo(size.width * .86, size.height * .19)
      ..lineTo(size.width * .87, size.height * .85)
      ..lineTo(size.width * .14, size.height * .84)
      ..close();
    canvas.drawShadow(path, const Color(0x66000000), size.width * .018, false);
  }

  @override
  bool shouldRepaint(_PaperShadowPainter oldDelegate) => false;
}

class _ScrapClipper extends CustomClipper<Path> {
  const _ScrapClipper(this.index);
  final int index;
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, size.height * .25)
    ..lineTo(size.width * (.55 + index * .08), 0)
    ..lineTo(size.width, size.height * (.65 + index * .07))
    ..lineTo(size.width * .2, size.height)
    ..close();
  @override
  bool shouldReclip(_ScrapClipper oldClipper) => oldClipper.index != index;
}

/// Blank fibres beneath the printed cover, aligned to this sprite's margins.
class _PaperBackingPainter extends CustomPainter {
  const _PaperBackingPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final inset = Path()
      ..moveTo(size.width * .17, size.height * .24)
      ..lineTo(size.width * .82, size.height * .23)
      ..lineTo(size.width * .84, size.height * .80)
      ..lineTo(size.width * .18, size.height * .79)
      ..close();
    canvas.drawPath(inset, Paint()..color = const Color(0xFFEED8AF));
    final fibre = Paint()
      ..color = const Color(0x168A6542)
      ..strokeWidth = .7;
    for (var i = 0; i < 12; i++) {
      final y = size.height * (.28 + i * .04);
      final x = size.width * (.21 + sin(i * 3.1) * .025);
      canvas.drawLine(
        Offset(x, y),
        Offset(size.width * .78, y + sin(i) * 1.5),
        fibre,
      );
    }
  }

  @override
  bool shouldRepaint(_PaperBackingPainter oldDelegate) => false;
}
