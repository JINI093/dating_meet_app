/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'package:collection/collection.dart';


/** This is an auto generated class representing the Profiles type in your schema. */
class Profiles extends amplify_core.Model {
  static const classType = const _ProfilesModelType();
  final String id;
  final String? _userId;
  final String? _name;
  final int? _age;
  final String? _gender;
  final String? _location;
  final List<String>? _profileImages;
  final String? _bio;
  final String? _occupation;
  final String? _education;
  final int? _height;
  final String? _bodyType;
  final String? _smoking;
  final String? _drinking;
  final String? _religion;
  final String? _mbti;
  final List<String>? _hobbies;
  final List<String>? _badges;
  final bool? _isVip;
  final bool? _isPremium;
  final bool? _isVerified;
  final bool? _isOnline;
  final int? _likeCount;
  final int? _superChatCount;
  final String? _meetingType;
  final String? _incomeCode;
  final amplify_core.TemporalDateTime? _lastSeen;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ProfilesModelIdentifier get modelIdentifier {
      return ProfilesModelIdentifier(
        id: id
      );
  }
  
  String get userId {
    try {
      return _userId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get name {
    try {
      return _name!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int? get age {
    return _age;
  }
  
  String? get gender {
    return _gender;
  }
  
  String? get location {
    return _location;
  }
  
  List<String>? get profileImages {
    return _profileImages;
  }
  
  String? get bio {
    return _bio;
  }
  
  String? get occupation {
    return _occupation;
  }
  
  String? get education {
    return _education;
  }
  
  int? get height {
    return _height;
  }
  
  String? get bodyType {
    return _bodyType;
  }
  
  String? get smoking {
    return _smoking;
  }
  
  String? get drinking {
    return _drinking;
  }
  
  String? get religion {
    return _religion;
  }
  
  String? get mbti {
    return _mbti;
  }
  
  List<String>? get hobbies {
    return _hobbies;
  }
  
  List<String>? get badges {
    return _badges;
  }
  
  bool? get isVip {
    return _isVip;
  }
  
  bool? get isPremium {
    return _isPremium;
  }
  
  bool? get isVerified {
    return _isVerified;
  }
  
  bool? get isOnline {
    return _isOnline;
  }
  
  int? get likeCount {
    return _likeCount;
  }
  
  int? get superChatCount {
    return _superChatCount;
  }
  
  String? get meetingType {
    return _meetingType;
  }
  
  String? get incomeCode {
    return _incomeCode;
  }
  
  amplify_core.TemporalDateTime? get lastSeen {
    return _lastSeen;
  }
  
  amplify_core.TemporalDateTime get createdAt {
    try {
      return _createdAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get updatedAt {
    try {
      return _updatedAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  const Profiles._internal({required this.id, required userId, required name, age, gender, location, profileImages, bio, occupation, education, height, bodyType, smoking, drinking, religion, mbti, hobbies, badges, isVip, isPremium, isVerified, isOnline, likeCount, superChatCount, meetingType, incomeCode, lastSeen, required createdAt, required updatedAt}): _userId = userId, _name = name, _age = age, _gender = gender, _location = location, _profileImages = profileImages, _bio = bio, _occupation = occupation, _education = education, _height = height, _bodyType = bodyType, _smoking = smoking, _drinking = drinking, _religion = religion, _mbti = mbti, _hobbies = hobbies, _badges = badges, _isVip = isVip, _isPremium = isPremium, _isVerified = isVerified, _isOnline = isOnline, _likeCount = likeCount, _superChatCount = superChatCount, _meetingType = meetingType, _incomeCode = incomeCode, _lastSeen = lastSeen, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Profiles({String? id, required String userId, required String name, int? age, String? gender, String? location, List<String>? profileImages, String? bio, String? occupation, String? education, int? height, String? bodyType, String? smoking, String? drinking, String? religion, String? mbti, List<String>? hobbies, List<String>? badges, bool? isVip, bool? isPremium, bool? isVerified, bool? isOnline, int? likeCount, int? superChatCount, String? meetingType, String? incomeCode, amplify_core.TemporalDateTime? lastSeen, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Profiles._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      userId: userId,
      name: name,
      age: age,
      gender: gender,
      location: location,
      profileImages: profileImages != null ? List<String>.unmodifiable(profileImages) : profileImages,
      bio: bio,
      occupation: occupation,
      education: education,
      height: height,
      bodyType: bodyType,
      smoking: smoking,
      drinking: drinking,
      religion: religion,
      mbti: mbti,
      hobbies: hobbies != null ? List<String>.unmodifiable(hobbies) : hobbies,
      badges: badges != null ? List<String>.unmodifiable(badges) : badges,
      isVip: isVip,
      isPremium: isPremium,
      isVerified: isVerified,
      isOnline: isOnline,
      likeCount: likeCount,
      superChatCount: superChatCount,
      meetingType: meetingType,
      incomeCode: incomeCode,
      lastSeen: lastSeen,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Profiles &&
      id == other.id &&
      _userId == other._userId &&
      _name == other._name &&
      _age == other._age &&
      _gender == other._gender &&
      _location == other._location &&
      DeepCollectionEquality().equals(_profileImages, other._profileImages) &&
      _bio == other._bio &&
      _occupation == other._occupation &&
      _education == other._education &&
      _height == other._height &&
      _bodyType == other._bodyType &&
      _smoking == other._smoking &&
      _drinking == other._drinking &&
      _religion == other._religion &&
      _mbti == other._mbti &&
      DeepCollectionEquality().equals(_hobbies, other._hobbies) &&
      DeepCollectionEquality().equals(_badges, other._badges) &&
      _isVip == other._isVip &&
      _isPremium == other._isPremium &&
      _isVerified == other._isVerified &&
      _isOnline == other._isOnline &&
      _likeCount == other._likeCount &&
      _superChatCount == other._superChatCount &&
      _meetingType == other._meetingType &&
      _incomeCode == other._incomeCode &&
      _lastSeen == other._lastSeen &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Profiles {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("age=" + (_age != null ? _age!.toString() : "null") + ", ");
    buffer.write("gender=" + "$_gender" + ", ");
    buffer.write("location=" + "$_location" + ", ");
    buffer.write("profileImages=" + (_profileImages != null ? _profileImages!.toString() : "null") + ", ");
    buffer.write("bio=" + "$_bio" + ", ");
    buffer.write("occupation=" + "$_occupation" + ", ");
    buffer.write("education=" + "$_education" + ", ");
    buffer.write("height=" + (_height != null ? _height!.toString() : "null") + ", ");
    buffer.write("bodyType=" + "$_bodyType" + ", ");
    buffer.write("smoking=" + "$_smoking" + ", ");
    buffer.write("drinking=" + "$_drinking" + ", ");
    buffer.write("religion=" + "$_religion" + ", ");
    buffer.write("mbti=" + "$_mbti" + ", ");
    buffer.write("hobbies=" + (_hobbies != null ? _hobbies!.toString() : "null") + ", ");
    buffer.write("badges=" + (_badges != null ? _badges!.toString() : "null") + ", ");
    buffer.write("isVip=" + (_isVip != null ? _isVip!.toString() : "null") + ", ");
    buffer.write("isPremium=" + (_isPremium != null ? _isPremium!.toString() : "null") + ", ");
    buffer.write("isVerified=" + (_isVerified != null ? _isVerified!.toString() : "null") + ", ");
    buffer.write("isOnline=" + (_isOnline != null ? _isOnline!.toString() : "null") + ", ");
    buffer.write("likeCount=" + (_likeCount != null ? _likeCount!.toString() : "null") + ", ");
    buffer.write("superChatCount=" + (_superChatCount != null ? _superChatCount!.toString() : "null") + ", ");
    buffer.write("meetingType=" + "$_meetingType" + ", ");
    buffer.write("incomeCode=" + "$_incomeCode" + ", ");
    buffer.write("lastSeen=" + (_lastSeen != null ? _lastSeen!.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Profiles copyWith({String? userId, String? name, int? age, String? gender, String? location, List<String>? profileImages, String? bio, String? occupation, String? education, int? height, String? bodyType, String? smoking, String? drinking, String? religion, String? mbti, List<String>? hobbies, List<String>? badges, bool? isVip, bool? isPremium, bool? isVerified, bool? isOnline, int? likeCount, int? superChatCount, String? meetingType, String? incomeCode, amplify_core.TemporalDateTime? lastSeen, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Profiles._internal(
      id: id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      profileImages: profileImages ?? this.profileImages,
      bio: bio ?? this.bio,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      height: height ?? this.height,
      bodyType: bodyType ?? this.bodyType,
      smoking: smoking ?? this.smoking,
      drinking: drinking ?? this.drinking,
      religion: religion ?? this.religion,
      mbti: mbti ?? this.mbti,
      hobbies: hobbies ?? this.hobbies,
      badges: badges ?? this.badges,
      isVip: isVip ?? this.isVip,
      isPremium: isPremium ?? this.isPremium,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      likeCount: likeCount ?? this.likeCount,
      superChatCount: superChatCount ?? this.superChatCount,
      meetingType: meetingType ?? this.meetingType,
      incomeCode: incomeCode ?? this.incomeCode,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Profiles copyWithModelFieldValues({
    ModelFieldValue<String>? userId,
    ModelFieldValue<String>? name,
    ModelFieldValue<int?>? age,
    ModelFieldValue<String?>? gender,
    ModelFieldValue<String?>? location,
    ModelFieldValue<List<String>?>? profileImages,
    ModelFieldValue<String?>? bio,
    ModelFieldValue<String?>? occupation,
    ModelFieldValue<String?>? education,
    ModelFieldValue<int?>? height,
    ModelFieldValue<String?>? bodyType,
    ModelFieldValue<String?>? smoking,
    ModelFieldValue<String?>? drinking,
    ModelFieldValue<String?>? religion,
    ModelFieldValue<String?>? mbti,
    ModelFieldValue<List<String>?>? hobbies,
    ModelFieldValue<List<String>?>? badges,
    ModelFieldValue<bool?>? isVip,
    ModelFieldValue<bool?>? isPremium,
    ModelFieldValue<bool?>? isVerified,
    ModelFieldValue<bool?>? isOnline,
    ModelFieldValue<int?>? likeCount,
    ModelFieldValue<int?>? superChatCount,
    ModelFieldValue<String?>? meetingType,
    ModelFieldValue<String?>? incomeCode,
    ModelFieldValue<amplify_core.TemporalDateTime?>? lastSeen,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Profiles._internal(
      id: id,
      userId: userId == null ? this.userId : userId.value,
      name: name == null ? this.name : name.value,
      age: age == null ? this.age : age.value,
      gender: gender == null ? this.gender : gender.value,
      location: location == null ? this.location : location.value,
      profileImages: profileImages == null ? this.profileImages : profileImages.value,
      bio: bio == null ? this.bio : bio.value,
      occupation: occupation == null ? this.occupation : occupation.value,
      education: education == null ? this.education : education.value,
      height: height == null ? this.height : height.value,
      bodyType: bodyType == null ? this.bodyType : bodyType.value,
      smoking: smoking == null ? this.smoking : smoking.value,
      drinking: drinking == null ? this.drinking : drinking.value,
      religion: religion == null ? this.religion : religion.value,
      mbti: mbti == null ? this.mbti : mbti.value,
      hobbies: hobbies == null ? this.hobbies : hobbies.value,
      badges: badges == null ? this.badges : badges.value,
      isVip: isVip == null ? this.isVip : isVip.value,
      isPremium: isPremium == null ? this.isPremium : isPremium.value,
      isVerified: isVerified == null ? this.isVerified : isVerified.value,
      isOnline: isOnline == null ? this.isOnline : isOnline.value,
      likeCount: likeCount == null ? this.likeCount : likeCount.value,
      superChatCount: superChatCount == null ? this.superChatCount : superChatCount.value,
      meetingType: meetingType == null ? this.meetingType : meetingType.value,
      incomeCode: incomeCode == null ? this.incomeCode : incomeCode.value,
      lastSeen: lastSeen == null ? this.lastSeen : lastSeen.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Profiles.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _userId = json['userId'],
      _name = json['name'],
      _age = (json['age'] as num?)?.toInt(),
      _gender = json['gender'],
      _location = json['location'],
      _profileImages = json['profileImages']?.cast<String>(),
      _bio = json['bio'],
      _occupation = json['occupation'],
      _education = json['education'],
      _height = (json['height'] as num?)?.toInt(),
      _bodyType = json['bodyType'],
      _smoking = json['smoking'],
      _drinking = json['drinking'],
      _religion = json['religion'],
      _mbti = json['mbti'],
      _hobbies = json['hobbies']?.cast<String>(),
      _badges = json['badges']?.cast<String>(),
      _isVip = json['isVip'],
      _isPremium = json['isPremium'],
      _isVerified = json['isVerified'],
      _isOnline = json['isOnline'],
      _likeCount = (json['likeCount'] as num?)?.toInt(),
      _superChatCount = (json['superChatCount'] as num?)?.toInt(),
      _meetingType = json['meetingType'],
      _incomeCode = json['incomeCode'],
      _lastSeen = json['lastSeen'] != null ? amplify_core.TemporalDateTime.fromString(json['lastSeen']) : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'userId': _userId, 'name': _name, 'age': _age, 'gender': _gender, 'location': _location, 'profileImages': _profileImages, 'bio': _bio, 'occupation': _occupation, 'education': _education, 'height': _height, 'bodyType': _bodyType, 'smoking': _smoking, 'drinking': _drinking, 'religion': _religion, 'mbti': _mbti, 'hobbies': _hobbies, 'badges': _badges, 'isVip': _isVip, 'isPremium': _isPremium, 'isVerified': _isVerified, 'isOnline': _isOnline, 'likeCount': _likeCount, 'superChatCount': _superChatCount, 'meetingType': _meetingType, 'incomeCode': _incomeCode, 'lastSeen': _lastSeen?.format(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'userId': _userId,
    'name': _name,
    'age': _age,
    'gender': _gender,
    'location': _location,
    'profileImages': _profileImages,
    'bio': _bio,
    'occupation': _occupation,
    'education': _education,
    'height': _height,
    'bodyType': _bodyType,
    'smoking': _smoking,
    'drinking': _drinking,
    'religion': _religion,
    'mbti': _mbti,
    'hobbies': _hobbies,
    'badges': _badges,
    'isVip': _isVip,
    'isPremium': _isPremium,
    'isVerified': _isVerified,
    'isOnline': _isOnline,
    'likeCount': _likeCount,
    'superChatCount': _superChatCount,
    'meetingType': _meetingType,
    'incomeCode': _incomeCode,
    'lastSeen': _lastSeen,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ProfilesModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ProfilesModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final AGE = amplify_core.QueryField(fieldName: "age");
  static final GENDER = amplify_core.QueryField(fieldName: "gender");
  static final LOCATION = amplify_core.QueryField(fieldName: "location");
  static final PROFILEIMAGES = amplify_core.QueryField(fieldName: "profileImages");
  static final BIO = amplify_core.QueryField(fieldName: "bio");
  static final OCCUPATION = amplify_core.QueryField(fieldName: "occupation");
  static final EDUCATION = amplify_core.QueryField(fieldName: "education");
  static final HEIGHT = amplify_core.QueryField(fieldName: "height");
  static final BODYTYPE = amplify_core.QueryField(fieldName: "bodyType");
  static final SMOKING = amplify_core.QueryField(fieldName: "smoking");
  static final DRINKING = amplify_core.QueryField(fieldName: "drinking");
  static final RELIGION = amplify_core.QueryField(fieldName: "religion");
  static final MBTI = amplify_core.QueryField(fieldName: "mbti");
  static final HOBBIES = amplify_core.QueryField(fieldName: "hobbies");
  static final BADGES = amplify_core.QueryField(fieldName: "badges");
  static final ISVIP = amplify_core.QueryField(fieldName: "isVip");
  static final ISPREMIUM = amplify_core.QueryField(fieldName: "isPremium");
  static final ISVERIFIED = amplify_core.QueryField(fieldName: "isVerified");
  static final ISONLINE = amplify_core.QueryField(fieldName: "isOnline");
  static final LIKECOUNT = amplify_core.QueryField(fieldName: "likeCount");
  static final SUPERCHATCOUNT = amplify_core.QueryField(fieldName: "superChatCount");
  static final MEETINGTYPE = amplify_core.QueryField(fieldName: "meetingType");
  static final INCOMECODE = amplify_core.QueryField(fieldName: "incomeCode");
  static final LASTSEEN = amplify_core.QueryField(fieldName: "lastSeen");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Profiles";
    modelSchemaDefinition.pluralName = "Profiles";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["userId"], name: "byUserId")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.USERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.NAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.AGE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.GENDER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.LOCATION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.PROFILEIMAGES,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.BIO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.OCCUPATION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.EDUCATION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.HEIGHT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.BODYTYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.SMOKING,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.DRINKING,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.RELIGION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.MBTI,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.HOBBIES,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.BADGES,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.ISVIP,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.ISPREMIUM,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.ISVERIFIED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.ISONLINE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.LIKECOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.SUPERCHATCOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.MEETINGTYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.INCOMECODE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.LASTSEEN,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Profiles.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _ProfilesModelType extends amplify_core.ModelType<Profiles> {
  const _ProfilesModelType();
  
  @override
  Profiles fromJson(Map<String, dynamic> jsonData) {
    return Profiles.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Profiles';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Profiles] in your schema.
 */
class ProfilesModelIdentifier implements amplify_core.ModelIdentifier<Profiles> {
  final String id;

  /** Create an instance of ProfilesModelIdentifier using [id] the primary key. */
  const ProfilesModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'ProfilesModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ProfilesModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}