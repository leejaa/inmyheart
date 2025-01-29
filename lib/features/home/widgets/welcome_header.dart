import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cupid/core/config/api_config.dart';
import 'package:cupid/core/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final likeCountProvider = FutureProvider<int>((ref) async {
  final token = await TokenService.getToken();
  if (token == null) return 0;

  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/like/count'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) return 0;

    final data = jsonDecode(response.body);
    return data['data']['count'] ?? 0;
  } catch (e) {
    print('Error fetching like count: $e');
    return 0;
  }
});

final quizSelectionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final token = await TokenService.getToken();
  if (token == null) return {'isSelected': false};

  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/quiz/selected'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) return {'isSelected': false};

    final data = jsonDecode(response.body);
    return data['data'];
  } catch (e) {
    print('Error fetching quiz selections: $e');
    return {'isSelected': false};
  }
});

class WelcomeHeader extends ConsumerWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeCountAsync = ref.watch(likeCountProvider);
    final quizSelectionAsync = ref.watch(quizSelectionProvider);

    return Container(
      height: 300.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF7676),
            const Color(0xFFFF4D8D),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 배경 장식 요소들
            Positioned(
              top: -40.h,
              right: -30.w,
              child: Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            // 메인 컨텐츠
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 로고 영역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'in my',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38.sp,
                              fontFamily: 'Pacifico',
                              height: 1,
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(4.w, 2.h),
                            child: Text(
                              '💝',
                              style: TextStyle(
                                fontSize: 32.sp,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 22.w,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  // 호감 표시 알림
                  GestureDetector(
                    onTap: () {
                      context.push('/likes'); // 새로운 페이지로 이동
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 16.w,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              likeCountAsync.when(
                                data: (count) => Text(
                                  count > 0
                                      ? '$count명이 호감을 표시했어요'
                                      : '아직 호감을 표시한 사람이 없어요',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                loading: () => Text(
                                  '로딩 중...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                error: (_, __) => Text(
                                  '호감 표시 수를 불러올 수 없습니다',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '지금 확인하기',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withOpacity(0.8),
                            size: 14.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      quizSelectionAsync.whenData((data) {
                        if (data['isSelected'] == true) {
                          // 지목된 퀴즈가 있는 경우
                          context.push('/quiz/selected',
                              extra: data['selections']);
                        } else {
                          // 지목된 퀴즈가 없는 경우
                          context.push('/quiz');
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.white,
                              size: 16.w,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              quizSelectionAsync.when(
                                data: (data) => Text(
                                  data['isSelected'] == true
                                      ? '오늘의 퀴즈에 지목되었어요'
                                      : '오늘의 퀴즈 보러가기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                loading: () => Text(
                                  '로딩 중...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                error: (_, __) => Text(
                                  '오늘의 퀴즈 보러가기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '지금 확인하기',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withOpacity(0.8),
                            size: 14.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
