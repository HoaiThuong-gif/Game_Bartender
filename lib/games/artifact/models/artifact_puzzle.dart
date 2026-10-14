enum ArtifactShape {
  cube('Hộp mộc'),
  cylinder('Ống tre đồng'),
  hexagonalPrism('Ấn lục giác');

  const ArtifactShape(this.label);
  final String label;
}

enum ArtifactMechanism {
  ring,
  slider,
  joint,
  lid,
  core,
  belt,
  panel,
  cam,
  longTenon,
  crossTenon,
  capSlide,
  capLift,
  piece,
}

// A physical joint has a bounded axis, occupied gates and a reverse assembly
// guard. Indices refer to separate meshes, never to an automatic move sequence.
class ArtifactJoint {
  const ArtifactJoint(
    this.label,
    this.axis,
    this.travel,
    this.hint, {
    this.rotation = false,
    this.on = const [],
    this.off = const [],
    this.closeBlocked = const [],
  });
  final String label, axis, hint;
  final double travel;
  final bool rotation;
  final List<int> on, off, closeBlocked;
}

class ArtifactAction {
  const ArtifactAction(this.mechanism, this.index, this.direction);
  final ArtifactMechanism mechanism;
  final int index;
  final int direction;
  ArtifactAction get inverse => ArtifactAction(mechanism, index, -direction);
  Map<String, Object> toJson() => {
    'kind': mechanism.name,
    'index': index,
    'direction': direction,
  };
}

class ArtifactState {
  ArtifactState(
    Iterable<int> rings,
    Iterable<bool> sliders, [
    Iterable<bool> parts = const [false, false, false],
    Iterable<bool> mechanical = const [],
  ]) : rings = List.unmodifiable(rings),
       sliders = List.unmodifiable(sliders),
       parts = List.unmodifiable(parts),
       mechanical = List.unmodifiable(mechanical);
  final List<int> rings;
  final List<bool> sliders;
  // Joint released, lid removed, core extracted. Each requires the previous one.
  final List<bool> parts;
  // Mộng Sen: A..F. Other crafts: one occupancy bit per physical joint.
  final List<bool> mechanical;
  int get key {
    var value = 0;
    for (final ring in rings) {
      value = value * 4 + ring;
    }
    for (final bit in [...sliders, ...parts, ...mechanical]) {
      value = value * 2 + (bit ? 1 : 0);
    }
    return value;
  }

  Map<String, Object> toJson() => {
    'rings': rings,
    'sliders': sliders,
    'parts': parts,
    'mechanical': mechanical,
  };
}

