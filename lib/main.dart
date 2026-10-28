import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

void main() {
  runApp(const CozyCatApp());
}

class CozyCatApp extends StatelessWidget {
  const CozyCatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

// ============================================================
// CAT STATE
// ============================================================

enum CatState {
  idle,
  lookAround,
  walk,
}

// ============================================================
// GAME SCREEN
// ============================================================

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // ==========================================================
  // SCENE
  // ==========================================================

  final Scene _scene = Scene();

  late final PerspectiveCamera _camera;

  Node? _cat;

  AnimationClip? _currentClip;

  // ==========================================================
  // CAT AI
  // ==========================================================

  CatState _catState = CatState.idle;

  final Random _random = Random();

  Timer? _behaviorTimer;

  Timer? _movementTimer;

  // Vị trí hiện tại của mèo trên trục X.
  double _catX = 0;

  // Điểm mèo muốn đi tới.
  double _targetX = 0;

  // Giới hạn khu vực mèo được đi.
  final double _minX = -12;
  final double _maxX = 12;

  // Tốc độ di chuyển.
  final double _walkSpeed = 0.12;

  // ==========================================================
  // APP STATE
  // ==========================================================

  bool _loading = true;

  String? _error;

  @override
  void initState() {
    super.initState();

    // Camera nhìn vào mặt mèo.
    _camera = PerspectiveCamera(
      position: vm.Vector3(
        0,
        20,
        -50,
      ),
      target: vm.Vector3(
        0,
        5,
        0,
      ),
      fovNear: 0.1,
      fovFar: 1000.0,
    );

    _loadGame();
  }

  // ==========================================================
  // LOAD GAME
  // ==========================================================

  Future<void> _loadGame() async {
    try {
      await Scene.initializeStaticResources();

      // Load mèo bằng asset pipeline.
      final cat = await loadScene(
        'assets/models/cat/cat.glb',
      );

      cat.position.setValues(
        0,
        0,
        0,
      );

      _cat = cat;

      _scene.add(cat);

      // Bắt đầu bằng Idle.
      _playAnimation(
        'Idle',
      );

      debugPrint('================================');
      debugPrint('CAT LOADED');
      debugPrint('Prototype 1 started');
      debugPrint('Initial state: IDLE');
      debugPrint('================================');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _catState = CatState.idle;
      });

