import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? gender,
    DateTime? dateOfBirth,
    double? heightCm,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(displayName);

    final now = DateTime.now();
    final profile = UserProfile(
      uid: credential.user!.uid,
      displayName: displayName,
      email: email,
      gender: gender,
      dateOfBirth: dateOfBirth,
      heightCm: heightCm,
      createdAt: now,
      updatedAt: now,
    );
    await _db.collection('users').doc(profile.uid).set(profile.toMap());
    await _cacheUser(profile);
    return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final snapshot = await _db.collection('users').doc(credential.user!.uid).get();
    if (snapshot.exists) {
      await _cacheUser(UserProfile.fromMap(snapshot.data()!));
    }
    await _cacheSession(credential.user!.uid);
    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
  }

  Future<void> updateProfile(UserProfile profile) async {
    final updated = profile.copyWith(updatedAt: DateTime.now());
    await _db.collection('users').doc(profile.uid).update(updated.toMap());
    await _cacheUser(updated);
  }

  Future<void> _cacheUser(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', profile.uid);
    await prefs.setString('displayName', profile.displayName);
    await prefs.setString('email', profile.email);
    if (profile.gender != null) await prefs.setString('gender', profile.gender!);
    if (profile.dateOfBirth != null) {
      await prefs.setString('dob', profile.dateOfBirth!.toIso8601String());
    }
    if (profile.heightCm != null) {
      await prefs.setDouble('heightCm', profile.heightCm!);
    }
  }

  Future<void> _cacheSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
  }
}