class ArtifactPuzzle {
  ArtifactPuzzle({
    required this.level,
    required this.shape,
    required Iterable<int> targets,
    required Iterable<Iterable<int>> links,
    required this.sliderCount,
  }) : targets = List.unmodifiable(targets),
       links = List.unmodifiable(
         links.map((link) => List<int>.unmodifiable(link)),
       );
  final int level;
  final ArtifactShape shape;
  final List<int> targets;
  final List<List<int>> links;
  final int sliderCount;
  bool get isMongSen => level == 1 && shape == ArtifactShape.cube;
  bool get isCraft => level >= 2 && level <= 5;
  String get title => switch (level) {
    1 => 'Hộp mộc 01 · Mộng Sen',
    2 => 'Ống tre · Trúc Tàng',
    3 => 'Ấn lục giác · Song Nêm',
    4 => 'Trống đồng · Âm Vang',
    5 => 'Khung cửi · Dệt Bí Mật',
    _ => shape.label,
  };
  List<ArtifactJoint> get joints => switch (level) {
    2 => const [
      ArtifactJoint(
        'Chốt tre',
        'z',
        .65,
        'Chốt ngang đang xuyên qua tai vòng. Rút về phía trước.',
        closeBlocked: [1],
      ),
      ArtifactJoint(
        'Vòng bayonet',
        'y',
        1.5707963267948966,
        'Xoay vòng để cửa khuyết trùng hai tai nắp.',
        rotation: true,
        on: [0],
        closeBlocked: [2],
      ),
      ArtifactJoint(
        'Nắp tre',
        'y',
        .72,
        'Hai tai đã thẳng cửa thoát. Nhấc nắp theo trục ống.',
        on: [1],
        closeBlocked: [3],
      ),
      ArtifactJoint(
        'Nắp rời',
        'x',
        2.8,
        'Nắp đã khỏi miệng ống; kéo sang phải để lấy lõi.',
        on: [2],
        closeBlocked: [4],
      ),
      ArtifactJoint(
        'Lõi trúc',
        'y',
        2.2,
        'Kéo lõi ngọc lên khỏi ống tre.',
        on: [3],
      ),
    ],
    3 => const [
      ArtifactJoint(
        'Nêm trái',
        'x',
        -.7,
        'Nêm trái ép giữ đầu cầu ngang. Kéo ra bên trái.',
        closeBlocked: [2],
      ),
      ArtifactJoint(
        'Nêm phải',
        'x',
        .7,
        'Nêm phải cũng giữ cầu ngang. Hai nêm có thể tháo theo thứ tự bất kỳ.',
        closeBlocked: [2],
      ),
      ArtifactJoint(
        'Cầu ngang',
        'z',
        1.35,
        'Rút cả hai nêm rồi kéo cầu ngang về trước.',
        on: [0, 1],
        closeBlocked: [3],
      ),
      ArtifactJoint(
        'Then đồng',
        'z',
        1.5707963267948966,
        'Cầu đã rời khỏi vai then. Xoay then ngang để nhả con trượt.',
        rotation: true,
        on: [2],
        closeBlocked: [4],
      ),
      ArtifactJoint(
        'Con trượt',
        'x',
        1.3,
        'Con trượt giữ tai nắp. Kéo sang phải theo hai ray.',
        on: [3],
        closeBlocked: [5],
      ),
      ArtifactJoint(
        'Nắp ấn',
        'z',
        -2.8,
        'Tai nắp đã được nhả. Trượt nắp về phía sau theo ray.',
        on: [4],
        closeBlocked: [6],
      ),
      ArtifactJoint(
        'Ngọc ấn',
        'y',
        2.0,
        'Khoang ấn đã mở. Nhấc ngọc lên.',
        on: [5],
      ),
    ],
    4 => const [
      ArtifactJoint(
        'Chốt đáy',
        'z',
        -.7,
        'Lật góc nhìn xuống đáy: chốt nhỏ ở mặt sau giữ vòng chân.',
        closeBlocked: [1],
      ),
      ArtifactJoint(
        'Vòng chân',
        'y',
        1.5707963267948966,
        'Xoay vòng chân để cửa đứng thẳng với đầu thanh truyền.',
        rotation: true,
        on: [0],
        closeBlocked: [2],
      ),
      ArtifactJoint(
        'Thanh truyền',
        'y',
        -.75,
        'Cửa đã thẳng. Kéo thanh truyền xuống để nhả tấm che.',
        on: [1],
        closeBlocked: [3],
      ),
      ArtifactJoint(
        'Tấm che',
        'x',
        -1.0,
        'Trượt tấm che sang trái; phía sau có trục then đồng.',
        on: [2],
        closeBlocked: [4],
      ),
      ArtifactJoint(
        'Then mặt trống',
        'z',
        1.5707963267948966,
        'Xoay then khỏi rãnh giữ chốt trên.',
        rotation: true,
        on: [3],
        closeBlocked: [5],
      ),
      ArtifactJoint(
        'Chốt trên',
        'x',
        .8,
        'Rút chốt trên sang phải để nhả khóa vành.',
        on: [4],
        closeBlocked: [6],
      ),
      ArtifactJoint(
        'Khóa vành',
        'z',
        .65,
        'Kéo khóa vành về phía trước; đầu khóa rời khỏi hốc mặt trống.',
        on: [5],
        closeBlocked: [7],
      ),
      ArtifactJoint(
        'Mặt trống',
        'z',
        -3.0,
        'Trượt mặt trống về sau trên hai ray đồng.',
        on: [6],
        closeBlocked: [8],
      ),
      ArtifactJoint('Ngọc âm', 'y', 2.1, 'Nhấc ngọc khỏi lòng trống.', on: [7]),
    ],
    5 => const [
      ArtifactJoint(
        'Khóa hồi vị',
        'x',
        .55,
        'Dịch khóa sang phải để nhả má che; sau khi xoay cam phải đưa khóa trở lại.',
        closeBlocked: [4],
      ),
      ArtifactJoint(
        'Má che',
        'y',
        -.65,
        'Khóa đã nhả. Hạ má che theo ray đứng.',
        on: [0],
        closeBlocked: [2],
      ),
      ArtifactJoint(
        'Cam cửi',
        'z',
        1.5707963267948966,
        'Xoay cam để nâng chốt khỏi thanh dọc; má che giữ cam ở vị trí mở.',
        rotation: true,
        on: [1],
        closeBlocked: [3],
      ),
      ArtifactJoint(
        'Thanh dọc',
        'z',
        1.65,
        'Vai thanh dọc chỉ đi qua cửa rộng khi khóa hồi vị trở về trái.',
        on: [2],
        off: [0],
        closeBlocked: [4],
      ),
      ArtifactJoint(
        'Thanh ngang',
        'x',
        1.7,
        'Thanh dọc đã nhường hốc mộng. Rút thanh ngang sang phải.',
        on: [3],
        closeBlocked: [5, 6],
      ),
      ArtifactJoint(
        'Nêm trái',
        'x',
        -.65,
        'Thanh ngang đã nhả nêm trái giữ cầu trên.',
        on: [4],
        closeBlocked: [7],
      ),
      ArtifactJoint(
        'Nêm phải',
        'x',
        .65,
        'Tháo nêm phải; hai nêm độc lập cùng ép cầu trên.',
        on: [4],
        closeBlocked: [7],
      ),
      ArtifactJoint(
        'Cầu trên',
        'y',
        .65,
        'Cả hai nêm đã rời. Nhấc cầu trên khỏi tai nắp.',
        on: [5, 6],
        closeBlocked: [8],
      ),
      ArtifactJoint(
        'Nắp khoang',
        'z',
        -3.0,
        'Trượt nắp về sau trên ray sau khi nhấc cầu trên.',
        on: [7],
        closeBlocked: [9],
      ),
      ArtifactJoint(
        'Thoi ngọc',
        'y',
        2.1,
        'Nhấc thoi ngọc ra khỏi khoang bí mật.',
        on: [8],
      ),
    ],
    _ => const [],
  };
  static const mechanicalKinds = [
    ArtifactMechanism.belt,
    ArtifactMechanism.panel,
    ArtifactMechanism.cam,
    ArtifactMechanism.longTenon,
    ArtifactMechanism.crossTenon,
    ArtifactMechanism.capSlide,
    ArtifactMechanism.capLift,
  ];
  ArtifactState get solved => ArtifactState(
    targets,
    List.filled(sliderCount, true),
    const [true, true, true],
    isCraft
        ? List.generate(joints.length, (i) => level != 5 || i != 0)
        : isMongSen
        ? const [false, true, true, true, true, true, true]
        : const [],
  );
  bool ringsAligned(ArtifactState state) => List.generate(
    targets.length,
    (i) => state.rings[i] == targets[i],
  ).every((v) => v);
  bool isSolved(ArtifactState state) => isCraft
      ? state.mechanical.last
      : isMongSen
      ? state.mechanical[6]
      : ringsAligned(state) &&
            state.sliders.every((v) => v) &&
            state.parts.every((v) => v);

