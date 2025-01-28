import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cupid/core/config/api_config.dart';
import 'package:cupid/core/services/token_service.dart';
import 'package:cupid/features/home/models/contact.dart';
import 'package:cupid/core/providers/contact_provider.dart';

final likedContactProvider = FutureProvider<Contact?>((ref) async {
  final token = await TokenService.getToken();
  if (token == null) return null;

  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/like/liked'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    if (data['liked'] == null) return null;

    final liked = data['liked'];
    final user = liked['user'];

    return Contact(
      id: user['id'],
      name: user['name'] ?? '미등록 사용자',
      phoneNumber: formatPhoneNumber(user['phone']),
      displayPhoneNumber:
          formatDisplayPhoneNumber(formatPhoneNumber(user['phone'])),
      imageUrl: '',
      isLiked: true,
      isRegistered: user['isRegistered'] ?? false,
    );
  } catch (e) {
    print('Error fetching liked contact: $e');
    return null;
  }
});
