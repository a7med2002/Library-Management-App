import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:library_managment/core/Services/objectbox_service.dart';
import 'package:library_managment/core/Services/store_service.dart';
import 'package:library_managment/core/models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // ─── Google Sign In ───────────────────────────────────────
  static Future<UserModel?> signInWithGoogle() async {
    try {
      const scopes = ['email', 'profile', 'openid'];

      await _googleSignIn.initialize();

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: scopes,
      );

      if (googleUser == null) return null;

      final GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          .authorizeScopes(scopes);

      if (authorization == null) return null;

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      final storeId = await StoreService.initStore(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );

      final user = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'مستخدم',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL ?? '',
        isLoggedIn: true,
        storeId: storeId,
        lastLogin: DateTime.now(),
      );

      debugPrint('📦 ObjectBox ready: ${ObjectBoxService.isReady}');
      ObjectBoxService.saveUser(user);
      return user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      debugPrint('❌ GoogleSignInException: $e');
      rethrow;
    } catch (e) {
      debugPrint('❌ SignIn Error: $e');
      rethrow;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google signout: $e');
    }

    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Firebase signout: $e');
    }

    ObjectBoxService.clearUser();
  }

  // ─── Current User ─────────────────────────────────────────
  static UserModel? get currentUser => ObjectBoxService.getUser();

  static bool get isLoggedIn => ObjectBoxService.isLoggedIn;
}
