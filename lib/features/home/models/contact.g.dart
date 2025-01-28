// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactImpl _$$ContactImplFromJson(Map<String, dynamic> json) =>
    _$ContactImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      displayPhoneNumber: json['displayPhoneNumber'] as String,
      imageUrl: json['imageUrl'] as String,
      isLiked: json['isLiked'] as bool? ?? false,
      isRegistered: json['isRegistered'] as bool? ?? false,
    );

Map<String, dynamic> _$$ContactImplToJson(_$ContactImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'displayPhoneNumber': instance.displayPhoneNumber,
      'imageUrl': instance.imageUrl,
      'isLiked': instance.isLiked,
      'isRegistered': instance.isRegistered,
    };