      // Cho mèo bắt đầu tự hành động.
      _scheduleNextBehavior();
    } catch (e, stackTrace) {
      debugPrint('================================');
      debugPrint('LOAD GAME ERROR');
      debugPrint('$e');
      debugPrint('================================');

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ==========================================================
  // PLAY ANIMATION
  // ==========================================================

  void _playAnimation(
      String animationName,
      ) {
    final cat = _cat;

    if (cat == null) return;

    final animation = cat.findAnimationByName(
      animationName,
    );

    if (animation == null) {
      debugPrint(
        'Animation not found: $animationName',
      );

      return;
    }

    // Dừng animation cũ.
    _currentClip?.stop();

    // Tạo animation mới.
    final clip = cat.createAnimationClip(
      animation,
    );

    clip.loop = true;

    clip.playbackTimeScale = 1.0;

    clip.play();

    _currentClip = clip;

    debugPrint(
      'Animation -> $animationName',
    );
  }

  // ==========================================================
  // SCHEDULE NEXT BEHAVIOR
  // ==========================================================

  void _scheduleNextBehavior() {
    _behaviorTimer?.cancel();

    // Mỗi trạng thái tồn tại khoảng 2–5 giây.
    final seconds = 2 + _random.nextInt(4);

    debugPrint(
      'Next behavior in $seconds seconds',
    );

    _behaviorTimer = Timer(
      Duration(seconds: seconds),
          () {
        if (!mounted) return;

        _chooseNextBehavior();
      },
    );
  }

  // ==========================================================
  // CHOOSE NEXT BEHAVIOR
  // ==========================================================

  void _chooseNextBehavior() {
    if (_catState == CatState.walk) {
      return;
    }

    // 0 hoặc 1.
    final choice = _random.nextInt(2);

    if (choice == 0) {
      _startLookAround();
    } else {
      _startWalking();
    }
  }

  // ==========================================================
  // IDLE
  // ==========================================================

  void _startIdle() {
    _movementTimer?.cancel();

    if (!mounted) return;

    setState(() {
      _catState = CatState.idle;
    });

    _playAnimation(
      'Idle',
    );

    debugPrint('CAT STATE -> IDLE');

    _scheduleNextBehavior();
  }

  // ==========================================================
  // LOOK AROUND
  // ==========================================================

  void _startLookAround() {
    _movementTimer?.cancel();

    if (!mounted) return;

    setState(() {
      _catState = CatState.lookAround;
    });

    _playAnimation(
      'IdleLookAround',
    );

    debugPrint(
      'CAT STATE -> LOOK AROUND',
    );

    // Nhìn xung quanh khoảng 2–4 giây.
    final seconds = 2 + _random.nextInt(3);

    _behaviorTimer?.cancel();

    _behaviorTimer = Timer(
      Duration(seconds: seconds),
          () {
        if (!mounted) return;

        _startIdle();
      },
    );
  }

  // ==========================================================
  // WALK
  // ==========================================================

  void _startWalking() {
    final cat = _cat;

    if (cat == null) return;

    _behaviorTimer?.cancel();
    _movementTimer?.cancel();

    // Chọn điểm X ngẫu nhiên.
    _targetX =
        _minX +
            _random.nextDouble() *
                (_maxX - _minX);

    // Không cho target quá gần vị trí hiện tại.
    if ((_targetX - _catX).abs() < 4) {
      if (_catX <= 0) {
        _targetX = min(
          _catX + 6,
          _maxX,
        );
      } else {
        _targetX = max(
          _catX - 6,
          _minX,
        );
      }
    }

    setState(() {
      _catState = CatState.walk;
    });

    _playAnimation(
      'WalkAttempt2',
    );

    debugPrint('==============================');
    debugPrint('CAT STATE -> WALK');
    debugPrint(
      'Current X: ${_catX.toStringAsFixed(2)}',
    );
    debugPrint(
      'Target X: ${_targetX.toStringAsFixed(2)}',
    );
    debugPrint('==============================');

    // Khoảng 60 FPS.
    _movementTimer = Timer.periodic(
      const Duration(
        milliseconds: 16,
      ),
          (timer) {
        final cat = _cat;

        if (cat == null || !mounted) {
          timer.cancel();
          return;
        }

        final distance =
            _targetX - _catX;

        // ================================
        // ĐÃ TỚI ĐÍCH
        // ================================

        if (distance.abs() <= _walkSpeed) {
          _catX = _targetX;

          cat.position.setValues(
            _catX,
            0,
            0,
          );

          timer.cancel();

          debugPrint(
            'Cat reached target: '
                '${_catX.toStringAsFixed(2)}',
          );

          _startIdle();

          return;
        }

        // ================================
        // DI CHUYỂN
        // ================================

        if (distance > 0) {
          // Đi sang phải.
          _catX += _walkSpeed;
        } else {
          // Đi sang trái.
          _catX -= _walkSpeed;
        }

        cat.position.setValues(
          _catX,
          0,
          0,
        );
      },
    );
  }

  // ==========================================================
  // STATE TEXT
  // ==========================================================

  String get _stateText {
    switch (_catState) {
      case CatState.idle:
        return 'Idle';

      case CatState.lookAround:
        return 'Looking Around';

      case CatState.walk:
        return 'Walking';
    }
  }

  // ==========================================================
  // STATE ICON
  // ==========================================================

  IconData get _stateIcon {
    switch (_catState) {
      case CatState.idle:
        return Icons.pets;

      case CatState.lookAround:
        return Icons.visibility;

      case CatState.walk:
        return Icons.directions_walk;
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _behaviorTimer?.cancel();

    _movementTimer?.cancel();

    _currentClip?.stop();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    // ========================================================
    // LOADING
    // ========================================================

    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),

              SizedBox(
                height: 16,
              ),

              Text(
                'Loading Chubby Cat...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ========================================================
    // ERROR
    // ========================================================

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(
              20,
            ),
            child: SingleChildScrollView(
              child: Text(
                'Không load được mèo 😭\n\n$_error',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ========================================================
    // GAME
    // ========================================================

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ==============================
          // 3D SCENE
          // ==============================

          Positioned.fill(
            child: SceneView(
              _scene,
              camera: _camera,
            ),
          ),

          // ==============================
          // DEBUG STATE
          // ==============================

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(
                  top: 16,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius:
                  BorderRadius.circular(
                    24,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _stateIcon,
                      size: 18,
                      color: Colors.white,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Text(
                      'Cat: $_stateText',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}