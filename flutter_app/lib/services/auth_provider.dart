import 'package:flutter/material.dart';
import '../models/models.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  CafeUser? _user;
  bool _loading = false;

  CafeUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _loading;
  bool get isAdmin => _user?.role == 'admin';
  bool get isApproved => _user?.role == 'approved' || _user?.role == 'admin';
  bool get isPending => _user?.role == 'pending';

  Future<void> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _authService.login(email, password);
      _user = result['user'];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _authService.register(email, password, name);
      _user = result['user'];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
