import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cupid/core/config/api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> sendVerificationCode(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/send-code'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone': phoneNumber,
        }),
      );

      final data = json.decode(utf8.decode(response.bodyBytes));

      print(data);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? '인증 코드 전송에 실패했습니다.');
      }

      return data;
    } catch (e) {
      throw Exception('인증 코드 전송 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/verify-code'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone': phoneNumber,
          'code': code,
        }),
      );

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? '인증 코드 확인에 실패했습니다.');
      }

      return data;
    } catch (e) {
      throw Exception('인증 코드 확인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
