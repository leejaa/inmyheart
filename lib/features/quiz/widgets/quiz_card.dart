import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class QuizCard extends StatelessWidget {
  final String question;
  final VoidCallback onSelectContact;
  final Animation<double> scaleAnimation;
  final Animation<double> floatAnimation;
  final Map<String, dynamic>? answer;
  final List<Contact>? randomContacts;
  final Function(Contact)? onRandomContactSelected;

  const QuizCard({
    super.key,
    required this.question,
    required this.onSelectContact,
    required this.scaleAnimation,
    required this.floatAnimation,
    this.answer,
    this.randomContacts,
    this.onRandomContactSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, floatAnimation.value),
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4D8D).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFFFF4D8D).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                answer != null
                    ? Icons.favorite_rounded
                    : Icons.psychology_rounded,
                color: const Color(0xFFFF4D8D),
                size: 32.w,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              question,
              style: TextStyle(
                color: const Color(0xFF2B2F4A),
                fontSize: 24.sp,
                height: 1.3,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            if (answer != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF4D8D),
                      Color(0xFFFF7676),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Text(
                      '나의 선택',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      answer!['name'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              if (randomContacts != null && randomContacts!.isNotEmpty) ...[
                ...randomContacts!
                    .map((contact) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: GestureDetector(
                            onTap: () => onRandomContactSelected?.call(contact),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 16.h, horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color:
                                      const Color(0xFFFF4D8D).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                contact.displayName,
                                style: TextStyle(
                                  color: const Color(0xFF2B2F4A),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
                SizedBox(height: 16.h),
              ],
              GestureDetector(
                onTap: onSelectContact,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF4D8D),
                        Color(0xFFFF7676),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size: 24.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '연락처에서 선택하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