  Iterable<ArtifactAction> get selections sync* {
    if (isCraft) {
      for (var i = 0; i < joints.length; i++) {
        yield ArtifactAction(ArtifactMechanism.piece, i, 1);
      }
      return;
    }
    if (isMongSen) {
      for (final kind in mechanicalKinds) {
        yield ArtifactAction(kind, 0, 1);
      }
      return;
    }
    for (var i = 0; i < targets.length; i++) {
      yield ArtifactAction(ArtifactMechanism.ring, i, 1);
      yield ArtifactAction(ArtifactMechanism.slider, i, 1);
    }
    for (final kind in [
      ArtifactMechanism.joint,
      ArtifactMechanism.lid,
      ArtifactMechanism.core,
    ]) {
      yield ArtifactAction(kind, 0, 1);
    }
  }

  bool isOpen(ArtifactState state, ArtifactMechanism kind, int index) => isCraft
      ? state.mechanical[index]
      : isMongSen
      ? state.mechanical[mechanicalKinds.indexOf(kind)]
      : kind == ArtifactMechanism.slider
      ? state.sliders[index]
      : kind == ArtifactMechanism.ring
      ? false
      : state.parts[kind.index - 2];

  String label(ArtifactMechanism kind, int index) => switch (kind) {
    ArtifactMechanism.piece => joints[index].label,
    ArtifactMechanism.ring => 'Vòng ${index + 1}',
    ArtifactMechanism.slider =>
      '${shape == ArtifactShape.cylinder ? 'Chốt rút' : 'Thanh trượt'} ${index + 1}',
    ArtifactMechanism.joint =>
      shape == ArtifactShape.cube ? 'Ngàm cạnh' : 'Đai khóa',
    ArtifactMechanism.lid =>
      shape == ArtifactShape.hexagonalPrism ? 'Nắp trượt' : 'Nắp',
    ArtifactMechanism.core => 'Lõi ngọc',
    ArtifactMechanism.belt => 'Đai gỗ A',
    ArtifactMechanism.panel => 'Tấm má B',
    ArtifactMechanism.cam => 'Cam đồng C',
    ArtifactMechanism.longTenon => 'Thanh mộng D',
    ArtifactMechanism.crossTenon => 'Thanh mộng E',
    ArtifactMechanism.capSlide => 'Ray nắp F',
    ArtifactMechanism.capLift => 'Nắp F',
  };

