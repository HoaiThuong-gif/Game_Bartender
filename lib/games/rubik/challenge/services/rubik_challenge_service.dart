import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../firebase_options.dart';
import '../models/rubik_room.dart';

abstract class RubikChallengeRepository {
  String get uid;
  bool get demo;
  int get serverNow;
  Future<String> create(String name);
  Future<void> join(String code, String name);
  Stream<RubikRoom?> watch(String code);
  Future<void> send(String code, int round, String action);
  Future<void> presence(String code, bool online);
  Future<Map<String, int>> rewardReceipts();
  Future<void> dispose();
}

class FirebaseRubikChallengeRepository implements RubikChallengeRepository {
  FirebaseRubikChallengeRepository._(this.db, this.uid);
  final FirebaseDatabase db;
  @override
  final String uid;
  int _offset = 0;
  bool _connected = false;
  String? _room;
  StreamSubscription<DatabaseEvent>? _clock, _connection;
  static Future<FirebaseRubikChallengeRepository> connect() async {
    const url = String.fromEnvironment('RUBIK_DATABASE_URL');
    if (url.isEmpty) {
      throw StateError(
        'Cần cấu hình RUBIK_DATABASE_URL và deploy backend Rubik. Xem CHALLENGE.md.',
      );
    }
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser ?? (await auth.signInAnonymously()).user!;
    final repo = FirebaseRubikChallengeRepository._(
      FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: url),
      user.uid,
    );
    repo._clock = repo.db.ref('.info/serverTimeOffset').onValue.listen((e) {
      repo._offset = (e.snapshot.value as num? ?? 0).toInt();
    });
    repo._connection = repo.db.ref('.info/connected').onValue.listen((e) {
      repo._connected = e.snapshot.value == true;
      if (repo._connected && repo._room != null) {
        unawaited(repo.presence(repo._room!, true).catchError((Object _) {}));
      }
    });
    await repo.db
        .ref('.info/connected')
        .onValue
        .firstWhere((e) => e.snapshot.value == true)
        .timeout(const Duration(seconds: 15));
    repo._connected = true;
    return repo;
  }

  @override
  bool get demo => false;
  @override
  int get serverNow => DateTime.now().millisecondsSinceEpoch + _offset;
  Future<void> _command(
    String code,
    int round,
    String action, {
    String name = '',
  }) async {
    if (!_connected) throw StateError('Mất kết nối. Hãy thử lại khi có mạng.');
    final request = db.ref('rubikCommands/$uid').push();
    final response = db.ref('rubikResponses/$uid/${request.key}');
    final reply = Completer<Map<String, dynamic>>();
    final subscription = response.onValue.listen((event) {
      if (event.snapshot.exists && !reply.isCompleted) {
        reply.complete(challengeMap(event.snapshot.value));
      }
    }, onError: (Object error, StackTrace stack) {
      if (!reply.isCompleted) reply.completeError(error, stack);
    });
    try {
      await Future.wait<void>([
        reply.future.then((result) {
          if (result['ok'] != true) {
            throw StateError(result['error'] as String? ?? 'Thao tác thất bại');
          }
        }),
        request.set({
          'action': action, 'code': code, 'round': round,
          'at': ServerValue.timestamp,
          'name': name.trim().substring(0, min(name.trim().length, 24)),
        }),
      ], eagerError: true).timeout(const Duration(seconds: 30));
    } finally {
      await subscription.cancel();
    }
  }

  @override
  Future<String> create(String name) async {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final code = List.generate(
      6,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
    await _command(code, 0, 'create', name: name);
    _room = code;
    await presence(code, true);
    return code;
  }

  @override
  Future<void> join(String code, String name) async {
    await _command(code, 0, 'join', name: name);
    _room = code;
    await presence(code, true);
  }

  @override
  Stream<RubikRoom?> watch(String code) => db
      .ref('rubikRooms/$code')
      .onValue
      .map(
        (e) => e.snapshot.exists
            ? RubikRoom(code, challengeMap(e.snapshot.value))
            : null,
      );
  @override
  Future<void> send(String code, int round, String action) =>
      _command(code, round, action);
  @override
  Future<void> presence(String code, bool online) async {
    final ref = db.ref('rubikPresence/$code/$uid');
    if (online) {
      await ref.onDisconnect().set({
        'online': false,
        'at': ServerValue.timestamp,
      });
    }
    await ref.set({'online': online, 'at': ServerValue.timestamp});
  }

  @override
  Future<Map<String, int>> rewardReceipts() async =>
      challengeMap((await db.ref('rubikRewards/$uid').get()).value).map(
        (id, value) =>
            MapEntry(id, (challengeMap(value)['amount'] as num).toInt()),
      );
  @override
  Future<void> dispose() async {
    if (_room != null) {
      try {
        await presence(_room!, false);
      } catch (_) {}
    }
    await _clock?.cancel();
    await _connection?.cancel();
  }
}
