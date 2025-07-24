// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      location: json['location'] as String,
      profileImages: (json['profileImages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      bio: json['bio'] as String?,
      occupation: json['occupation'] as String?,
      education: json['education'] as String?,
      height: (json['height'] as num?)?.toInt(),
      bodyType: json['bodyType'] as String?,
      smoking: json['smoking'] as String?,
      drinking: json['drinking'] as String?,
      religion: json['religion'] as String?,
      mbti: json['mbti'] as String?,
      hobbies: (json['hobbies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isVip: json['isVip'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      distance: (json['distance'] as num?)?.toDouble(),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      superChatCount: (json['superChatCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      gender: json['gender'] as String?,
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'location': instance.location,
      'profileImages': instance.profileImages,
      'bio': instance.bio,
      'occupation': instance.occupation,
      'education': instance.education,
      'height': instance.height,
      'bodyType': instance.bodyType,
      'smoking': instance.smoking,
      'drinking': instance.drinking,
      'religion': instance.religion,
      'mbti': instance.mbti,
      'hobbies': instance.hobbies,
      'badges': instance.badges,
      'isVip': instance.isVip,
      'isPremium': instance.isPremium,
      'isVerified': instance.isVerified,
      'isOnline': instance.isOnline,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'distance': instance.distance,
      'likeCount': instance.likeCount,
      'superChatCount': instance.superChatCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'gender': instance.gender,
    };