  String? rejection(ArtifactState state, ArtifactAction action) {
    final kind = action.mechanism, index = action.index;
    if (action.direction != 1 && action.direction != -1) {
      return 'Thao tác không hợp lệ.';
    }
    if (isCraft) {
      if (kind != ArtifactMechanism.piece ||
          index < 0 ||
          index >= joints.length) {
        return 'Không tìm thấy cơ cấu.';
      }
      final m = state.mechanical, joint = joints[index];
      final opening = action.direction == 1;
      if (m[index] == opening) return 'Bộ phận đã ở cuối hành trình.';
      if (level == 5 && index == 1 && !m[0]) {
        return 'Khóa hồi vị đang chắn chân má che. Dịch khóa sang phải trước.';
      }
      if (opening) {
        for (final gate in joint.on) {
          if (!m[gate]) {
            return '${joints[gate].label} vẫn đang giữ ${joint.label.toLowerCase()}. Quan sát khe và vai mộng.';
          }
        }
        for (final gate in joint.off) {
          if (m[gate]) {
            return 'Đưa ${joints[gate].label.toLowerCase()} trở về để cửa thoát thẳng với vai mộng.';
          }
        }
        // The returned key captures the extracted crossbar's shoulder.
        if (level == 5 && index == 0 && m[3]) {
          return 'Vai thanh dọc đang chiếm cửa khóa. Lắp thanh dọc về trước.';
        }
      } else {
        for (final gate in joint.closeBlocked) {
          if (m[gate]) {
            return 'Lắp ${joints[gate].label.toLowerCase()} về trước; hốc ghép đang lệch vị trí.';
          }
        }
        if (level == 5 && index == 3 && m[0]) {
          return 'Đưa khóa hồi vị về trái trước khi lắp thanh dọc.';
        }
      }
      return null;
    }
    if (isMongSen) return _mechanicalRejection(state, action);
    if (mechanicalKinds.contains(kind)) return 'Không tìm thấy cơ cấu.';
    if (index < 0 ||
        index >=
            (kind == ArtifactMechanism.ring
                ? targets.length
                : kind == ArtifactMechanism.slider
                ? sliderCount
                : 1)) {
      return 'Không tìm thấy cơ cấu.';
    }
    if (kind == ArtifactMechanism.ring) {
      if (index > 0 && !state.sliders[index - 1]) {
        return 'Rút chốt $index để nhả vòng ${index + 1} và lộ dấu khắc.';
      }
      if (state.sliders[index]) {
        return 'Đẩy chốt ${index + 1} trở lại trước khi xoay vòng này.';
      }
      return null;
    }
    final opening = action.direction == 1;
    if (isOpen(state, kind, index) == opening) {
      return opening
          ? 'Bộ phận đã ở cuối hành trình.'
          : 'Bộ phận đã ở vị trí ban đầu.';
    }
    if (kind == ArtifactMechanism.slider) {
      if (opening) {
        if (index > 0 && !state.sliders[index - 1]) {
          return 'Rút chốt $index trước.';
        }
        if (state.rings[index] != targets[index]) {
          return 'Đối chiếu vòng ${index + 1} với dấu khắc vừa tìm được.';
        }
      } else if ((index + 1 < sliderCount && state.sliders[index + 1]) ||
          state.parts[0]) {
        return 'Lắp lại bộ phận phía sau trước khi đẩy chốt này vào.';
      }
    } else {
      final part = kind.index - 2;
      if (opening &&
          !(part == 0
              ? state.sliders.every((v) => v)
              : state.parts[part - 1])) {
        return switch (kind) {
          ArtifactMechanism.joint =>
            'Các chốt vẫn đang giữ ngàm. Rút từng chốt trước.',
          ArtifactMechanism.lid => 'Xoay ngàm để nhả nắp trước.',
          _ => 'Tháo nắp trước khi lấy lõi.',
        };
      }
      if (!opening && part < 2 && state.parts[part + 1]) {
        return 'Lắp lại ${part == 0 ? 'nắp' : 'lõi'} trước.';
      }
    }
    return null;
  }

