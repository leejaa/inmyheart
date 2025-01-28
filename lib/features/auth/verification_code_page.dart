import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cupid/core/services/auth_service.dart';
import 'package:cupid/core/services/token_service.dart';
import 'package:cupid/core/services/fcm_service.dart';
import 'package:permission_handler/permission_handler.dart';

class VerificationCodePage extends ConsumerStatefulWidget {
  const VerificationCodePage({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  ConsumerState<VerificationCodePage> createState() =>
      _VerificationCodePageState();
}

class _VerificationCodePageState extends ConsumerState<VerificationCodePage> {
  final TextEditingController _verificationController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _verificationController.dispose();
    super.dispose();
  }

  void _verifyCode() async {
    final code = _verificationController.text;
    if (code.length != 6) return;

    setState(() {
      _isLoading = true;
    });

    final authService = AuthService();
    try {
      final result = await authService.verifyCode(
        phoneNumber: widget.phoneNumber,
        code: code,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '인증이 완료되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );

        if (result['token'] != null) {
          await TokenService.saveToken(result['token']);

          // FCM 토큰 업데이트
          final fcmService = ref.read(fcmServiceProvider);
          final fcmToken = await fcmService.getToken();
          if (fcmToken != null) {
            await fcmService.updateFcmToken(fcmToken);
          }

          // 연락처 권한 요청
          await Permission.contacts.request();

          context.go('/');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCodeChanged(String value) {
    if (value.length == 6) {
      _verifyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인증번호 입력'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.message_rounded,
                      size: 48.w,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    '인증번호가 발송되었습니다',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.phoneNumber,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _verificationController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        hintText: '000000',
                        hintStyle: TextStyle(
                          color: Colors.grey[300],
                          letterSpacing: 8,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 20.h,
                          horizontal: 24.w,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onChanged: _onCodeChanged,
                    ),
                  ),
                  if (_isLoading) ...[
                    SizedBox(height: 40.h),
                    const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                    ),
                  ],
                  SizedBox(height: 40.h),
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text(
                      '전화번호 다시 입력',
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
