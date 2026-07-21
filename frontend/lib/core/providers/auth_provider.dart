import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/user.dart';

class AuthState {
  const AuthState({this.user, this.token, this.initializing = true});

  final AppUser? user;
  final String? token;
  final bool initializing;

  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({AppUser? user, String? token, bool? initializing}) =>
      AuthState(
        user: user ?? this.user,
        token: token ?? this.token,
        initializing: initializing ?? this.initializing,
      );
}

const _tokenKey = 'crm_auth_token';

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState()) {
    _restore();
  }

  ApiClient get _api => ApiClient(tokenProvider: () => state.token);

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) {
      state = state.copyWith(initializing: false);
      return;
    }
    state = state.copyWith(token: token);
    try {
      final res = await ApiClient(tokenProvider: () => token).get('/auth/me');
      final user = AppUser.fromJson(res['user'] as Map<String, dynamic>);
      state = AuthState(user: user, token: token, initializing: false);
    } catch (_) {
      await prefs.remove(_tokenKey);
      state = const AuthState(initializing: false);
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final res = await _api.post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      await _persist(res);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      final res = await _api.post('/auth/register', body: {
        'name': name,
        'email': email,
        'password': password,
      });
      await _persist(res);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> _persist(Map<String, dynamic> res) async {
    final token = res['token'] as String;
    final user = AppUser.fromJson(res['user'] as Map<String, dynamic>);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    state = AuthState(user: user, token: token, initializing: false);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    state = const AuthState(initializing: false);
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenProvider: () => ref.watch(authProvider).token);
});
