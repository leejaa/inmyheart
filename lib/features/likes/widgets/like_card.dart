import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LikeCard extends StatefulWidget {
  final Map<String, dynamic> like;

  const LikeCard({
    super.key,
    required this.like,
  });

  @override
  State<LikeCard> createState() => _LikeCardState();
}

class _LikeCardState extends State<LikeCard> {
  bool _isHintRevealed = false;
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // 테스트 광고 ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                _isHintRevealed = true;
              });
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Failed to load rewarded ad: ${error.message}');
        },
      ),
    );
  }

  void _showRewardedAd() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('알림'),
        content: const Text('애드몹 광고 준비 중입니다.\n잠시만 기다려주세요.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _maskName(String name) {
    if (name.length <= 1) return '*';
    if (_isHintRevealed) {
      return name.substring(0, 1) + '*' * (name.length - 1);
    }
    return '*' * name.length;
  }

  String _maskPhoneNumber(String phone) {
    if (_isHintRevealed) {
      if (phone.length > 4) {
        return '*' * (phone.length - 4) +
            phone.substring(phone.length - 4, phone.length - 2);
      }
      return phone;
    }
    return '*' * phone.length;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.like['user'];
    final createdAt = DateTime.parse(widget.like['createdAt']);
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
      child: Column(
        children: [
          ListTile(
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
            title: Text(
              _maskName(user['name']),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B2F4A),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _maskPhoneNumber(user['phone'] ?? ''),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
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
              ],
            ),
            trailing: const Icon(
              Icons.favorite,
              color: Color(0xFFFF4D8D),
            ),
          ),
          if (!_isHintRevealed) ...[
            Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            InkWell(
              onTap: _isLoading ? null : _showRewardedAd,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFFF4D8D)),
                        ),
                      )
                    else
                      Icon(
                        Icons.visibility_outlined,
                        size: 16.w,
                        color: const Color(0xFFFF4D8D),
                      ),
                    SizedBox(width: 8.w),
                    Text(
                      _isLoading ? '로딩 중...' : '힌트 보기',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF4D8D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
