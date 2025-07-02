import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;

    if (user != null) {
      print('✅ User signed in: UID=${user.uid}, Email=${user.email}');
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('✅ Updated lastLoginAt for user UID=${user.uid}');
      } catch (e) {
        print('⚠️ Failed to update lastLoginAt: $e');
      }
    } else {
      print('⚠️ signIn returned null user for email: $email');
    }

    return user;
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<String?> getUserRole(String uid, {int retries = 2}) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      print('🔍 Fetching user role for UID: $uid (attempt ${attempt + 1})');
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        print('⚠️ No user document found for UID: $uid');
        return null;
      }

      final data = doc.data();
      final role = data?['role'];
      print('🔍 Role fetched from Firestore for UID $uid: $role');

      if (role != null && role.toString().trim().isNotEmpty) {
        return role;
      }

      // If role missing or empty, wait a bit and retry
      await Future.delayed(const Duration(milliseconds: 500));
    }

    print('⚠️ Failed to fetch valid role for UID $uid after $retries attempts.');
    return null;
  }
}
