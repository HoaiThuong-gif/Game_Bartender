import 'package:flutter/foundation.dart';

import '../models/artifact_puzzle.dart';
import '../services/artifact_level_generator.dart';

enum ArtifactPhase { playing, opening, complete }

class ArtifactController extends ChangeNotifier {
  ArtifactController() {
    _level = _generator.generate(1);
    _state = _level.initial;
    _selected = ArtifactMechanism.belt;
    _notice = 'Mộng Sen · Chạm một chi tiết rồi kéo. Quan sát các khe ghép quanh đai gỗ.';
  }

  final _generator = ArtifactLevelGenerator();
  late ArtifactLevel _level;
  late ArtifactState _state;
  ArtifactPhase _phase = ArtifactPhase.playing;
  int _moves = 0;
  int _epoch = 1;
  int _revision = 0;
  int _rejection = 0;
  ArtifactMechanism _selected = ArtifactMechanism.ring;
  int _selectedIndex = 0;
  String _notice = 'Tìm dấu khắc nhỏ ở chân cổ vật, rồi giải vòng đầu tiên.';

  ArtifactLevel get level => _level;
  ArtifactState get state => _state;
  ArtifactPhase get phase => _phase;
  int get moves => _moves;
  int get epoch => _epoch;
  int get revision => _revision;
  ArtifactMechanism get selected => _selected;
  int get selectedIndex => _selectedIndex;
  String get notice => _notice;
  bool _noticeVisible = false;
  bool get noticeVisible => _noticeVisible;
  int _hintStep = 0;
  String _hintStage = '';

  void hint() {
    if (_phase != ArtifactPhase.playing) return;
    _noticeVisible = true;
    if (_level.puzzle.isMongSen) {
      final m = _state.mechanical;
      final stage = m[5]
          ? 6
          : m[4]
          ? 5
          : m[3]
          ? 4
          : m[2]
          ? 3
          : m[1]
          ? 2
          : m[0]
          ? 1
          : 0;
      if (_hintStage != 'mechanical:$stage') {
        _hintStage = 'mechanical:$stage';
        _hintStep = 0;
      }
      const hints = [
        [
          'Đường ghép ngang ở mặt trước chạy qua một hõm tay.',
          'Đai gỗ có khoảng trống để dịch sang phải.',
        ],
        [
          'Quan sát vai tấm má bên phải và gờ đai vừa dịch.',
          'Kéo tấm má xuống theo hai ray đứng.',
        ],
        [
          'Một chốt đồng đang ăn vào thanh gỗ bên trong.',
          'Xoay cam bằng cách kéo quanh trục; nhìn chốt nâng khỏi hốc.',
        ],
        [
          'Chốt đã nhả, nhưng vai mộng vẫn vướng đai phía trước.',
          'Đưa đai A về trái để cửa khuyết thẳng với vai D, rồi rút D ra trước.',
        ],
        [
          'Phần mộng vừa rút đã nhường đường cho thanh ngang.',
          'Tìm đầu thanh E ở phía phải và kéo ra theo ray.',
        ],
        [
          'Đầu giữ nắp đã rời khỏi hốc, nhưng tai nắp còn dưới ray.',
          'Trượt nắp về phía sau để các tai đến cửa thoát.',
        ],
        [
          'Các tai đã nằm trong cửa thoát trên ray.',
          'Chạm nắp và nhấc lên để mở khoang chứa.',
        ],
      ];
      _notice = hints[stage][_hintStep.clamp(0, 1)];
      _hintStep = 1;
      notifyListeners();
      return;
    }
    if (_level.puzzle.isCraft) {
      final puzzle = _level.puzzle;
      final opening = puzzle.actions(_state).where((a) => a.direction == 1);
      final next = opening.isNotEmpty
          ? opening.last
          : const ArtifactAction(ArtifactMechanism.piece, 0, -1);
      _notice =
          puzzle.level == 5 &&
              _state.mechanical[2] &&
              !_state.mechanical[3] &&
              _state.mechanical[0]
          ? 'Cam đã nhả chốt nhưng vai thanh dọc còn vướng khóa. Đưa khóa hồi vị trở lại trái.'
          : puzzle.joints[next.index].hint;
      notifyListeners();
      return;
    }
    final i = _state.sliders.indexOf(false);
    final stage =
        '${_state.sliders}:${_state.parts}:${i >= 0 && _state.rings[i] == _level.puzzle.targets[i]}';
    if (stage != _hintStage) {
      _hintStage = stage;
      _hintStep = 0;
    }
    late List<String> hints;
    if (i >= 0 && _state.rings[i] != _level.puzzle.targets[i]) {
      hints = [
        i == 0
            ? 'Quan sát dấu khắc nhỏ ở chân cổ vật.'
            : 'Quan sát chỗ vừa được chốt $i để lộ.',
        'Dấu khắc mang số ${i + 1} thuộc vòng ${i + 1}.',
        'Xoay vòng ${i + 1} để ký hiệu trùng dấu khắc nằm dưới mũi chỉ.',
      ];
    } else if (i >= 0) {
      hints = [
        'Vòng ${i + 1} đã khớp, nhưng cơ cấu vẫn cần tháo bằng tay.',
        'Chọn chốt ${i + 1}; chú ý chiều mũi tên trên rãnh.',
        'Kéo chốt ${i + 1} theo rãnh đến cuối hành trình để lộ bước kế tiếp.',
      ];
    } else if (!_state.parts[0]) {
      hints = [
        'Các chốt đã rút. Quan sát ngàm giữ nắp.',
        'Ngàm cạnh hoặc đai phía trên có thể xoay quanh trục riêng.',
        'Chọn ngàm và xoay một phần tư vòng để nhả nắp.',
      ];
    } else if (!_state.parts[1]) {
      hints = [
        'Nắp đã được nhả nhưng vẫn còn trên thân.',
        _level.puzzle.shape == ArtifactShape.hexagonalPrism
            ? 'Nắp lục giác trượt ngang theo ray.'
            : 'Nắp có thể nhấc thẳng lên.',
        'Chọn nắp, kéo theo mũi tên hoặc dùng nút Tháo bên dưới.',
      ];
    } else {
      hints = [
        'Bên trong còn một bộ phận chưa lấy ra.',
        'Nhìn qua miệng cổ vật để tìm lõi ngọc.',
        'Chọn lõi và kéo lên theo trục đứng.',
      ];
    }
    _notice = 'Gợi ý ${(_hintStep % 3) + 1}: ${hints[_hintStep % 3]}';
    _hintStep = (_hintStep + 1).clamp(0, 2);
    notifyListeners();
  }

