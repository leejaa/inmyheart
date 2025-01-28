import 'package:contacts_service/contacts_service.dart' as service;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cupid/features/home/models/contact.dart';
import 'package:cupid/core/config/api_config.dart';
import 'package:cupid/core/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'contact_provider.g.dart';

String formatPhoneNumber(String? phone) {
  if (phone == null || phone.isEmpty) return '';

  // 모든 공백과 하이픈 제거
  String cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');

  return cleaned;
}

String formatDisplayPhoneNumber(String phoneNumber) {
  // +8210으로 시작하는 번호를 010으로 변환
  if (phoneNumber.startsWith('+8210')) {
    return '0${phoneNumber.substring(3)}';
  }
  return phoneNumber;
}

// 연락처 목록 최대 개수 설정
const int maxContactCount = 500;

@riverpod
class ContactController extends _$ContactController {
  @override
  Future<List<Contact>> build() async {
    return _loadContacts();
  }

  Future<List<Contact>> _loadContacts() async {
    final contacts = await service.ContactsService.getContacts();
    final List<Contact> contactList =
        contacts.take(maxContactCount).map((contact) {
      final phoneNumber = formatPhoneNumber(contact.phones?.firstOrNull?.value);
      return Contact(
        id: contact.identifier ?? '',
        name: contact.displayName ?? '이름 없음',
        phoneNumber: phoneNumber,
        displayPhoneNumber: formatDisplayPhoneNumber(phoneNumber),
        imageUrl:
            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
        isLiked: false,
      );
    }).toList();

    // 가입 여부 확인
    final token = await TokenService.getToken();
    if (token == null) return contactList;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/check'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'phones': contactList.map((c) => c.phoneNumber).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final users = data['users'] as List;

        // 가입 여부 업데이트
        return contactList.map((contact) {
          final userInfo = users.firstWhere(
            (u) => u['phone'] == contact.phoneNumber,
            orElse: () => {'isRegistered': false},
          );
          return contact.copyWith(
            isRegistered: userInfo['isRegistered'] ?? false,
          );
        }).toList();
      }
    } catch (e) {
      print('Error checking user registration: $e');
    }

    return contactList;
  }

  Future<void> refreshContacts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadContacts());
  }

  bool hasLikedContact() {
    return state.valueOrNull?.any((contact) => contact.isLiked) ?? false;
  }

  String? getLikedContactName() {
    return state.valueOrNull?.firstWhere((contact) => contact.isLiked).name;
  }

  void updateContact(Contact updatedContact) {
    state.whenData((contacts) {
      final index = contacts.indexWhere((c) => c.id == updatedContact.id);
      if (index != -1) {
        final updatedContacts = [...contacts];
        if (updatedContact.isLiked) {
          for (var i = 0; i < updatedContacts.length; i++) {
            if (i != index) {
              updatedContacts[i] = updatedContacts[i].copyWith(isLiked: false);
            }
          }
        }
        updatedContacts[index] = updatedContact;
        state = AsyncValue.data(updatedContacts);
      }
    });
  }
}
