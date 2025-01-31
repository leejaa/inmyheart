import 'package:cupid/features/quiz/quiz_page.dart';
import 'package:cupid/features/quiz/quiz_selections_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cupid/core/theme/app_theme.dart';
import 'package:cupid/features/main/main_page.dart';
import 'package:cupid/features/auth/phone_verification_page.dart';
import 'package:cupid/features/auth/verification_code_page.dart';
import 'package:cupid/features/permission/permission_required_page.dart';
import 'package:cupid/features/likes/likes_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cupid/core/services/token_service.dart';
import 'package:cupid/core/services/fcm_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // AdMob 초기화
  await MobileAds.instance.initialize();

  String initialLocation = '/auth/phone';

  // 저장된 토큰이 있는지 확인하고 유효성 검증
  final token = await TokenService.getToken();
  print('token: $token');
  if (token != null) {
    final isValid = await TokenService.validateToken();
    print('isValid: $isValid');
    if (!isValid) {
      // 토큰이 유효하지 않으면 삭제
      await TokenService.deleteToken();
    } else {
      // 토큰이 유효하면 연락처 권한 체크
      final contactsStatus = await Permission.contacts.status;
      print('contactsStatus: $contactsStatus');

      if (contactsStatus.isPermanentlyDenied) {
        initialLocation = '/permission';
      } else if (contactsStatus.isDenied) {
        // 권한이 없는 경우 권한 요청
        final result = await Permission.contacts.request();
        print('permission request result: $result');

        if (result.isGranted || result == PermissionStatus.limited) {
          initialLocation = '/';
        } else {
          initialLocation = '/permission';
        }
      } else {
        // 권한이 허용(전체 또는 일부)된 경우 홈 화면으로 이동
        initialLocation = '/';
      }
    }
  }

  runApp(
    ProviderScope(
      child: App(initialLocation: initialLocation),
    ),
  );
}

class App extends ConsumerStatefulWidget {
  final String initialLocation;

  const App({
    super.key,
    required this.initialLocation,
  });

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    final authToken = await TokenService.getToken();
    if (authToken == null) return;

    final fcmService = ref.read(fcmServiceProvider);
    await fcmService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(initialLocation: widget.initialLocation);
  }
}

class MyApp extends StatelessWidget {
  final String initialLocation;

  const MyApp({
    super.key,
    required this.initialLocation,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Cupid',
          theme: AppTheme.light,
          routerConfig: GoRouter(
            initialLocation: initialLocation,
            navigatorKey: navigatorKey,
            routes: [
              GoRoute(
                path: '/',
                redirect: (context, state) async {
                  // 메인 페이지 접근 시 연락처 권한 체크
                  final contactsStatus = await Permission.contacts.status;

                  if (contactsStatus.isPermanentlyDenied) {
                    return '/permission';
                  } else if (contactsStatus.isDenied) {
                    final result = await Permission.contacts.request();
                    if (result.isGranted ||
                        result == PermissionStatus.limited) {
                      return null;
                    }
                    return '/permission';
                  }
                  return null;
                },
                builder: (context, state) => const MainPage(),
              ),
              GoRoute(
                path: '/quiz',
                builder: (context, state) => const QuizPage(),
              ),
              GoRoute(
                path: '/quiz/selected',
                builder: (context, state) => QuizSelectionsPage(
                  selections: state.extra as List<dynamic>,
                ),
              ),
              GoRoute(
                path: '/auth/phone',
                builder: (context, state) => const PhoneVerificationPage(),
              ),
              GoRoute(
                path: '/auth/verification',
                builder: (context, state) {
                  final extra = state.extra as Map<String, String>;
                  return VerificationCodePage(
                    phoneNumber: extra['phoneNumber']!,
                  );
                },
              ),
              GoRoute(
                path: '/permission',
                builder: (context, state) => const PermissionRequiredPage(),
              ),
              GoRoute(
                path: '/likes',
                builder: (context, state) => const LikesPage(),
              ),
            ],
          ),
        );
      },
    );
  }
}
