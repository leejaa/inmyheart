import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class LikeCard extends StatelessWidget {
  final Map<String, dynamic> like;

  const LikeCard({
    super.key,
    required this.like,
  });

  @override
  Widget build(BuildContext context) {
    final user = like['user'];

    print(user);
    final createdAt = DateTime.parse(like['createdAt']);
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours}시간 전';
    } else {
      timeAgo = '${difference.inDays}일 전';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFF4D8D).withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B2F4A).withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF6F9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Text(
                user['name'].substring(0, 1),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF4D8D),
                ),
              ),
            ),
          ),
        ),
        title: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Text(
            user['name'],
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B2F4A),
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Text(
                user['phone'] ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 12.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(width: 4.w),
                Text(
                  '서로 호감을 표시한 경우에만 공개됩니다',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.favorite,
          color: Color(0xFFFF4D8D),
        ),
      ),
    );
  }
}
