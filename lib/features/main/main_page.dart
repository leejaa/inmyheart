import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cupid/features/home/home_page.dart';
import 'package:cupid/features/likes/likes_page.dart';
import 'package:cupid/features/settings/settings_page.dart';
import 'package:cupid/core/providers/permission_provider.dart';
import 'package:cupid/core/services/fcm_service.dart';
import 'package:cupid/features/quiz/quiz_page.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          HomePage(),
          QuizPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF9BA3EB).withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Color(0xFF8E92A8)),
            selectedIcon: Icon(Icons.home, color: Color(0xFF9BA3EB)),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined, color: Color(0xFF8E92A8)),
            selectedIcon: Icon(Icons.psychology, color: Color(0xFF9BA3EB)),
            label: '퀴즈',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: Color(0xFF8E92A8)),
            selectedIcon: Icon(Icons.settings, color: Color(0xFF9BA3EB)),
            label: '설정',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
