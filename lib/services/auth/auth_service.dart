import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instance of Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // sign in
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Failed to sign in: ${e.message}");
    }
  }

  // sign up
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      // create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Failed to sign up: ${e.message}");
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception("Failed to sign out: ${e.message}");
    }
  }

  Future<void> saveAdditionalUserInfo({
    required String userId,
    required String email,
    required String username,
  }) async {
    await _firestore.collection("Users").doc(userId).set({
      "id": userId,
      "email": email,
      "username": username,
    });
  }

  // errors
}
