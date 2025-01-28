import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:cupid/core/config/api_config.dart';
import 'package:cupid/core/services/token_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:cupid/main.dart';

// 백그라운드 메시지 핸들러
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('백그라운드 메시지 수신: ${message.messageId}');
}

final fcmServiceProvider = Provider<FCMService>((ref) => FCMService());

class FCMService {
  final _messaging = FirebaseMessaging.instance;
  final _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 백그라운드 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 포그라운드 알림 표시 옵션 설정
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 로컬 노티피케이션 초기화
    await _initializeLocalNotifications();

    // 포그라운드 메시지 핸들러 등록
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 알림 클릭 핸들러 등록
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // FCM 토큰 가져오기
    final token = await _messaging.getToken();
    if (token != null) {
      await updateFcmToken(token);
    }

    // 토큰 갱신 리스너 등록
    _messaging.onTokenRefresh.listen(updateFcmToken);
  }

  /// 알림 권한을 요청하고 현재 권한 상태를 반환합니다.
  Future<bool> requestNotificationPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final isAuthorized =
        settings.authorizationStatus == AuthorizationStatus.authorized;

    // 권한 상태를 서버에 업데이트
    await _updateNotificationPermissionStatus(isAuthorized);

    return isAuthorized;
  }

  /// 현재 알림 권한 상태를 확인합니다.
  Future<bool> checkNotificationPermission() async {
    final settings = await _messaging.getNotificationSettings();
    final isAuthorized =
        settings.authorizationStatus == AuthorizationStatus.authorized;

    // 현재 권한 상태를 서버에 업데이트
    await _updateNotificationPermissionStatus(isAuthorized);

    return isAuthorized;
  }

  /// 알림 권한 상태를 서버에 업데이트합니다.
  Future<void> _updateNotificationPermissionStatus(bool isEnabled) async {
    try {
      final authToken = await TokenService.getToken();
      if (authToken == null) return;

      await _dio.post(
        '/users/notification/settings',
        data: {'isEnabled': isEnabled},
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        ),
      );
    } catch (e) {
      print('알림 권한 상태 업데이트 실패: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // 알림 클릭 시 처리
        print('로컬 알림 클릭: ${details.payload}');

        // payload에서 route 정보 추출
        if (details.payload != null && navigatorKey.currentContext != null) {
          try {
            final data =
                details.payload!.replaceAll('{', '').replaceAll('}', '');
            final pairs = data.split(',');
            for (var pair in pairs) {
              final keyValue = pair.trim().split(':');
              if (keyValue.length == 2 && keyValue[0].trim() == 'route') {
                final route = keyValue[1].trim();
                GoRouter.of(navigatorKey.currentContext!).push(route);
                break;
              }
            }
          } catch (e) {
            print('알림 payload 파싱 실패: $e');
          }
        }
      },
    );

    // Android 알림 채널 생성
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      '중요 알림',
      description: '중요한 알림을 위한 채널입니다.',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    print('포그라운드 메시지 수신: ${message.messageId}');

    // if (message.notification != null) {
    //   await _showLocalNotification(message);
    // }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('알림 클릭: ${message.data}');

    // 라우트 정보가 있는 경우 해당 화면으로 이동
    final route = message.data['route'];
    if (route != null && navigatorKey.currentContext != null) {
      GoRouter.of(navigatorKey.currentContext!).push(route);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) return;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        '중요 알림',
        channelDescription: '중요한 알림을 위한 채널입니다.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  Future<void> updateFcmToken(String token) async {
    try {
      final authToken = await TokenService.getToken();
      if (authToken == null) return;

      await _dio.post(
        '/users/notification/token',
        data: {'fcmToken': token},
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        ),
      );
    } catch (e) {
      print('FCM 토큰 업데이트 실패: $e');
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
