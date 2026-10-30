import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/account/account_gate.dart';
import 'package:nhom_bar/account/account_service.dart';
import 'package:nhom_bar/account/account_validation.dart';
import 'package:nhom_bar/account/login_screen.dart';

class TestAccounts implements AccountService {
  User? user;
  final events = StreamController<User?>.broadcast();
  Object? error;
  int attempts = 0;
  @override
  Stream<User?> get changes async* {
    yield user;
    yield* events.stream;
  }

  void emit(User? value) {
    user = value;
    events.add(value);
  }

  @override
  Future<void> login(String email, String password) async {
    attempts++;
    if (error != null) throw error!;
    emit(MockUser(uid: 'player', email: email, isAnonymous: false));
  }

  @override
  Future<void> register(String name, String email, String password) =>
      login(email, password);
  @override
  Future<void> google() => login('player@example.com', 'secret');
  @override
  Future<void> logout() async => emit(null);
  @override
  Future<void> resetPassword(String email) async {
    attempts++;
  }
}

void main() {
  test('Vietnamese validation and Firebase errors cover collisions and wrong credentials', () {
    expect(validateEmail('wrong'), isNotNull);
    expect(validateEmail(' child@example.com '), isNull);
    expect(validatePassword('12345'), isNotNull);
    expect(validatePlayerName('   '), isNotNull);
    expect(
      accountError(FirebaseAuthException(code: 'email-already-in-use')),
      contains('đã có tài khoản'),
    );
    expect(
      accountError(FirebaseAuthException(code: 'invalid-credential')),
      'Email hoặc mật khẩu chưa đúng.',
    );
  });

  test('profile initialization and edits preserve old game data, dates and other players', () async {
    final db = FakeFirebaseFirestore();
    final profiles = PlayerProfiles(firestore: db);
    final created = Timestamp.fromDate(DateTime(2020));
    final player = MockUser(
      uid: 'old-player',
      email: 'a@example.com',
      displayName: 'Auth name',
    );
    await profiles.reference(player.uid).set({
      'displayName': 'Existing name',
      'createdAt': created,
      'scores': {'bartender': 321},
      'gacha': {
        'owned': ['cat'],
      },
    });
    await profiles.reference('other-player').set({'displayName': 'Other'});
    await profiles.ensure(player);
    await profiles.ensure(player);
    var data = (await profiles.reference(player.uid).get()).data()!;
    expect(data['displayName'], 'Existing name');
    expect(data['uid'], player.uid);
    expect(data['createdAt'], created);
    await profiles.save(player, 'New name');
    data = (await profiles.reference(player.uid).get()).data()!;
    expect(data['displayName'], 'New name');
    expect(data['scores'], {'bartender': 321});
    expect(data['gacha'], {
      'owned': ['cat'],
    });
    expect(data['createdAt'], created);
    expect((await profiles.reference('other-player').get()).data(), {
      'displayName': 'Other',
    });
  });

  testWidgets(
    'anonymous session cannot enter Lobby; signing out removes protected routes',
    (tester) async {
      final accounts = TestAccounts()
        ..user = MockUser(uid: 'legacy', isAnonymous: true);
      addTearDown(accounts.events.close);
      await tester.pumpWidget(
        MaterialApp(
          home: AccountGate(
            initialize: () async => accounts,
            lobbyBuilder: (context) => Scaffold(
              body: Column(
                children: [
                  const Text('Protected Lobby'),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const Scaffold(body: Text('Protected profile')),
                      ),
                    ),
                    child: const Text('Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Protected Lobby'), findsNothing);
      accounts.emit(MockUser(uid: 'real', isAnonymous: false));
      await tester.pumpAndSettle();
      expect(find.text('Protected Lobby'), findsOneWidget);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Protected profile'), findsOneWidget);
      await accounts.logout();
      await tester.pumpAndSettle();
      expect(find.text('Protected profile'), findsNothing);
      expect(find.text('Protected Lobby'), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );

  testWidgets(
    'invalid input sends no request and incorrect password stays at login',
    (tester) async {
      final accounts = TestAccounts()
        ..error = FirebaseAuthException(code: 'invalid-credential');
      addTearDown(accounts.events.close);
      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(service: accounts)),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
      await tester.pumpAndSettle();
      expect(accounts.attempts, 0);
      await tester.enterText(find.byType(TextFormField).at(0), 'a@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'incorrect');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Đăng nhập'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
      await tester.pumpAndSettle();
      expect(accounts.attempts, 1);
      expect(find.text('Email hoặc mật khẩu chưa đúng.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );
}
