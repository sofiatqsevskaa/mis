import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../models/cafe_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  CafeUser? _user;
  bool _loading = false;

  CafeUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _loading;

  bool get isApproved => _user?.role == 'approved' || _user?.role == 'admin';
  bool get isAdmin => _user?.role == 'admin';
  bool get isPending => _user?.role == 'pending';

  Future<void> login(String email, String password) async {
    await _runWithLoading(() async {
      final result = await _authService.login(email, password);
      _user = result['user'];
    });
  }

  Future<void> register(String email, String password, String name) async {
    await _runWithLoading(() async {
      final result = await _authService.register(email, password, name);
      _user = result['user'];
    });
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> _runWithLoading(Future<void> Function() action) async {
    _setLoading(true);
    try {
      await action();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
