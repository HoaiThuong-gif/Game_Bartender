import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';
import 'account_security.dart';

abstract class AccountService {
  Stream<User?> get changes;
  Future<void> login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> google();
  Future<void> resetPassword(String email);
  Future<void> logout();
}

class FirebaseAccountService implements AccountService {
  FirebaseAccountService(this.auth);
  final FirebaseAuth auth;
  late final security = AccountSecurity(auth);
  int loginEpoch = 0;
  Future<void>? _googleReady;
  Completer<void>? _registration;

  static Future<AccountService> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final auth = FirebaseAuth.instance;
    // A cold start requires a fresh login/OTP or a Keystore-protected biometric grant.
    if (auth.currentUser != null && !auth.currentUser!.isAnonymous) {
      await auth.signOut();
    }
    return FirebaseAccountService(auth);
  }

  @override
  Stream<User?> get changes => auth.userChanges().asyncMap((user) async {
    final registration = _registration;
    if (registration != null) {
      await registration.future;
      return auth.currentUser;
    }
    return user;
  });
  @override
  Future<void> login(String email, String password) async {
    loginEpoch++;
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> register(String name, String email, String password) async {
    loginEpoch++;
    final registration = Completer<void>();
    _registration = registration;
    try {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      // Upgrade a legacy anonymous identity so its UID/data are preserved.
      final old = auth.currentUser;
      final result = old?.isAnonymous == true
          ? await old!.linkWithCredential(credential)
          : await auth.createUserWithEmailAndPassword(
              email: email.trim(),
              password: password,
            );
      await result.user!.updateDisplayName(name.trim());
    } finally {
      registration.complete();
      _registration = null;
    }
  }

  @override
  Future<void> google() async {
    loginEpoch++;
    _googleReady ??= GoogleSignIn.instance.initialize();
    await _googleReady;
    final google = await GoogleSignIn.instance.authenticate();
    final credential = GoogleAuthProvider.credential(
      idToken: google.authentication.idToken,
    );
    final old = auth.currentUser;
    if (old?.isAnonymous == true) {
      try {
        await old!.linkWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        if (error.code != 'credential-already-in-use') rethrow;
        // Sign into the existing account without deleting/merging legacy data.
        await auth.signInWithCredential(credential);
      }
    } else {
      await auth.signInWithCredential(credential);
    }
  }

  @override
  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email.trim());
  @override
  Future<void> logout() async {
    await security.signOut();
    try {
      if (_googleReady != null) await GoogleSignIn.instance.signOut();
    } catch (error) {
      debugPrint('[Account] Google sign-out: ${error.runtimeType}');
    }
  }
}

/// Profiles are separate from legacy RTDB/game records. No game field is reset.
class PlayerProfiles {
  PlayerProfiles({FirebaseFirestore? firestore, this.storage})
    : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;
  final FirebaseStorage? storage;

  DocumentReference<Map<String, dynamic>> reference(String uid) =>
      _db.collection('players').doc(uid);

  Future<void> ensure(User user) => _db.runTransaction((transaction) async {
    final ref = reference(user.uid);
    final snapshot = await transaction.get(ref);
    final previous = snapshot.data() ?? {};
    final name = (user.displayName ?? '').trim();
    final defaults = <String, dynamic>{
      'uid': user.uid,
      'displayName': name.isNotEmpty && name.length <= 40 ? name : 'Người chơi',
      'photoURL': user.photoURL ?? '',
      'email': user.email ?? '',
      'createdAt': Timestamp.fromDate(
        user.metadata.creationTime ?? DateTime.now(),
      ),
      'schemaVersion': 1,
    };
    // Only fill missing fields, including on old documents. Future game data
    // belongs in players/{uid}/games/{gameId}; never initialize empty game maps.
    final missing = Map<String, dynamic>.fromEntries(
      defaults.entries.where((entry) => !previous.containsKey(entry.key)),
    );
    if (missing.isNotEmpty) {
      if (snapshot.exists) {
        transaction.update(ref, missing);
      } else {
        transaction.set(ref, missing);
      }
    }
  });

  Future<void> save(User user, String name, {Uint8List? avatar}) async {
    String? photoURL;
    if (avatar != null) {
      if (avatar.length > 2 * 1024 * 1024) {
        throw ArgumentError('Avatar too large');
      }
      final ref = (storage ?? FirebaseStorage.instance).ref(
        'players/${user.uid}/avatars/${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      final upload = ref.putData(
        avatar,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      await upload.timeout(
        const Duration(seconds: 30),
        onTimeout: () async {
          await upload.cancel();
          throw TimeoutException('Avatar upload timed out');
        },
      );
      photoURL = await ref.getDownloadURL();
    }
    await reference(user.uid)
        .set({
          'displayName': name.trim(),
          'photoURL': ?photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .timeout(const Duration(seconds: 20));
  }

  Future<void> changePassword(User user, String current, String next) async {
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email!, password: current),
    );
    await user.updatePassword(next);
  }
}
