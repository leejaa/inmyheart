import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cupid/core/providers/contact_provider.dart';
import 'package:cupid/features/home/widgets/contact_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cupid/core/config/api_config.dart';
import 'package:cupid/core/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cupid/features/home/models/contact.dart';

final likedContactProvider = FutureProvider<Contact?>((ref) async {
  final token = await TokenService.getToken();
  if (token == null) return null;

  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/like/liked'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    if (data['liked'] == null) return null;

    final liked = data['liked'];
    final user = liked['user'];

    return Contact(
      id: user['id'],
      name: user['name'] ?? '미등록 사용자',
      phoneNumber: formatPhoneNumber(user['phone']),
      displayPhoneNumber:
          formatDisplayPhoneNumber(formatPhoneNumber(user['phone'])),
      imageUrl: '',
      isLiked: true,
    );
  } catch (e) {
    print('Error fetching liked contact: $e');
    return null;
  }
});

class ContactsList extends ConsumerWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactControllerProvider);
    final likedContactAsync = ref.watch(likedContactProvider);

    return CustomScrollView(
      slivers: [
        contactsAsync.when(
          data: (contacts) {
            if (contacts.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: Text('연락처가 없습니다.'),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildListDelegate(
                contacts
                    .where((contact) => likedContactAsync.when(
                          data: (likedContact) =>
                              likedContact?.phoneNumber != contact.phoneNumber,
                          loading: () => true,
                          error: (_, __) => true,
                        ))
                    .map((contact) => ContactCard(contact: contact))
                    .toList(),
              ),
            );
          },
          loading: () => SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '연락처를 불러오는 중...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stack) => SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.w,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => ref.refresh(contactControllerProvider),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
