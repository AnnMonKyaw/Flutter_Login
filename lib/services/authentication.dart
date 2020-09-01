import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);

  Future<void> signOut();
  Future<FirebaseUser> getCurrentUser();
}

class Auth extends BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> signIn(String email, String password) async {
    var result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    FirebaseUser user = result.user;
    return user.uid;
  }

  @override
  Future<String> signUp(String email, String password) async {
    var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    FirebaseUser user = result.user;
    return user.uid;
  }

  @override
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
