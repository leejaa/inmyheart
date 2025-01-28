import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cupid/core/services/fcm_service.dart';
import 'package:cupid/features/home/widgets/contacts_list.dart';
import 'package:cupid/features/home/widgets/welcome_header.dart';
import 'package:cupid/features/home/widgets/liked_contact_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final fcmService = ref.read(fcmServiceProvider);
    final hasPermission = await fcmService.checkNotificationPermission();

    if (!hasPermission && mounted) {
      // 권한이 없는 경우에만 요청
      await fcmService.requestNotificationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        WelcomeHeader(),
        LikedContactCard(),
        Expanded(
          child: ContactsList(),
        ),
      ],
    );
  }
}
