import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cupid/core/config/api_config.dart';
import 'package:cupid/core/services/token_service.dart';

final todayQuizProvider = FutureProvider.autoDispose((ref) async {
  try {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/quiz/today'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? '퀴즈를 불러오는데 실패했습니다.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final quiz = data['quiz'] as Map<String, dynamic>;
    final answer = data['answer'] as Map<String, dynamic>?;

    return {
      ...quiz,
      'answer': answer,
    };
  } catch (e) {
    print('e: $e');
    throw Exception('퀴즈를 불러오는데 실패했습니다: ${e.toString()}');
  }
});

final quizAnswerProvider =
    FutureProvider.family.autoDispose<void, Map<String, dynamic>>(
  (ref, params) async {
    try {
      final token = await TokenService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/quiz/answer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'quizId': params['quizId'],
          'phone': params['phone'],
          'name': params['name'],
        }),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? '답변 제출에 실패했습니다.');
      }

      // 성공적으로 답변이 제출되면 오늘의 퀴즈를 리프레시
      ref.invalidate(todayQuizProvider);
    } catch (e) {
      throw Exception('답변 제출에 실패했습니다: ${e.toString()}');
    }
  },
);
