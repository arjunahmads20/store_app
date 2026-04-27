import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  final SharedPreferences _sharedPreferences;
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  TokenStorage(this._sharedPreferences);

  Future<void> saveToken(String token) async {
    await _sharedPreferences.setString(_tokenKey, token);
  }

  String? getToken() {
    return _sharedPreferences.getString(_tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    final jsonString = jsonEncode(userJson);
    await _sharedPreferences.setString(_userKey, jsonString);
  }

  Map<String, dynamic>? getUser() {
    final jsonString = _sharedPreferences.getString(_userKey);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _sharedPreferences.remove(_tokenKey);
    await _sharedPreferences.remove(_userKey);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return TokenStorage(sharedPreferences);
});
