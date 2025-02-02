import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:cupid/features/quiz/providers/quiz_provider.dart';
import 'package:cupid/features/quiz/widgets/contact_selection_dialog.dart';
import 'package:cupid/features/quiz/widgets/quiz_card.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;
  List<Contact>? _randomContacts;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _floatAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.repeat(reverse: true);
    _loadRandomContacts();
  }

  Future<void> _loadRandomContacts() async {
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );
    final contactsList = contacts.toList()..shuffle();
    setState(() {
      _randomContacts = contactsList.take(3).toList();
    });
  }

  Future<void> _checkAndRequestContactPermission() async {
    final status = await Permission.contacts.status;

    if (status.isDenied) {
      final result = await Permission.contacts.request();
      if (result.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('연락처 접근 권한이 필요합니다.'),
              backgroundColor: Color(0xFFFF4D8D),
            ),
          );
        }
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('권한 필요'),
            content: const Text('연락처 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('설정으로 이동'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );
    if (contacts.length < 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('최소 5개 이상의 연락처가 필요합니다.'),
            backgroundColor: Color(0xFFFF4D8D),
          ),
        );
      }
      return;
    }

    if (mounted) {
      _showContactSelectionDialog();
    }
  }

  void _showContactSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (dialogContext) => ContactSelectionDialog(
        contacts: [],
        onContactSelected: (contact) async {
          final quiz = ref.read(todayQuizProvider).value;
          if (quiz == null) return;

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('답변을 제출하는 중...'),
                ],
              ),
              backgroundColor: Color(0xFFFF4D8D),
              duration: Duration(seconds: 1),
            ),
          );

          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          try {
            await ref.read(quizAnswerProvider(
              {
                'quizId': quiz['id'],
                'phone': contact.phones.isNotEmpty
                    ? contact.phones.first.number
                    : '',
                'name': contact.displayName,
              },
            ).future);

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('답변이 제출되었습니다.'),
                backgroundColor: Color(0xFFFF4D8D),
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: Color(0xFFFF4D8D),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _submitAnswer(Contact contact) async {
    final quiz = ref.read(todayQuizProvider).value;
    if (quiz == null) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('답변을 제출하는 중...'),
          ],
        ),
        backgroundColor: Color(0xFFFF4D8D),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      await ref.read(quizAnswerProvider({
        'quizId': quiz['id'],
        'phone': contact.phones.isNotEmpty ? contact.phones.first.number : '',
        'name': contact.displayName,
      }).future);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('답변이 제출되었습니다.'),
          backgroundColor: Color(0xFFFF4D8D),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Color(0xFFFF4D8D),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(todayQuizProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFF6F9),
              const Color(0xFFFAF1F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    quizAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF4D8D),
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: const Color(0xFFFF4D8D),
                              size: 48.w,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              '퀴즈를 불러오는데 실패했습니다',
                              style: TextStyle(
                                color: const Color(0xFF2B2F4A),
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            TextButton(
                              onPressed: () {
                                ref.refresh(todayQuizProvider);
                              },
                              child: Text(
                                '다시 시도',
                                style: TextStyle(
                                  color: const Color(0xFFFF4D8D),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      data: (quiz) {
                        print('Quiz data: $quiz');
                        print('Question value: ${quiz?['question']}');
                        return Column(
                          children: [
                            QuizCard(
                              question: quiz?['question'] as String? ?? '',
                              onSelectContact:
                                  _checkAndRequestContactPermission,
                              scaleAnimation: _scaleAnimation,
                              floatAnimation: _floatAnimation,
                              answer: quiz?['answer'] as Map<String, dynamic>?,
                              randomContacts: _randomContacts,
                              onRandomContactSelected: _submitAnswer,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '오늘의 퀴즈',
                    style: TextStyle(
                      color: const Color(0xFF2B2F4A),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
