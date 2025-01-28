import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cupid/core/providers/contact_provider.dart';
import 'package:cupid/core/providers/liked_contact_provider.dart';
import 'package:cupid/features/home/models/contact.dart' as model;
import 'package:cupid/shared/widgets/like_button.dart';
import 'package:cupid/core/config/api_config.dart';
import 'package:cupid/core/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class ContactCard extends ConsumerStatefulWidget {
  final model.Contact contact;

  const ContactCard({
    super.key,
    required this.contact,
  });

  @override
  ConsumerState<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends ConsumerState<ContactCard> {
  bool _isLoading = false;

  Future<void> _sendLikeRequest() async {
    final token = await TokenService.getToken();
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'phone': widget.contact.phoneNumber,
          'name': widget.contact.name,
        }),
      );

      if (response.body.isEmpty) {
        if (mounted) {
          _showErrorDialog('서버 응답이 비어있습니다.');
        }
        return;
      }

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        if (mounted) {
          _showErrorDialog('서버 응답을 처리할 수 없습니다.');
        }
        return;
      }

      if (response.statusCode != 200) {
        if (mounted) {
          _showErrorDialog(data?['error'] ?? '오류가 발생했습니다.');
        }
        return;
      }

      if (mounted) {
        await ref.refresh(likedContactProvider.future);
        final controller = ref.read(contactControllerProvider.notifier);
        controller.updateContact(widget.contact.copyWith(isLiked: true));
        _showLikeSnackBar(context);
      }
    } catch (e) {
      print(e);
      if (mounted) {
        _showErrorDialog('네트워크 오류가 발생했습니다.');
      }
    }
  }

  Future<void> _handleLikePressed(BuildContext context) async {
    // 이미 좋아요를 누른 상태라면 아무 동작도 하지 않음
    if (widget.contact.isLiked) {
      return;
    }

    // 좋아요 확인 대화상자 표시
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('호감 표시'),
        content: Text(
            '${widget.contact.name}님에게 호감을 표시하시겠습니까?\n호감 표시는 한 사람에게만 할 수 있습니다.'),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              '아니오',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: CupertinoColors.systemBlue,
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text(
              '예',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemBlue,
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await _sendLikeRequest();
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              '확인',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemBlue,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _sendInvitation() async {
    // +8210xxxxyyyy 형식을 010xxxxyyyy 형식으로 변환
    final phoneNumber = widget.contact.phoneNumber.startsWith('+82')
        ? '0${widget.contact.phoneNumber.substring(3)}'
        : widget.contact.phoneNumber;

    final message =
        '💝 ${widget.contact.name}님, in my heart에서 당신을 기다리고 있어요!\n\n지금 바로 가입하고 설렘 가득한 인연을 만나보세요 ✨\n\n앱 다운로드: https://inmyheart.app';

    final uri =
        Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.contact.name}님을 초대했어요!',
                style: TextStyle(fontSize: 14.sp),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
        }
      } else {
        if (mounted) {
          _showErrorDialog('SMS를 보낼 수 없습니다.');
        }
      }
    } catch (e) {
      print('Error sending SMS: $e');
      if (mounted) {
        _showErrorDialog('SMS 전송 중 오류가 발생했습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
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
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.contact.isRegistered ? null : _sendInvitation,
              borderRadius: BorderRadius.circular(12.r),
              child: Opacity(
                opacity: _isLoading ? 0.5 : 1.0,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.contact.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2B2F4A),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.contact.displayPhoneNumber,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF8E92A8),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!widget.contact.isRegistered) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF4D8D),
                                    Color(0xFFFF6B9F)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_add_rounded,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '초대',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                          ],
                          Transform.scale(
                            scale: 0.85,
                            child: LikeButton(
                              isLiked: widget.contact.isLiked,
                              onPressed: () => _handleLikePressed(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF4D8D),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showLikeSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.contact.name}님에게 호감을 표시했어요! 💕',
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}
