import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Check if user is already logged in
    _user = AuthService.currentUser;
    _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    
    // Listen to auth state changes
    _authSubscription = AuthService.authStateChanges.listen((AuthState data) {
      _user = data.session?.user;
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    });
    
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();
      
      final response = await AuthService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _setError('Sign up failed. Please try again.');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();
      
      final response = await AuthService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _setError('Invalid email or password. Please check your credentials.');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading();
      await AuthService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading();

      final response = await AuthService.signInWithGoogle();

      if (response.user != null) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _setError('Google sign-in failed. Please try again.');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading();
      await AuthService.resetPassword(email: email);
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password. Please try again.';
        case 'Email not confirmed':
          return 'Please check your email and confirm your account.';
        case 'User already registered':
          return 'An account with this email already exists.';
        default:
          return error.message;
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