  ArtifactState? apply(ArtifactState state, ArtifactAction action) {
    if (rejection(state, action) != null) return null;
    if (isCraft) {
      final values = state.mechanical.toList();
      values[action.index] = action.direction == 1;
      return ArtifactState(state.rings, state.sliders, state.parts, values);
    }
    if (isMongSen) {
      final values = state.mechanical.toList();
      values[mechanicalKinds.indexOf(action.mechanism)] = action.direction == 1;
      return ArtifactState(state.rings, state.sliders, state.parts, values);
    }
    final rings = state.rings.toList(),
        sliders = state.sliders.toList(),
        parts = state.parts.toList();
    if (action.mechanism == ArtifactMechanism.ring) {
      for (final index in [action.index, ...links[action.index]]) {
        rings[index] = (rings[index] + action.direction) % 4;
      }
    } else if (action.mechanism == ArtifactMechanism.slider) {
      sliders[action.index] = action.direction == 1;
    } else {
      parts[action.mechanism.index - 2] = action.direction == 1;
    }
    return ArtifactState(rings, sliders, parts);
  }

  Iterable<ArtifactAction> actions(ArtifactState state) sync* {
    for (final part in selections) {
      for (final direction in [-1, 1]) {
        final action = ArtifactAction(part.mechanism, part.index, direction);
        if (rejection(state, action) == null) yield action;
      }
    }
  }

