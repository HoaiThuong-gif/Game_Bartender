/// Standard API exceptions matching the error contract in API.md.
class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'error': {
          'code': code,
          'message': message,
        },
      };

  factory ApiException.invalidRequest(String message) => ApiException(
        statusCode: 400,
        code: 'INVALID_REQUEST',
        message: message,
      );

  factory ApiException.unauthorized(
          [String message = 'Missing or invalid player token.']) =>
      ApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: message,
      );

  factory ApiException.roomNotFound(String code) => ApiException(
        statusCode: 404,
        code: 'ROOM_NOT_FOUND',
        message: 'Room #$code not found.',
      );

  factory ApiException.itemNotFound(String itemId) => ApiException(
        statusCode: 404,
        code: 'ITEM_NOT_FOUND',
        message: 'Item $itemId not found in inbox.',
      );

  factory ApiException.roomFull() => const ApiException(
        statusCode: 409,
        code: 'ROOM_FULL',
        message: 'Room is already full (max 4 players).',
      );

  factory ApiException.roomNotJoinable() => const ApiException(
        statusCode: 409,
        code: 'ROOM_NOT_JOINABLE',
        message: 'Room has already started or ended.',
      );

  factory ApiException.notEnoughPlayers() => const ApiException(
        statusCode: 409,
        code: 'NOT_ENOUGH_PLAYERS',
        message:
            'At least 2 connected players are required to start the match.',
      );

  factory ApiException.invalidState(String message) => ApiException(
        statusCode: 409,
        code: 'INVALID_STATE',
        message: message,
      );

  factory ApiException.invalidMove(String message) => ApiException(
        statusCode: 422,
        code: 'INVALID_MOVE',
        message: message,
      );

  factory ApiException.orderMismatch(String message) => ApiException(
        statusCode: 422,
        code: 'ORDER_MISMATCH',
        message: message,
      );

  @override
  String toString() => 'ApiException($statusCode, $code: $message)';
}
