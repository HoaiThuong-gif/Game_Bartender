enum RubikColor { white, yellow, red, orange, green, blue }

/// Fixed orientation shared by manual input, camera and solver adapters.
enum RubikFace {
  up('U', RubikColor.white),
  right('R', RubikColor.red),
  front('F', RubikColor.green),
  down('D', RubikColor.yellow),
  left('L', RubikColor.orange),
  back('B', RubikColor.blue);

  const RubikFace(this.code, this.centerColor);
  final String code;
  final RubikColor centerColor;

  /// Derived from cuber 0.4.0 facelet.dart net and cube.dart edge table:
  /// U2-B2, D2-F8; side faces have their first row against U.
  RubikFace get topFace => switch (this) {
    RubikFace.up => RubikFace.back,
    RubikFace.down => RubikFace.front,
    _ => RubikFace.up,
  };
}