  Map<String, Object> toJson() => {
    'level': level, 'shape': shape.name, 'targets': targets,
    'assembly': isMongSen
        ? 'mong-sen'
        : isCraft
        ? 'craft-$level'
        : 'classic',
    'links': links, 'sliderCount': sliderCount,
    // Verified assemblies: lock i -> pin i -> next lock -> joint -> lid -> core.
    'parts': isCraft
        ? [
            for (var i = 0; i < joints.length; i++)
              {
                'kind': 'piece',
                'index': i,
                'axis': joints[i].axis,
                'travel': joints[i].travel,
                'rotation': joints[i].rotation,
              },
          ]
        : [
            for (final part in selections)
              {
                'kind': part.mechanism.name,
                'index': part.index,
                'axis': switch (part.mechanism) {
                  ArtifactMechanism.ring =>
                    shape == ArtifactShape.cylinder ? 'y' : 'z',
                  ArtifactMechanism.slider =>
                    shape == ArtifactShape.cylinder ? 'z' : 'x',
                  ArtifactMechanism.joint =>
                    shape == ArtifactShape.cube ? 'z' : 'y',
                  ArtifactMechanism.lid =>
                    shape == ArtifactShape.hexagonalPrism ? 'x' : 'y',
                  ArtifactMechanism.core => 'y',
                  ArtifactMechanism.piece => 'x',
                  ArtifactMechanism.panel || ArtifactMechanism.capLift => 'y',
                  ArtifactMechanism.longTenon ||
                  ArtifactMechanism.capSlide => 'z',
                  _ => 'x',
                },
                'travel': switch (part.mechanism) {
                  ArtifactMechanism.ring ||
                  ArtifactMechanism.joint => 1.5707963267948966,
                  ArtifactMechanism.slider =>
                    shape == ArtifactShape.cylinder ? .8 : .76,
                  ArtifactMechanism.lid => 1.0,
                  ArtifactMechanism.core => 2.0,
                  ArtifactMechanism.belt => .4,
                  ArtifactMechanism.panel => -.9,
                  ArtifactMechanism.cam => 1.5707963267948966,
                  ArtifactMechanism.longTenon => 2.2,
                  ArtifactMechanism.crossTenon => 2.8,
                  ArtifactMechanism.capSlide => -.42,
                  ArtifactMechanism.capLift => 1.5,
                  ArtifactMechanism.piece => 1.0,
                },
                'limits': part.mechanism == ArtifactMechanism.ring
                    ? [0, 3]
                    : [0, 1],
                'requires': switch (part.mechanism) {
                  ArtifactMechanism.ring =>
                    part.index == 0 ? 'none' : 'slider:${part.index - 1}',
                  ArtifactMechanism.slider => 'ring:${part.index}:aligned',
                  ArtifactMechanism.joint => 'all-sliders',
                  ArtifactMechanism.lid => 'joint:0',
                  ArtifactMechanism.core => 'lid:0',
                  _ => 'geometry-interlock',
                },
              },
          ],
    'win': isMongSen ? 'lid-lifted' : 'core-extracted',
  };

  String? _mechanicalRejection(ArtifactState state, ArtifactAction action) {
    final i = mechanicalKinds.indexOf(action.mechanism);
    if (i < 0 || action.index != 0 || state.mechanical.length != 7) {
      return 'Không tìm thấy cơ cấu.';
    }
    final m = state.mechanical, opening = action.direction == 1;
    if (m[i] == opening) return 'Bộ phận đã ở cuối hành trình.';
    // Gates describe occupied geometry, not a prescribed list of moves.
    return switch (action.mechanism) {
      ArtifactMechanism.panel when !m[0] =>
        'Vai tấm B đang vướng gờ phía sau đai A.',
      ArtifactMechanism.cam when !m[1] => 'Tấm má B đang che cơ cấu cam.',
      ArtifactMechanism.longTenon when !m[2] =>
        'Chốt đồng vẫn nằm trong hốc của thanh D.',
      ArtifactMechanism.longTenon when m[0] =>
        'Vai mộng D đang vướng đai A. Quan sát cửa khuyết và khe ngang.',
      ArtifactMechanism.crossTenon when !m[3] =>
        'Lưỡi mộng của D đang giữ thanh E.',
      ArtifactMechanism.crossTenon when !opening && m[5] =>
        'Hốc dưới nắp đã lệch khỏi đầu thanh E. Đưa nắp về trước.',
      ArtifactMechanism.capSlide when m[6] =>
        'Hạ nắp vào cửa thoát trên ray trước khi trượt.',
      ArtifactMechanism.capSlide when opening && !m[4] =>
        'Đầu thanh E còn cài trong hốc dưới nắp.',
      ArtifactMechanism.capLift when !m[5] =>
        'Tai nắp còn nằm dưới gờ ray. Tìm hướng trượt trước khi nhấc.',
      _ => null,
    };
  }
}

class ArtifactLevel {
  const ArtifactLevel(this.puzzle, this.initial, this.minimumMoves);
  final ArtifactPuzzle puzzle;
  final ArtifactState initial;
  final int minimumMoves;
}
