import '../models/cube_state.dart';

/// Normalize faces to the documented orientation before returning a state.
/// Null means cancelled; unknown stickers remain null. Validate the result
/// with CubeValidationService before solving.
abstract interface class CubeScanner {
  Future<CubeState?> scan();
}
