import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:cupid/core/config/api_config.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static final _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// 저장된 토큰의 유효성을 검증합니다.
  /// 토큰이 유효하면 true를 반환하고, 유효하지 않으면 false를 반환합니다.
  static Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await _dio.get(
        '/users/validate-token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data;

      print('토큰 검증 응답: $data');
      return data['isValid'] ?? false;
    } catch (e) {
      print('토큰 검증 실패: $e');
      return false;
    }
  }
}
