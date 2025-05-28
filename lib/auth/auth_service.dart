import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ----------------- Google Sign-In -----------------
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("❌ Google sign-in failed: $e");
      return null;
    }
  }

  // ----------------- Facebook Sign-In -----------------
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      print("Facebook login status: ${result.status}");
      if (result.status == LoginStatus.success && result.accessToken != null) {
        print("AccessToken received: ${result.accessToken!.token}");

        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.token,
        );

        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);
        print("Firebase sign-in success: ${userCredential.user?.uid}");

        return userCredential.user;
      } else {
        print("Facebook login failed: ${result.message}");
        return null;
      }
    } catch (e) {
      print("Exception during Facebook login: $e");
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("❌ Email/Password sign-in failed: $e");
      return null;
    }
  }

  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("❌ Email/Password signup failed: $e");
      return null;
    }
  }

  // ----------------- Sign Out -----------------
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      for (final info in user.providerData) {
        if (info.providerId == 'google.com') {
          await GoogleSignIn().signOut();
        } else if (info.providerId == 'facebook.com') {
          await FacebookAuth.instance.logOut();
        }
      }
    }
    await _auth.signOut();
  }

  // ----------------- Get Current User -----------------
  User? get currentUser => _auth.currentUser;
}
