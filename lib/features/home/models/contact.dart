import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact.freezed.dart';
part 'contact.g.dart';

@freezed
class Contact with _$Contact {
  const factory Contact({
    required String id,
    required String name,
    required String phoneNumber,
    required String displayPhoneNumber,
    required String imageUrl,
    @Default(false) bool isLiked,
    @Default(false) bool isRegistered,
  }) = _Contact;

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
}
