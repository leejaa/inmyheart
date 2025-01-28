import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:cupid/core/services/token_service.dart';
import 'package:cupid/core/services/fcm_service.dart';
import '../../features/webview/webview_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with WidgetsBindingObserver {
  bool _notificationEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화되었을 때 알림 권한 상태를 확인하여 업데이트
      _checkNotificationStatus();
    }
  }

  Future<void> _checkNotificationStatus() async {
    final status = await Permission.notification.status;
    print('알림 권한 상태: $status');
    setState(() {
      _notificationEnabled = status.isGranted;
    });
    // FCM 서비스에 알림 상태 전달
    await ref.read(fcmServiceProvider).checkNotificationPermission();
  }

  Future<void> _toggleNotification(bool value) async {
    if (value) {
      // 알림 권한 요청
      final status = await Permission.notification.request();
      if (status.isGranted) {
        setState(() {
          _notificationEnabled = true;
        });
        // FCM 서비스에 알림 상태 전달
        await ref.read(fcmServiceProvider).requestNotificationPermission();
      } else if (status.isPermanentlyDenied) {
        // 권한이 영구적으로 거부된 경우 앱 설정으로 이동 안내
        _showPermissionDeniedDialog();
      }
    } else {
      // 알림 권한 해제는 시스템 설정에서만 가능하므로 안내
      _showDisableNotificationDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('알림 권한 필요'),
        content: const Text('알림을 받기 위해서는 앱 설정에서 알림 권한을 허용해주세요.'),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              '취소',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: CupertinoColors.systemBlue,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text(
              '설정으로 이동',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemBlue,
              ),
            ),
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDisableNotificationDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('알림 해제 안내'),
        content: const Text('알림을 해제하려면 시스템 설정에서 알림 권한을 비활성화해주세요.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
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

  void _showTermsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WebViewPage(
          title: '서비스 이용약관',
          url: 'https://example.com/terms',
        ),
      ),
    );
  }

  void _showPrivacyPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WebViewPage(
          title: '개인정보 처리방침',
          url: 'https://example.com/privacy',
        ),
      ),
    );
  }

  void _showVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('버전 정보'),
        content: Text('현재 버전: ${packageInfo.version}'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
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

  void _showDeleteAccountDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('서비스 탈퇴'),
        content: const Text(
          '정말 탈퇴하시겠습니까?\n탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              '취소',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: CupertinoColors.systemBlue,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text(
              '탈퇴',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () async {
              // TODO: API 호출하여 계정 삭제
              await TokenService.deleteToken();
              if (mounted) {
                context.go('/auth/phone');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '설정',
          style: TextStyle(
            color: const Color(0xFF2B2F4A),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: '알림',
            items: [
              _SettingItem(
                title: '알림 수신',
                onTap: () {
                  _toggleNotification(!_notificationEnabled);
                },
                showToggle: true,
                isToggleOn: _notificationEnabled,
              ),
            ],
          ),
          _buildDivider(),
          _buildSection(
            title: '약관 및 정책',
            items: [
              _SettingItem(
                title: '서비스 이용약관',
                onTap: _showTermsPage,
              ),
              _SettingItem(
                title: '개인정보 처리방침',
                onTap: _showPrivacyPage,
              ),
            ],
          ),
          _buildDivider(),
          _buildSection(
            title: '앱 정보',
            items: [
              _SettingItem(
                title: '버전',
                onTap: _showVersionInfo,
              ),
            ],
          ),
          _buildDivider(),
          _buildSection(
            title: '계정',
            items: [
              _SettingItem(
                title: '서비스 탈퇴',
                titleColor: const Color(0xFFFF4D8D),
                onTap: _showDeleteAccountDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, top: 20.h, bottom: 8.h),
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFF8E92A8),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1.h,
      thickness: 1.h,
      color: const Color(0xFFF2F2F2),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showToggle;
  final Color? titleColor;
  final bool isToggleOn;

  const _SettingItem({
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showToggle = false,
    this.titleColor,
    this.isToggleOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? const Color(0xFF2B2F4A),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: const Color(0xFF8E92A8),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showToggle)
              Switch.adaptive(
                value: isToggleOn,
                onChanged: (value) {
                  onTap();
                },
                activeColor: const Color(0xFFFF4D8D),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: const Color(0xFF8E92A8),
              ),
          ],
        ),
      ),
    );
  }
}
