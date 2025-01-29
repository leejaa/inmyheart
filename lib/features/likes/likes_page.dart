import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cupid/core/config/api_config.dart';
import 'package:cupid/core/services/token_service.dart';
import 'package:cupid/features/likes/widgets/like_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final receivedLikesProvider = FutureProvider<List<dynamic>>((ref) async {
  final token = await TokenService.getToken();
  if (token == null) return [];

  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/like/received'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    return data['data']['likes'] ?? [];
  } catch (e) {
    print('Error fetching received likes: $e');
    return [];
  }
});

class LikesPage extends ConsumerWidget {
  const LikesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receivedLikesAsync = ref.watch(receivedLikesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('나를 좋아하는 사람들'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: receivedLikesAsync.when(
          data: (likes) {
            if (likes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 48.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '아직 호감을 표시한 사람이 없어요',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              itemCount: likes.length,
              itemBuilder: (context, index) {
                return LikeCard(like: likes[index]);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4D8D)),
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.sp,
                  color: Colors.red[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  '데이터를 불러올 수 없습니다',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => ref.refresh(receivedLikesProvider),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
