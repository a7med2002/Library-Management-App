import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:library_managment/Core/models/user_model.dart';
import 'objectbox_service.dart';

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

      if (authorization == null) {
        throw Exception("Authorization failed");
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      final user = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'مستخدم',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL ?? '',
        isLoggedIn: true,
        lastLogin: DateTime.now(),
      );

      // حفظ في ObjectBox
      await ObjectBoxService.saveUser(user);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    ObjectBoxService.clearUser();
  }

  // ─── Current User ─────────────────────────────────────────
  static UserModel? get currentUser => ObjectBoxService.getUser();

  static bool get isLoggedIn => ObjectBoxService.isLoggedIn;
}
