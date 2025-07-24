import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isEmployee => _currentUser?.role == 'employee';

  AuthProvider() {
    _initializeAuthListener();
  }

  // Initialize auth state listener
  void _initializeAuthListener() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _clearUserData();
      }
    });
  }

  // Check current auth state
  Future<void> checkAuthState() async {
    _setLoading(true);
    try {
      User? user = _authService.currentUser;
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _clearUserData();
      }
    } catch (e) {
      _setError('Failed to check authentication state');
    }
    _setLoading(false);
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      UserModel? user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        _setCurrentUser(user);
        _setLoading(false);
        return true;
      } else {
        _setError('Sign in failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Create new user account (Admin only)
  Future<bool> createUserAccount({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      UserModel? newUser = await _authService.createUserAccount(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        address: address,
        role: role,
      );

      if (newUser != null) {
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to create user account');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateUserData(updatedUser);
      _setCurrentUser(updatedUser);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _clearUserData();
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      UserModel? user = await _authService.getUserData(uid);
      if (user != null) {
        _setCurrentUser(user);
      } else {
        _clearUserData();
      }
    } catch (e) {
      _setError('Failed to load user data');
      _clearUserData();
    }
  }

  // Private helper methods
  void _setCurrentUser(UserModel user) {
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  void _clearUserData() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _clearError();
  }
}