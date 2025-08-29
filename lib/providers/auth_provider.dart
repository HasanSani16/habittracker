import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  User? _firebaseUser;
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    _authService.authStateChanges().listen((user) {
      _firebaseUser = user;
      notifyListeners();
    });
  }

  User? get firebaseUser => _firebaseUser;
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String? gender,
    DateTime? dateOfBirth,
    double? heightCm,
  }) async {
    _setLoading(true);
    try {
      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        heightCm: heightCm,
      );
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}