  void select(ArtifactMechanism mechanism, int index) {
    _noticeVisible = false;
    if (_level.puzzle.isMongSen) {
      if (index != 0 ||
          !ArtifactPuzzle.mechanicalKinds.contains(mechanism) ||
          _phase != ArtifactPhase.playing) {
        return;
      }
      _selected = mechanism;
      _selectedIndex = index;
      _notice =
          '${_level.puzzle.label(mechanism, index)} · ${switch (mechanism) {
            ArtifactMechanism.cam => 'Kéo quanh trục để xoay cam.',
            ArtifactMechanism.panel => 'Kéo theo ray đứng.',
            ArtifactMechanism.longTenon => 'Kéo dọc thanh về phía trước hộp.',
            ArtifactMechanism.capLift => 'Kéo nắp lên khỏi ray.',
            ArtifactMechanism.capSlide => 'Kéo nắp dọc hai ray.',
            _ => 'Kéo theo khe ghép ngang.',
          }}';
      notifyListeners();
      return;
    }
    if (_level.puzzle.isCraft) {
      if (mechanism != ArtifactMechanism.piece ||
          index < 0 ||
          index >= _level.puzzle.joints.length ||
          _phase != ArtifactPhase.playing) {
        return;
      }
      _selected = mechanism;
      _selectedIndex = index;
      final joint = _level.puzzle.joints[index];
      _notice =
          '${joint.label} · ${joint.rotation ? 'Kéo quanh trục để xoay.' : 'Kéo dọc khe ghép; kéo ngược để lắp lại.'}';
      notifyListeners();
      return;
    }
    final count = mechanism == ArtifactMechanism.ring
        ? _state.rings.length
        : mechanism == ArtifactMechanism.slider
        ? _state.sliders.length
        : 1;
    if (index < 0 || index >= count || _phase != ArtifactPhase.playing) return;
    _selected = mechanism;
    _selectedIndex = index;
    _notice = switch (mechanism) {
      ArtifactMechanism.ring =>
        'Xoay vòng ${index + 1} theo dấu khắc tương ứng.',
      ArtifactMechanism.slider =>
        'Kéo chốt ${index + 1} theo mũi tên; đẩy ngược để lắp lại.',
      ArtifactMechanism.joint => 'Xoay ngàm quanh trục để nhả nắp.',
      ArtifactMechanism.lid =>
        _level.puzzle.shape == ArtifactShape.hexagonalPrism
            ? 'Trượt nắp sang phải theo ray.'
            : 'Nhấc nắp thẳng lên.',
      ArtifactMechanism.core => 'Kéo lõi lên qua miệng cổ vật.',
      _ => '',
    };
    notifyListeners();
  }

  bool move(ArtifactAction action) {
    if (_phase != ArtifactPhase.playing) return false;
    final rejection = _level.puzzle.rejection(_state, action);
    if (rejection != null) {
      _rejection++;
      _noticeVisible = true;
      _notice = rejection;
      notifyListeners();
      return false;
    }
    _noticeVisible = false;
    _state = _level.puzzle.apply(_state, action)!;
    _moves++;
    _revision++;
    _selected = action.mechanism;
    _selectedIndex = action.index;
    if (_level.puzzle.isSolved(_state)) {
      _phase = ArtifactPhase.opening;
      _noticeVisible = true;
      _notice = _level.puzzle.isMongSen
          ? 'Nắp đang rời khỏi ray. Khoang bí mật đã mở…'
          : 'Bạn đang lấy lõi ra khỏi cổ vật…';
    } else if (_level.puzzle.isCraft) {
      _notice =
          'Đã dịch chuyển ${_level.puzzle.label(action.mechanism, action.index).toLowerCase()}. Quan sát cơ cấu vừa lộ ra.';
    } else if (_level.puzzle.isMongSen) {
      _notice =
          'Đã dịch chuyển ${_level.puzzle.label(action.mechanism, 0).toLowerCase()}. Quan sát cấu tạo vừa thay đổi.';
    } else if (action.mechanism == ArtifactMechanism.slider &&
        action.direction == 1) {
      _notice = action.index + 1 < _state.sliders.length
          ? 'Chốt đã rút: dấu khắc ${action.index + 2} vừa lộ. Quan sát rồi giải vòng tiếp theo.'
          : 'Các chốt đã rút. Tự xoay ngàm để nhả nắp.';
    } else if (_state.parts[1]) {
      _notice = 'Nắp đã tháo. Quan sát miệng cổ vật và kéo lõi ra.';
    } else if (_state.parts[0]) {
      _notice = 'Ngàm đã nhả. Chọn nắp và tháo theo hướng mũi tên.';
    } else {
      _notice = 'Quan sát dấu khắc và tháo lần lượt từng cơ cấu.';
    }
    notifyListeners();
    return true;
  }

  void complete(int epoch, int revision) {
    if (epoch != _epoch ||
        revision != _revision ||
        _phase != ArtifactPhase.opening) {
      return;
    }
    _phase = ArtifactPhase.complete;
    _noticeVisible = true;
    _notice = _level.puzzle.isMongSen
        ? 'Bạn đã mở Mộng Sen bằng cách tháo các mộng khóa.'
        : 'Bạn đã khám phá lõi bí mật.';
    notifyListeners();
  }

  void reset() {
    _state = _level.initial;
    _restart();
  }

  void nextLevel() {
    if (_phase != ArtifactPhase.complete) return;
    if (_level.puzzle.level >= 5) return;
    _level = _generator.generate(_level.puzzle.level + 1);
    _state = _level.initial;
    _restart();
  }

  void _restart() {
    _noticeVisible = false;
    _hintStep = 0;
    _hintStage = '';
    _moves = 0;
    _epoch++;
    _revision = 0;
    _rejection = 0;
    _phase = ArtifactPhase.playing;
    _selected = _level.puzzle.isMongSen
        ? ArtifactMechanism.belt
        : _level.puzzle.isCraft
        ? ArtifactMechanism.piece
        : ArtifactMechanism.ring;
    _selectedIndex = 0;
    _notice = _level.puzzle.isMongSen
        ? 'Mộng Sen · Chạm một chi tiết rồi kéo. Quan sát các khe ghép quanh đai gỗ.'
        : '${_level.puzzle.title} · Quan sát các khe ghép và thử dịch chuyển từng chi tiết.';
    notifyListeners();
  }

  Map<String, Object> get snapshot => {
    ..._level.puzzle.toJson(),
    'state': _state.toJson(),
    'epoch': _epoch,
    'revision': _revision,
    'rejection': _rejection,
    'phase': _phase.name,
    'legalActions': [
      for (final action in _level.puzzle.actions(_state)) action.toJson(),
    ],
    'selected': {'kind': _selected.name, 'index': _selectedIndex},
  };
}
