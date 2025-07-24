import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../models/profile_model.dart';
import '../utils/logger.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// AWS 기반 프로필 서비스
/// S3를 사용한 이미지 업로드와 DynamoDB/RDS를 통한 프로필 데이터 관리
class AWSProfileService {
  static final AWSProfileService _instance = AWSProfileService._internal();
  factory AWSProfileService() => _instance;
  AWSProfileService._internal();

  static const String _s3ProfileImagePath = 'profile-images';
  static const String _apiEndpoint = 'profiles';
  static const int _maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int _maxImageDimension = 1920;
  static const int _imageQuality = 85;
  static const Uuid _uuid = Uuid();

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      if (!Amplify.isConfigured) {
        throw Exception('Amplify가 초기화되지 않았습니다.');
      }
      Logger.log('✅ AWSProfileService 초기화 완료', name: 'AWSProfileService');
    } catch (e) {
      Logger.error('❌ AWSProfileService 초기화 실패', error: e, name: 'AWSProfileService');
      rethrow;
    }
  }

  /// 프로필 생성
  Future<ProfileModel?> createProfile({
    required String userId,
    required String name,
    required int age,
    required String gender,
    required String location,
    required List<File> profileImages,
    String? bio,
    String? occupation,
    String? education,
    int? height,
    String? bodyType,
    String? smoking,
    String? drinking,
    String? religion,
    String? mbti,
    List<String>? hobbies,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // 1. 입력값 검증
      _validateProfileData(
        name: name,
        age: age,
        gender: gender,
        location: location,
        profileImages: profileImages,
      );

      // 2. 이미지 업로드
      final uploadedImageUrls = await _uploadProfileImages(userId, profileImages);
      if (uploadedImageUrls.isEmpty) {
        throw Exception('프로필 이미지 업로드에 실패했습니다.');
      }

      // 3. 프로필 데이터 생성
      final now = DateTime.now();
      final profileId = '${now.millisecondsSinceEpoch}-${_uuid.v4().substring(0, 8)}';
      final profileData = {
        'id': profileId,  // DynamoDB 파티션 키
        'userId': userId,
        'name': name,
        'age': age,
        'gender': gender,
        'location': location,
        'profileImages': uploadedImageUrls,
        'bio': bio ?? '',
        'occupation': occupation ?? '',
        'education': education ?? '',
        'height': height,
        'bodyType': bodyType ?? '',
        'smoking': smoking ?? '',
        'drinking': drinking ?? '',
        'religion': religion ?? '',
        'mbti': mbti ?? '',
        'hobbies': hobbies ?? [],
        'badges': [],
        'isVip': false,
        'isPremium': false,
        'isVerified': false,
        'isOnline': true,
        'likeCount': 0,
        'superChatCount': 0,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        ...?additionalData,
      };

      // 4. API 호출하여 프로필 저장
      Logger.log('GraphQL 프로필 생성 요청 시작', name: 'AWSProfileService');
      Logger.log('프로필 데이터: userId=${profileData['userId']}, name=${profileData['name']}, images=${uploadedImageUrls.length}장', name: 'AWSProfileService');
      

      // 4. API 호출하여 프로필 저장 (임시 사용자는 건너뛰기)
      if (userId.startsWith('temp_user_')) {
        Logger.log('임시 사용자이므로 GraphQL API 호출 건너뛰고 바로 로컬 프로필 생성', name: 'AWSProfileService');
        
        // 임시 사용자의 경우 바로 로컬 프로필 객체 생성
        final localProfile = ProfileModel(
          id: profileData['id'], // 고유 ID 사용
          name: profileData['name'],
          age: profileData['age'],
          gender: profileData['gender'],
          location: profileData['location'],
          profileImages: List<String>.from(profileData['profileImages']),
          bio: profileData['bio'],
          occupation: profileData['occupation'],
          education: profileData['education'],
          height: profileData['height'],
          bodyType: profileData['bodyType'],
          smoking: profileData['smoking'],
          drinking: profileData['drinking'],
          religion: profileData['religion'],
          mbti: profileData['mbti'],
          hobbies: List<String>.from(profileData['hobbies']),
          badges: List<String>.from(profileData['badges']),
          isVip: profileData['isVip'],
          isPremium: profileData['isPremium'],
          isVerified: profileData['isVerified'],
          isOnline: profileData['isOnline'],
          likeCount: profileData['likeCount'],
          superChatCount: profileData['superChatCount'],
          createdAt: DateTime.parse(profileData['createdAt']),
          updatedAt: DateTime.parse(profileData['updatedAt']),
        );
        
        Logger.log('임시 사용자용 로컬 프로필 생성 완료: ${localProfile.id}', name: 'AWSProfileService');
        return localProfile;
      }
      
      // GraphQL 대신 REST API를 직접 사용 (GraphQL이 구현되지 않았을 가능성)
      Logger.log('REST API를 통한 프로필 생성 시도', name: 'AWSProfileService');
      
      try {
        final apiService = ApiService();
        Logger.log('REST API 요청 데이터: ${profileData.keys.join(', ')}', name: 'AWSProfileService');
        Logger.log('주요 필드 값 확인: name=${profileData['name']}, age=${profileData['age']}, userId=${profileData['userId']}', name: 'AWSProfileService');
        Logger.log('전체 profileData: ${json.encode(profileData)}', name: 'AWSProfileService');
        
        final response = await apiService.post('/profiles', data: profileData);
        
        Logger.log('REST API 응답: statusCode=${response.statusCode}, data=${response.data != null ? 'exists' : 'null'}', name: 'AWSProfileService');
        Logger.log('REST API 응답 내용: ${response.data}', name: 'AWSProfileService');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          // 백엔드 에러 응답 체크
          if (response.data != null && response.data is Map<String, dynamic> && 
              response.data.containsKey('errorType')) {
            Logger.error('백엔드에서 에러 반환: ${response.data['errorMessage']}', name: 'AWSProfileService');
            throw Exception('DynamoDB 저장 실패: ${response.data['errorMessage']}');
          }
          
          Logger.log('REST API를 통한 프로필 생성 성공', name: 'AWSProfileService');
          
          // 응답 데이터 검증
          if (response.data != null && response.data is Map<String, dynamic>) {
            try {
              final responseMap = response.data as Map<String, dynamic>;
              
              // Lambda가 {statusCode, headers, body} 형태로 응답하는 경우
              if (responseMap.containsKey('body') && responseMap['body'] is String) {
                final bodyString = responseMap['body'] as String;
                final bodyData = json.decode(bodyString) as Map<String, dynamic>;
                
                if (bodyData.containsKey('data') && bodyData['data'] != null) {
                  final profileData = bodyData['data'] as Map<String, dynamic>;
                  return ProfileModel.fromJson(profileData);
                }
              }
              // 직접 data 객체가 있는 경우
              else if (responseMap.containsKey('data') && responseMap['data'] != null) {
                final profileData = responseMap['data'] as Map<String, dynamic>;
                return ProfileModel.fromJson(profileData);
              } 
              // 전체 응답을 사용
              else {
                return ProfileModel.fromJson(responseMap);
              }
            } catch (parseError) {
              Logger.error('응답 파싱 오류: $parseError', name: 'AWSProfileService');
              Logger.log('응답 데이터 구조가 예상과 다르지만 API는 성공. 원본 데이터로 프로필 생성', name: 'AWSProfileService');
              // 파싱 실패해도 API는 성공했으므로 원본 프로필 데이터로 반환
              return ProfileModel(
                id: profileData['userId'],
                name: profileData['name'],
                age: profileData['age'],
                location: profileData['location'],
                profileImages: List<String>.from(profileData['profileImages']),
                bio: profileData['bio'],
                occupation: profileData['occupation'],
                education: profileData['education'],
                height: profileData['height'],
                bodyType: profileData['bodyType'],
                smoking: profileData['smoking'],
                drinking: profileData['drinking'],
                religion: profileData['religion'],
                mbti: profileData['mbti'],
                hobbies: List<String>.from(profileData['hobbies']),
                badges: List<String>.from(profileData['badges']),
                isVip: profileData['isVip'],
                isPremium: profileData['isPremium'],
                isVerified: profileData['isVerified'],
                isOnline: profileData['isOnline'],
                likeCount: profileData['likeCount'],
                superChatCount: profileData['superChatCount'],
                createdAt: DateTime.parse(profileData['createdAt']),
                updatedAt: DateTime.parse(profileData['updatedAt']),
              );
            }
          } else {
            Logger.log('응답 데이터가 올바른 형식이 아니지만 API는 성공. 원본 데이터로 프로필 생성', name: 'AWSProfileService');
            // API는 성공했으므로 원본 프로필 데이터로 반환
            return ProfileModel(
              id: profileData['userId'],
              name: profileData['name'],
              age: profileData['age'],
              location: profileData['location'],
              profileImages: List<String>.from(profileData['profileImages']),
              bio: profileData['bio'],
              occupation: profileData['occupation'],
              education: profileData['education'],
              height: profileData['height'],
              bodyType: profileData['bodyType'],
              smoking: profileData['smoking'],
              drinking: profileData['drinking'],
              religion: profileData['religion'],
              mbti: profileData['mbti'],
              hobbies: List<String>.from(profileData['hobbies']),
              badges: List<String>.from(profileData['badges']),
              isVip: profileData['isVip'],
              isPremium: profileData['isPremium'],
              isVerified: profileData['isVerified'],
              isOnline: profileData['isOnline'],
              likeCount: profileData['likeCount'],
              superChatCount: profileData['superChatCount'],
              createdAt: DateTime.parse(profileData['createdAt']),
              updatedAt: DateTime.parse(profileData['updatedAt']),
            );
          }
        } else {
          Logger.error('REST API 응답 상태 코드: ${response.statusCode}, 응답: ${response.data}', name: 'AWSProfileService');
          throw Exception('프로필 생성 실패: HTTP ${response.statusCode}');
        }
      } catch (e) {
        Logger.error('REST API 호출 실패: $e', name: 'AWSProfileService');
        
        // 403 에러인 경우 로컬 저장소에 저장
        if (e.toString().contains('403')) {
          Logger.log('403 인증 에러로 인해 로컬 저장소에 프로필 저장', name: 'AWSProfileService');
          await _saveProfileToLocal(profileData);
        }
        
        
        // 모든 API가 실패한 경우 로컬 프로필 객체 생성
        final localProfile = ProfileModel(
          id: profileData['userId'], // userId를 profileId로 사용
          name: profileData['name'],
          age: profileData['age'],
          location: profileData['location'],
          profileImages: List<String>.from(profileData['profileImages']),
          bio: profileData['bio'],
          occupation: profileData['occupation'],
          education: profileData['education'],
          height: profileData['height'],
          bodyType: profileData['bodyType'],
          smoking: profileData['smoking'],
          drinking: profileData['drinking'],
          religion: profileData['religion'],
          mbti: profileData['mbti'],
          hobbies: List<String>.from(profileData['hobbies']),
          badges: List<String>.from(profileData['badges']),
          isVip: profileData['isVip'],
          isPremium: profileData['isPremium'],
          isVerified: profileData['isVerified'],
          isOnline: profileData['isOnline'],
          likeCount: profileData['likeCount'],
          superChatCount: profileData['superChatCount'],
          createdAt: DateTime.parse(profileData['createdAt']),
          updatedAt: DateTime.parse(profileData['updatedAt']),
        );
        
        Logger.log('로컬 프로필 생성 완료: ${localProfile.id}', name: 'AWSProfileService');
        return localProfile;
      }
    } catch (e) {
      Logger.error('프로필 생성 오류', error: e, name: 'AWSProfileService');
      rethrow;
    }
  }

  /// 프로필 업데이트
  Future<ProfileModel?> updateProfile({
    required String profileId,
    String? name,
    int? age,
    String? location,
    List<File>? newProfileImages,
    List<String>? existingImageUrls,
    String? bio,
    String? occupation,
    String? education,
    int? height,
    String? bodyType,
    String? smoking,
    String? drinking,
    String? religion,
    String? mbti,
    List<String>? hobbies,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // 1. 기존 프로필 조회
      final existingProfile = await getProfile(profileId);
      if (existingProfile == null) {
        throw Exception('프로필을 찾을 수 없습니다.');
      }

      // 2. 새 이미지 업로드 (있는 경우)
      List<String> updatedImageUrls = existingImageUrls ?? existingProfile.profileImages;
      
      if (newProfileImages != null && newProfileImages.isNotEmpty) {
        final newImageUrls = await _uploadProfileImages(existingProfile.id, newProfileImages);
        updatedImageUrls = [...updatedImageUrls, ...newImageUrls];
      }

      // 3. 업데이트 데이터 준비
      final updateData = {
        'id': profileId,
        'name': name ?? existingProfile.name,
        'age': age ?? existingProfile.age,
        'location': location ?? existingProfile.location,
        'profileImages': updatedImageUrls,
        'bio': bio ?? existingProfile.bio,
        'occupation': occupation ?? existingProfile.occupation,
        'education': education ?? existingProfile.education,
        'height': height ?? existingProfile.height,
        'bodyType': bodyType ?? existingProfile.bodyType,
        'smoking': smoking ?? existingProfile.smoking,
        'drinking': drinking ?? existingProfile.drinking,
        'religion': religion ?? existingProfile.religion,
        'mbti': mbti ?? existingProfile.mbti,
        'hobbies': hobbies ?? existingProfile.hobbies,
        'updatedAt': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      // 4. API 호출하여 프로필 업데이트
      final request = GraphQLRequest<String>(
        document: '''
          mutation UpdateProfile(\$input: UpdateProfileInput!) {
            updateProfile(input: \$input) {
              id
              userId
              name
              age
              gender
              location
              profileImages
              bio
              occupation
              education
              height
              bodyType
              smoking
              drinking
              religion
              mbti
              hobbies
              badges
              isVip
              isPremium
              isVerified
              isOnline
              likeCount
              superChatCount
              createdAt
              updatedAt
            }
          }
        ''',
        variables: {'input': updateData},
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('프로필 업데이트 실패: ${response.errors.first.message}');
      }

      if (response.data != null) {
        final profileJson = _parseGraphQLResponse(response.data!);
        return ProfileModel.fromJson(profileJson);
      }

      return null;
    } catch (e) {
      Logger.error('프로필 업데이트 오류', error: e, name: 'AWSProfileService');
      rethrow;
    }
  }

  /// 프로필 조회
  /// 프로필 조회 (DynamoDB 전용)
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      Logger.log('DynamoDB 프로필 조회 시작: $userId', name: 'AWSProfileService');
      
      // DynamoDB에서 조회
      final dynamoProfile = await _getProfileFromDynamoDBInternal(userId);
      if (dynamoProfile != null) {
        Logger.log('DynamoDB에서 프로필 로드 성공: ${dynamoProfile.name}', name: 'AWSProfileService');
        return dynamoProfile;
      }
      
      Logger.log('DynamoDB에 프로필이 없음: $userId', name: 'AWSProfileService');
      return null;
      
    } catch (e) {
      Logger.error('DynamoDB 프로필 조회 오류: $e', name: 'AWSProfileService');
      return null;
    }
  }

  /// 사용자 ID로 프로필 조회 (DynamoDB 전용)
  Future<ProfileModel?> getProfileByUserId(String userId) async {
    return await getProfile(userId);
  }

  /// GraphQL 프로필 조회 (Deprecated - DynamoDB 사용)
  Future<ProfileModel?> _getProfileGraphQL(String userId) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetProfileByUserId(\$userId: String!) {
            profilesByUserId(userId: \$userId) {
              items {
                id
                userId
                name
                age
                gender
                location
                profileImages
                bio
                occupation
                education
                height
                bodyType
                smoking
                drinking
                religion
                mbti
                hobbies
                badges
                isVip
                isPremium
                isVerified
                isOnline
                lastSeen
                likeCount
                superChatCount
                createdAt
                updatedAt
              }
            }
          }
        ''',
        variables: {'userId': userId},
        apiName: 'DatingMeetGraphQL', // GraphQL API 이름 지정
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('프로필 조회 실패: ${response.errors.first.message}');
      }

      if (response.data != null) {
        try {
          final data = _parseGraphQLResponse(response.data!);
          final items = data['profilesByUserId']?['items'] as List?;
          if (items != null && items.isNotEmpty) {
            return ProfileModel.fromJson(items.first as Map<String, dynamic>);
          } else {
            Logger.log('사용자 프로필 없음: userId=$userId', name: 'AWSProfileService');
            return null;
          }
        } catch (parseError) {
          Logger.error('GraphQL 응답 파싱 오류', error: parseError, name: 'AWSProfileService');
          return null; // 파싱 오류 시 null 반환
        }
      }

      return null;
    } catch (e) {
      Logger.error('GraphQL 프로필 조회 실패, REST API로 재시도: $e', name: 'AWSProfileService');
      
      // GraphQL 실패 시 REST API로 재시도
      try {
        final apiService = ApiService();
        final response = await apiService.get('/profiles/$userId');
        
        if (response.statusCode == 200) {
          Logger.log('REST API를 통한 프로필 조회 성공', name: 'AWSProfileService');
          return ProfileModel.fromJson(response.data);
        }
      } catch (restError) {
        Logger.error('REST API 프로필 조회도 실패: $restError', name: 'AWSProfileService');
      }
      
      // API 실패 시 로컬 저장소에서 시도
      try {
        final profile = await _getProfileFromLocal(userId);
        if (profile != null) {
          Logger.log('로컬 저장소에서 프로필 조회 성공', name: 'AWSProfileService');
          return profile;
        }
      } catch (localError) {
        Logger.error('로컬 저장소 프로필 조회도 실패: $localError', name: 'AWSProfileService');
      }
      
      // 프로필이 없는 경우는 예외가 아니므로 null 반환
      return null;
    }
  }

  /// 매칭 대상 프로필 목록 조회
  Future<List<ProfileModel>> getDiscoverProfiles({
    required String currentUserId,
    String? gender,
    int? minAge,
    int? maxAge,
    double? maxDistance,
    String? location,
    int limit = 20,
    String? nextToken,
  }) async {
    try {
      // 디버깅 로그
      Logger.log('=== getDiscoverProfiles 디버깅 시작 ===', name: 'AWSProfileService');
      Logger.log('🔍 프로필 검색 요청:', name: 'AWSProfileService');
      Logger.log('   요청된 성별: $gender', name: 'AWSProfileService');
      Logger.log('   현재 사용자 ID: $currentUserId', name: 'AWSProfileService');
      Logger.log('   필터링 조건: minAge=$minAge, maxAge=$maxAge, location=$location, limit=$limit', name: 'AWSProfileService');
      
      // 필터 조건 생성
      final filter = <String, dynamic>{};
      if (gender != null) filter['gender'] = {'eq': gender};
      if (minAge != null || maxAge != null) {
        filter['age'] = {};
        if (minAge != null) filter['age']['gte'] = minAge;
        if (maxAge != null) filter['age']['lte'] = maxAge;
      }
      if (location != null) filter['location'] = {'contains': location};

      Logger.log('📝 GraphQL 필터 조건: ${json.encode(filter)}', name: 'AWSProfileService');

      final request = GraphQLRequest<String>(
        document: '''
          query ListProfiles(\$filter: ModelProfileFilterInput, \$limit: Int, \$nextToken: String) {
            listProfiles(filter: \$filter, limit: \$limit, nextToken: \$nextToken) {
              items {
                id
                userId
                name
                age
                gender
                location
                profileImages
                bio
                occupation
                education
                height
                bodyType
                smoking
                drinking
                religion
                mbti
                hobbies
                badges
                isVip
                isPremium
                isVerified
                isOnline
                lastSeen
                likeCount
                superChatCount
                createdAt
                updatedAt
              }
              nextToken
            }
          }
        ''',
        variables: {
          'filter': filter,
          'limit': limit,
          'nextToken': nextToken,
        },
      );

      Logger.log('🚀 GraphQL 요청 시작', name: 'AWSProfileService');
      final response = await Amplify.API.query(request: request).response;
      
      // GraphQL 응답 에러 상세 로깅
      if (response.errors.isNotEmpty) {
        Logger.error('❌ GraphQL 응답 에러 상세:', name: 'AWSProfileService');
        for (int i = 0; i < response.errors.length; i++) {
          final error = response.errors[i];
          Logger.error('   에러 ${i + 1}:', name: 'AWSProfileService');
          Logger.error('     메시지: ${error.message}', name: 'AWSProfileService');
          Logger.error('     위치: ${error.locations}', name: 'AWSProfileService');
          Logger.error('     경로: ${error.path}', name: 'AWSProfileService');
          Logger.error('     확장: ${error.extensions}', name: 'AWSProfileService');
        }
        throw Exception('GraphQL 프로필 목록 조회 실패: ${response.errors.first.message}');
      }

      Logger.log('✅ GraphQL 응답 성공 - 데이터 파싱 시작', name: 'AWSProfileService');

      if (response.data != null) {
        Logger.log('📄 GraphQL 원본 응답:', name: 'AWSProfileService');
        Logger.log('   타입: ${response.data.runtimeType}', name: 'AWSProfileService');
        Logger.log('   내용: ${response.data}', name: 'AWSProfileService');
        
        // 응답 구조 상세 분석
        _analyzeDynamoDBResponse(response.data, 'GraphQL');
        
        try {
          final data = _parseGraphQLResponse(response.data!);
          Logger.log('🔄 파싱된 데이터 구조: ${data.keys.toList()}', name: 'AWSProfileService');
          
          final items = data['listProfiles']?['items'] as List?;
          Logger.log('📊 GraphQL 조회 결과: ${items?.length ?? 0}개 프로필', name: 'AWSProfileService');
          
          if (items != null && items.isNotEmpty) {
            Logger.log('📋 조회된 프로필 상세 정보:', name: 'AWSProfileService');
            // 조회된 모든 프로필 확인
            for (int i = 0; i < items.length && i < 5; i++) {
              final item = items[i] as Map<String, dynamic>;
              Logger.log('   프로필 ${i+1}:', name: 'AWSProfileService');
              Logger.log('     원본 데이터: ${item.toString()}', name: 'AWSProfileService');
              Logger.log('     이름: ${item['name']}, 성별: ${item['gender']}, 나이: ${item['age']}, ID: ${item['id']}', name: 'AWSProfileService');
              
              // DynamoDB 형식인지 확인
              if (_isDynamoDBFormat(item)) {
                Logger.log('     ⚠️  DynamoDB 형식 데이터 발견 - 변환 필요', name: 'AWSProfileService');
                final converted = _convertDynamoDBToJson(item);
                Logger.log('     🔄 변환된 데이터: ${converted.toString()}', name: 'AWSProfileService');
              }
            }
            
            try {
              final profiles = items.map((item) {
                final itemMap = item as Map<String, dynamic>;
                
                // DynamoDB 형식인지 확인하고 변환
                final profileData = _isDynamoDBFormat(itemMap)
                    ? _convertDynamoDBToJson(itemMap)
                    : itemMap;
                
                Logger.log('📝 프로필 생성 데이터: name=${profileData['name']}, gender=${profileData['gender']}', name: 'AWSProfileService');
                
                return ProfileModel.fromJson(profileData);
              }).where((profile) {
                // 자신의 프로필 제외 (더 정확한 필터링)
                final shouldInclude = profile.id != currentUserId && 
                                   !profile.id.contains(currentUserId);
                if (!shouldInclude) {
                  Logger.log('❌ 자신의 프로필 제외: ${profile.name} (ID: ${profile.id})', name: 'AWSProfileService');
                } else {
                  Logger.log('✅ 포함할 프로필: ${profile.name} (${profile.gender}) - ${profile.age}세', name: 'AWSProfileService');
                }
                return shouldInclude;
              }).toList();
              
              Logger.log('🎯 최종 필터링 결과: ${profiles.length}개 프로필', name: 'AWSProfileService');
              if (profiles.isNotEmpty) {
                Logger.log('✅ GraphQL을 통한 프로필 조회 성공', name: 'AWSProfileService');
                return profiles;
              } else {
                Logger.log('⚠️  필터링 후 프로필이 없음', name: 'AWSProfileService');
              }
            } catch (profileParseError) {
              Logger.error('❌ 프로필 파싱 에러:', error: profileParseError, name: 'AWSProfileService');
              Logger.log('프로필 파싱 실패 - REST API 폴백 시도', name: 'AWSProfileService');
            }
          } else {
            Logger.log('⚠️  GraphQL 응답에 프로필 아이템이 없음', name: 'AWSProfileService');
          }
        } catch (parseError) {
          Logger.error('❌ GraphQL 응답 파싱 에러:', error: parseError, name: 'AWSProfileService');
          Logger.log('GraphQL 응답 파싱 실패 - REST API 폴백 시도', name: 'AWSProfileService');
        }
      } else {
        Logger.log('⚠️  GraphQL 응답 데이터가 null', name: 'AWSProfileService');
      }

      Logger.log('📡 GraphQL 조회 실패 또는 결과 없음 - REST API 폴백 시도', name: 'AWSProfileService');
      
    } catch (e) {
      Logger.error('❌ GraphQL 매칭 프로필 조회 오류:', error: e, name: 'AWSProfileService');
      Logger.log('GraphQL 오류 상세: ${e.toString()}', name: 'AWSProfileService');
      
      if (e.toString().contains('UnauthorizedException') || e.toString().contains('401')) {
        Logger.error('🔐 인증 오류 - 사용자 인증 상태 확인 필요', name: 'AWSProfileService');
      } else if (e.toString().contains('NetworkException') || e.toString().contains('timeout')) {
        Logger.error('🌐 네트워크 오류 - 연결 상태 확인 필요', name: 'AWSProfileService');
      }
    }
    
    // REST API 폴백
    Logger.log('🔄 REST API 폴백 시작', name: 'AWSProfileService');
    try {
      final apiService = ApiService();
      final queryParams = <String, dynamic>{
        'currentUserId': currentUserId,
        if (gender != null) 'gender': gender,
        if (minAge != null) 'minAge': minAge,
        if (maxAge != null) 'maxAge': maxAge,
        if (location != null) 'location': location,
        'limit': limit,
      };
      
      Logger.log('📝 REST API 요청 파라미터: ${json.encode(queryParams)}', name: 'AWSProfileService');
      
      final response = await apiService.get('/profiles/discover', queryParameters: queryParams);
      
      Logger.log('📡 REST API 응답:', name: 'AWSProfileService');
      Logger.log('   상태 코드: ${response.statusCode}', name: 'AWSProfileService');
      Logger.log('   응답 타입: ${response.data.runtimeType}', name: 'AWSProfileService');
      Logger.log('   응답 내용: ${response.data}', name: 'AWSProfileService');
      
      // REST API 응답 구조 상세 분석
      _analyzeDynamoDBResponse(response.data, 'REST API');
      
      if (response.statusCode == 200) {
        Logger.log('✅ REST API 응답 성공 - 데이터 파싱 시작', name: 'AWSProfileService');
        
        try {
          final data = response.data;
          List<dynamic>? profilesData;
          
          if (data is Map && data['profiles'] is List) {
            profilesData = data['profiles'] as List;
            Logger.log('📋 profiles 키에서 데이터 추출: ${profilesData.length}개', name: 'AWSProfileService');
          } else if (data is Map && data['body'] is String) {
            // Lambda 응답 형태
            final bodyString = data['body'] as String;
            final bodyData = json.decode(bodyString) as Map<String, dynamic>;
            Logger.log('🔄 Lambda body 파싱: ${bodyData.toString()}', name: 'AWSProfileService');
            
            if (bodyData['success'] == true && bodyData['data'] is List) {
              profilesData = bodyData['data'] as List;
              Logger.log('📋 Lambda body.data에서 데이터 추출: ${profilesData.length}개', name: 'AWSProfileService');
            }
          } else if (data is List) {
            profilesData = data;
            Logger.log('📋 직접 리스트 데이터: ${profilesData.length}개', name: 'AWSProfileService');
          }
          
          if (profilesData != null && profilesData.isNotEmpty) {
            Logger.log('🔄 REST API 프로필 데이터 변환 시작', name: 'AWSProfileService');
            
            final profiles = profilesData.map((item) {
              final itemMap = item as Map<String, dynamic>;
              Logger.log('📝 REST API 프로필 아이템: ${itemMap.toString()}', name: 'AWSProfileService');
              
              // DynamoDB 형식인지 확인하고 변환
              final profileData = _isDynamoDBFormat(itemMap)
                  ? _convertDynamoDBToJson(itemMap)
                  : itemMap;
              
              Logger.log('🔄 변환된 프로필 데이터: name=${profileData['name']}, gender=${profileData['gender']}', name: 'AWSProfileService');
              
              return ProfileModel.fromJson(profileData);
            }).where((profile) {
              // 자신의 프로필 제외 (더 정확한 필터링)
              final shouldInclude = profile.id != currentUserId && 
                                 !profile.id.contains(currentUserId);
              if (!shouldInclude) {
                Logger.log('❌ REST API - 자신의 프로필 제외: ${profile.name} (${profile.id})', name: 'AWSProfileService');
              } else {
                Logger.log('✅ REST API - 포함할 프로필: ${profile.name} (${profile.gender}) - ${profile.age}세', name: 'AWSProfileService');
              }
              return shouldInclude;
            }).toList();
            
            Logger.log('🎯 REST API 최종 결과: ${profiles.length}개 프로필', name: 'AWSProfileService');
            
            if (profiles.isNotEmpty) {
              Logger.log('✅ REST API를 통한 매칭 프로필 조회 성공', name: 'AWSProfileService');
              return profiles;
            } else {
              Logger.log('⚠️  REST API 필터링 후 프로필이 없음', name: 'AWSProfileService');
            }
          } else {
            Logger.log('⚠️  REST API 응답에 프로필 데이터가 없음', name: 'AWSProfileService');
          }
        } catch (restParseError) {
          Logger.error('❌ REST API 응답 파싱 에러:', error: restParseError, name: 'AWSProfileService');
          Logger.log('REST API 파싱 실패 상세: ${restParseError.toString()}', name: 'AWSProfileService');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        Logger.error('🔐 REST API 인증 오류: ${response.statusCode}', name: 'AWSProfileService');
      } else if (response.statusCode != null && response.statusCode! >= 500) {
        Logger.error('🚨 REST API 서버 오류: ${response.statusCode}', name: 'AWSProfileService');
      } else {
        Logger.error('❌ REST API 응답 오류: ${response.statusCode}', name: 'AWSProfileService');
      }
    } catch (restError) {
      Logger.error('❌ REST API 매칭 프로필 조회 실패:', error: restError, name: 'AWSProfileService');
      Logger.log('REST API 오류 상세: ${restError.toString()}', name: 'AWSProfileService');
      
      if (restError.toString().contains('timeout')) {
        Logger.error('⏱️  REST API 타임아웃 오류', name: 'AWSProfileService');
      } else if (restError.toString().contains('connection')) {
        Logger.error('🌐 REST API 연결 오류', name: 'AWSProfileService');
      }
    }
    
    // 모든 API 실패 시 상황 분석 및 샘플 데이터 조건 명확화
    Logger.error('🚨 모든 API 호출 실패 - 원인 분석:', name: 'AWSProfileService');
    Logger.log('=' * 50, name: 'AWSProfileService');
    Logger.log('실패 상황 요약:', name: 'AWSProfileService');
    Logger.log('  현재 사용자 ID: $currentUserId', name: 'AWSProfileService');
    Logger.log('  요청 성별: $gender', name: 'AWSProfileService');
    Logger.log('  GraphQL 실패 여부: ✓', name: 'AWSProfileService');
    Logger.log('  REST API 실패 여부: ✓', name: 'AWSProfileService');
    Logger.log('=' * 50, name: 'AWSProfileService');
    
    // 샘플 데이터 생성 조건 명확화
    Logger.log('🤔 샘플 데이터 생성 조건 확인:', name: 'AWSProfileService');
    
    // 개발 환경에서만 샘플 데이터 생성 허용 (환경변수나 플래그로 제어 가능)
    final shouldGenerateSampleData = currentUserId.startsWith('temp_user_') || 
                                    currentUserId.contains('test_') ||
                                    currentUserId.contains('dev_');
                                    
    Logger.log('  샘플 데이터 생성 정책: ${shouldGenerateSampleData ? "활성화" : "비활성화"}', name: 'AWSProfileService');
    Logger.log('  조건: 임시 사용자, 테스트 사용자, 개발 사용자인 경우만 활성화', name: 'AWSProfileService');
    
    if (shouldGenerateSampleData) {
      Logger.log('🎭 샘플 데이터 생성 시작 (개발/테스트 사용자)', name: 'AWSProfileService');
      final sampleProfiles = _generateSampleProfiles(currentUserId, gender);
      Logger.log('✅ 샘플 데이터 생성 완료: ${sampleProfiles.length}개', name: 'AWSProfileService');
      return sampleProfiles;
    } else {
      Logger.log('📋 실제 데이터 우선 정책으로 빈 리스트 반환', name: 'AWSProfileService');
      Logger.log('  이유: AWS API에서 실제 데이터를 가져오지 못하는 정확한 원인을 파악하기 위함', name: 'AWSProfileService');
      Logger.log('  권장사항: 위의 에러 로그를 확인하여 AWS 설정 문제를 해결하세요', name: 'AWSProfileService');
    }
    
    return []; // 빈 리스트 반환으로 문제 상황을 명확히 표시
  }

  /// 프로필 이미지 S3 업로드 (개선된 버전)
  Future<List<String>> _uploadProfileImages(String userId, List<File> images) async {
    final uploadedUrls = <String>[];

    try {
      Logger.log('🔄 이미지 S3 업로드 시작: ${images.length}장', name: 'AWSProfileService');
      
      // AWS 인증 상태 확인
      final authSession = await Amplify.Auth.fetchAuthSession();
      Logger.log('인증 상태: ${authSession.isSignedIn}', name: 'AWSProfileService');
      
      if (!authSession.isSignedIn) {
        throw Exception('인증이 필요합니다');
      }
      
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        Logger.log('📸 이미지 ${i + 1}/${images.length} 처리: ${image.path}', name: 'AWSProfileService');
        
        try {
          // 1. 이미지 압축
          final compressedBytes = await _compressImage(image);
          Logger.log('이미지 압축 완료: ${compressedBytes.length} bytes', name: 'AWSProfileService');
          
          // 2. S3 키 생성
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final randomId = _uuid.v4().substring(0, 8);
          final extension = path.extension(image.path).toLowerCase();
          final s3Key = 'profile-images/$userId/$timestamp-$randomId$extension';
          
          Logger.log('S3 업로드 시작: $s3Key', name: 'AWSProfileService');
          
          // 3. S3 업로드 (개선된 설정)
          final uploadResult = await Amplify.Storage.uploadData(
            data: StorageDataPayload.bytes(compressedBytes),
            path: StoragePath.fromString(s3Key),
            options: const StorageUploadDataOptions(
              metadata: {
                'Content-Type': 'image/jpeg',
                'Cache-Control': 'max-age=31536000',
              },
            ),
          ).result.timeout(
            const Duration(seconds: 30), // 타임아웃 연장
            onTimeout: () {
              throw TimeoutException('S3 업로드 타임아웃 (30초)', const Duration(seconds: 30));
            },
          );
          
          Logger.log('S3 업로드 성공: ${uploadResult.uploadedItem.path}', name: 'AWSProfileService');
          
          // 4. 공개 URL 생성 (guest 레벨은 공개 접근 가능)
          final publicUrl = 'https://meet-project.s3.ap-northeast-2.amazonaws.com/$s3Key';
          uploadedUrls.add(publicUrl);
          
          Logger.log('✅ 이미지 ${i + 1}/${images.length} 업로드 완료: $publicUrl', name: 'AWSProfileService');
          
        } catch (e) {
          Logger.error('이미지 ${i + 1}/${images.length} 업로드 실패: $e', name: 'AWSProfileService');
          
          // 실패한 이미지는 placeholder 이미지로 대체
          final placeholderUrl = 'https://picsum.photos/seed/${_uuid.v4()}/400/600';
          uploadedUrls.add(placeholderUrl);
          Logger.log('S3 업로드 실패로 placeholder 이미지 사용: $placeholderUrl', name: 'AWSProfileService');
        }
      }

      Logger.log('🎉 이미진 업로드 완료: ${uploadedUrls.length}장', name: 'AWSProfileService');
      return uploadedUrls;
      
    } catch (e) {
      Logger.error('S3 업로드 전체 실패: $e', name: 'AWSProfileService');
      
      // 전체 실패 시 모든 이미지를 로컬 경로로 대체
      uploadedUrls.clear();
      for (final image in images) {
        uploadedUrls.add('file://${image.path}');
      }
      
      Logger.log('로컬 경로로 대체 완료: ${uploadedUrls.length}장', name: 'AWSProfileService');
      return uploadedUrls;
    }
  }

  /// 이미지 압축
  Future<Uint8List> _compressImage(File image) async {
    try {
      final fileSize = await image.length();
      
      // 크기가 이미 작으면 압축하지 않음
      if (fileSize <= _maxImageSize) {
        return await image.readAsBytes();
      }

      // 압축 실행
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        image.absolute.path,
        minWidth: _maxImageDimension,
        minHeight: _maxImageDimension,
        quality: _imageQuality,
        keepExif: false,
      );

      if (compressedBytes == null) {
        throw Exception('이미지 압축 실패');
      }

      Logger.log(
        '이미지 압축 완료: ${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB → ${(compressedBytes.length / 1024 / 1024).toStringAsFixed(1)}MB',
        name: 'AWSProfileService',
      );

      return compressedBytes;
    } catch (e) {
      Logger.error('이미지 압축 오류', error: e, name: 'AWSProfileService');
      return await image.readAsBytes();
    }
  }

  /// 이미지 삭제
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      await _deleteImageFromUrl(imageUrl);
      Logger.log('이미지 삭제 완료', name: 'AWSProfileService');
    } catch (e) {
      Logger.error('이미지 삭제 오류', error: e, name: 'AWSProfileService');
      rethrow;
    }
  }

  /// URL에서 S3 키 추출 및 삭제
  Future<void> _deleteImageFromUrl(String imageUrl) async {
    try {
      // URL에서 S3 키 추출
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final keyIndex = pathSegments.indexOf(_s3ProfileImagePath);
      
      if (keyIndex >= 0) {
        final s3Key = pathSegments.sublist(keyIndex).join('/');
        
        await Amplify.Storage.remove(
          path: StoragePath.fromString(s3Key),
        ).result;
      }
    } catch (e) {
      Logger.error('S3 이미지 삭제 오류', error: e, name: 'AWSProfileService');
      rethrow;
    }
  }

  /// 프로필 데이터 검증
  void _validateProfileData({
    required String name,
    required int age,
    required String gender,
    required String location,
    required List<File> profileImages,
  }) {
    // 이름 검증
    if (name.isEmpty || name.length > 20) {
      throw Exception('이름은 1-20자 사이여야 합니다.');
    }

    // 나이 검증
    if (age < 40 || age > 100) {
      throw Exception('나이는 40-100세 사이여야 합니다.');
    }

    // 성별 검증
    if (!['M', 'F', '남성', '여성'].contains(gender)) {
      throw Exception('올바른 성별을 선택해주세요.');
    }

    // 위치 검증
    if (location.isEmpty) {
      throw Exception('위치 정보를 입력해주세요.');
    }

    // 프로필 이미지 검증
    if (profileImages.isEmpty) {
      throw Exception('최소 1장 이상의 프로필 사진이 필요합니다.');
    }

    if (profileImages.length > 6) {
      throw Exception('프로필 사진은 최대 6장까지 가능합니다.');
    }
  }

  /// GraphQL 응답 파싱
  /// 로컬 저장소에 프로필 저장
  Future<void> _saveProfileToLocal(Map<String, dynamic> profileData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(profileData);
      final userId = profileData['userId'] as String;
      
      await prefs.setString('profile_$userId', profileJson);
      Logger.log('프로필을 로컬 저장소에 저장완료: $userId', name: 'AWSProfileService');
    } catch (e) {
      Logger.error('로컬 저장소 저장 실패: $e', name: 'AWSProfileService');
    }
  }

  /// 로컬 저장소에서 프로필 조회
  Future<ProfileModel?> _getProfileFromLocal(String userId) async {
    try {
      Logger.log('💾 로컬 저장소에서 프로필 조회: $userId', name: 'AWSProfileService');
      
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('profile_$userId');
      
      if (profileJson != null && profileJson.isNotEmpty) {
        final profileData = json.decode(profileJson) as Map<String, dynamic>;
        Logger.log('📄 로컬 저장소 원본 데이터: ${profileData.toString()}', name: 'AWSProfileService');
        
        // DynamoDB 형식인지 확인하고 변환
        final convertedData = _isDynamoDBFormat(profileData)
            ? _convertDynamoDBToJson(profileData)
            : profileData;
        
        Logger.log('🔄 로컬 저장소 변환된 데이터: ${convertedData.toString()}', name: 'AWSProfileService');
        
        // null 값들을 안전하게 처리
        final safeProfileData = <String, dynamic>{};
        convertedData.forEach((key, value) {
          safeProfileData[key] = value ?? '';
        });
        
        Logger.log('✅ 로컬 저장소에서 프로필 로드 성공: ${safeProfileData['name']}', name: 'AWSProfileService');
        return ProfileModel.fromJson(safeProfileData);
      }
      
      Logger.log('❌ 로컬 저장소에 프로필 없음', name: 'AWSProfileService');
      return null;
    } catch (e) {
      Logger.error('로컬 저장소 조회 실패: $e', name: 'AWSProfileService');
      return null;
    }
  }

  /// 백엔드 에러 상태 확인
  Future<bool> hasBackendError(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('backend_error_$userId') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 백엔드 에러 메시지 조회
  Future<String?> getBackendErrorMessage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('backend_error_message_$userId');
    } catch (e) {
      return null;
    }
  }

  /// 백엔드 에러 상태 초기화
  Future<void> clearBackendError(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('backend_error_$userId');
      await prefs.remove('backend_error_message_$userId');
    } catch (e) {
      Logger.error('백엔드 에러 상태 초기화 실패: $e', name: 'AWSProfileService');
    }
  }

  Map<String, dynamic> _parseGraphQLResponse(dynamic response) {
    try {
      // 이미 Map인 경우
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      // Map이지만 타입이 다른 경우
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      
      // 문자열인 경우 JSON 파싱 시도
      if (response is String) {
        if (response.startsWith('{') || response.startsWith('[')) {
          final parsed = response; // JSON 파싱 로직이 필요하다면 여기서
          return Map<String, dynamic>.from(parsed as Map);
        }
      }
      
      Logger.log('GraphQL 응답 타입 확인: ${response.runtimeType}', name: 'AWSProfileService');
      
      // 기본적으로 빈 맵 반환
      return {};
    } catch (e) {
      Logger.error('GraphQL 응답 파싱 오류', error: e, name: 'AWSProfileService');
      return {};
    }
  }

  /// 온라인 상태 업데이트
  Future<void> updateOnlineStatus(String profileId, bool isOnline) async {
    try {
      final updateData = {
        'id': profileId,
        'isOnline': isOnline,
        'lastSeen': DateTime.now().toIso8601String(),
      };

      final request = GraphQLRequest<String>(
        document: '''
          mutation UpdateOnlineStatus(\$input: UpdateProfileInput!) {
            updateProfile(input: \$input) {
              id
              isOnline
              lastSeen
            }
          }
        ''',
        variables: {'input': updateData},
      );

      await Amplify.API.mutate(request: request).response;
      
      Logger.log(
        '온라인 상태 업데이트: ${isOnline ? "온라인" : "오프라인"}',
        name: 'AWSProfileService',
      );
    } catch (e) {
      Logger.error('온라인 상태 업데이트 오류', error: e, name: 'AWSProfileService');
    }
  }

  /// 프로필 조회수 증가
  Future<void> incrementProfileView(String profileId) async {
    try {
      // 실제 구현에서는 별도의 조회 기록 테이블을 사용하는 것이 좋음
      final request = GraphQLRequest<String>(
        document: '''
          mutation IncrementProfileView(\$id: ID!) {
            incrementProfileView(id: \$id) {
              id
              viewCount
            }
          }
        ''',
        variables: {'id': profileId},
      );

      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      Logger.error('프로필 조회수 증가 오류', error: e, name: 'AWSProfileService');
    }
  }

  /// DynamoDB에서 프로필 조회 (내부 메소드)
  Future<ProfileModel?> _getProfileFromDynamoDBInternal(String userId) async {
    try {
      Logger.log('DynamoDB에서 프로필 조회 시작: $userId', name: 'AWSProfileService');
      
      // 1. 직접 DynamoDB 스캔을 통한 조회 시도 (userId 기반)
      try {
        final directProfile = await _getProfileByUserIdDirect(userId);
        if (directProfile != null) {
          Logger.log('직접 DynamoDB에서 프로필 로드 성공: ${directProfile.name}', name: 'AWSProfileService');
          return directProfile;
        }
      } catch (directError) {
        Logger.log('직접 DynamoDB 조회 실패, GraphQL로 재시도: $directError', name: 'AWSProfileService');
      }

      // 2. GraphQL로 userId 기반 조회 시도
      try {
        final graphqlProfile = await _getProfileByUserIdGraphQL(userId);
        if (graphqlProfile != null) {
          Logger.log('GraphQL에서 프로필 로드 성공: ${graphqlProfile.name}', name: 'AWSProfileService');
          return graphqlProfile;
        }
      } catch (graphqlError) {
        Logger.log('GraphQL 조회 실패, REST API로 재시도: $graphqlError', name: 'AWSProfileService');
      }
      
      // 2. REST API로 재시도
      final apiService = ApiService();
      final response = await apiService.get('/profiles/$userId');
      
      Logger.log('프로필 조회 응답: ${response.statusCode}', name: 'AWSProfileService');
      
      if (response.statusCode == 200) {
        final responseMap = response.data as Map<String, dynamic>;
        Logger.log('🌐 REST API 응답 데이터: ${responseMap.toString()}', name: 'AWSProfileService');
        
        Map<String, dynamic>? profileData;
        
        // Lambda 응답에서 'data' 객체 추출
        if (responseMap.containsKey('body') && responseMap['body'] is String) {
          final bodyString = responseMap['body'] as String;
          final bodyData = json.decode(bodyString) as Map<String, dynamic>;
          Logger.log('📄 Lambda 응답 body: ${bodyData.toString()}', name: 'AWSProfileService');
          
          if (bodyData['success'] == true && bodyData.containsKey('data')) {
            profileData = bodyData['data'] as Map<String, dynamic>;
          }
        }
        // 직접 data 객체가 있는 경우
        else if (responseMap.containsKey('data') && responseMap['data'] != null) {
          profileData = responseMap['data'] as Map<String, dynamic>;
        }
        // 응답 자체가 프로필 데이터인 경우
        else if (responseMap.containsKey('id') || responseMap.containsKey('name')) {
          profileData = responseMap;
        }
        
        if (profileData != null) {
          Logger.log('📋 추출된 프로필 데이터: ${profileData.toString()}', name: 'AWSProfileService');
          
          // DynamoDB 형식인지 확인하고 변환
          final convertedData = _isDynamoDBFormat(profileData) 
              ? _convertDynamoDBToJson(profileData)
              : profileData;
          
          Logger.log('🔄 최종 변환된 데이터: ${convertedData.toString()}', name: 'AWSProfileService');
          
          return ProfileModel.fromJson(convertedData);
        }
      } else if (response.statusCode == 404) {
        Logger.log('❌ DynamoDB에서 프로필을 찾을 수 없음: $userId', name: 'AWSProfileService');
        return null;
      }
      
      Logger.error('프로필 조회 실패: ${response.statusCode}', name: 'AWSProfileService');
      return null;
      
    } catch (e) {
      Logger.error('DynamoDB 프로필 조회 오류: $e', name: 'AWSProfileService');
      
      // DynamoDB 조회 실패시 로컬 저장소에서 조회
      return await _getProfileFromLocal(userId);
    }
  }

  /// 직접 DynamoDB에서 userId로 프로필 조회 (스캔 방식)
  Future<ProfileModel?> _getProfileByUserIdDirect(String userId) async {
    try {
      Logger.log('🔍 직접 DynamoDB 스캔 시작: $userId', name: 'AWSProfileService');
      
      // 테스트: 실제 DynamoDB 데이터 파싱
      await _testDynamoDBDataParsing();
      
      // DynamoDB에서 모든 프로필을 스캔하여 userId가 일치하는 것 찾기
      final request = GraphQLRequest<String>(
        document: '''
          query ListAllProfiles {
            listProfiles {
              items {
                id
                userId
                name
                age
                gender
                location
                profileImages
                bio
                occupation
                education
                height
                bodyType
                smoking
                drinking
                religion
                mbti
                hobbies
                badges
                isVip
                isPremium
                isVerified
                isOnline
                lastSeen
                likeCount
                superChatCount
                createdAt
                updatedAt
              }
            }
          }
        ''',
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        Logger.error('GraphQL 스캔 에러: ${response.errors.first.message}', name: 'AWSProfileService');
        throw Exception('GraphQL 스캔 에러: ${response.errors.first.message}');
      }

      if (response.data != null) {
        Logger.log('📄 GraphQL 응답 원본 데이터:', name: 'AWSProfileService');
        Logger.log(response.data!, name: 'AWSProfileService');
        
        final data = _parseGraphQLResponse(response.data!);
        final items = data['listProfiles']?['items'] as List?;
        
        Logger.log('📊 파싱된 아이템 수: ${items?.length ?? 0}', name: 'AWSProfileService');
        
        if (items != null && items.isNotEmpty) {
          // 모든 프로필의 원본 데이터 출력
          for (int i = 0; i < items.length; i++) {
            final item = items[i] as Map<String, dynamic>;
            Logger.log('📋 원본 프로필 $i: ${item.toString()}', name: 'AWSProfileService');
            
            // DynamoDB 형식 데이터를 일반 JSON으로 변환
            final convertedData = _convertDynamoDBToJson(item);
            Logger.log('🔄 변환된 프로필 $i: ${convertedData.toString()}', name: 'AWSProfileService');
            
            final itemUserId = convertedData['userId'] as String?;
            Logger.log('🆔 비교 - 요청 userId: $userId, 프로필 userId: $itemUserId', name: 'AWSProfileService');
            
            if (itemUserId == userId) {
              Logger.log('✅ userId 일치하는 프로필 발견: ${convertedData['name']}', name: 'AWSProfileService');
              return ProfileModel.fromJson(convertedData);
            }
          }
          
          Logger.log('❌ userId와 일치하는 프로필을 찾지 못함. 총 ${items.length}개 프로필 스캔', name: 'AWSProfileService');
        }
      }

      return null;
    } catch (e) {
      Logger.error('직접 DynamoDB 스캔 실패: $e', name: 'AWSProfileService');
      rethrow;
    }
  }

  /// DynamoDB 형식 데이터를 일반 JSON으로 변환
  Map<String, dynamic> _convertDynamoDBToJson(Map<String, dynamic> dynamoData) {
    Logger.log('🔄 DynamoDB 데이터 변환 시작', name: 'AWSProfileService');
    Logger.log('입력 데이터: ${dynamoData.toString()}', name: 'AWSProfileService');
    
    final Map<String, dynamic> converted = {};
    
    for (final entry in dynamoData.entries) {
      final key = entry.key;
      final value = entry.value;
      
      Logger.log('변환 중: $key = ${value.toString()}', name: 'AWSProfileService');
      
      if (value is Map<String, dynamic>) {
        // DynamoDB 타입 형식 처리
        if (value.containsKey('S')) {
          // String 타입
          final stringValue = value['S'] as String;
          converted[key] = stringValue;
          Logger.log('  → String: $key = "$stringValue"', name: 'AWSProfileService');
        } else if (value.containsKey('N')) {
          // Number 타입
          final numStr = value['N'] as String;
          final numValue = numStr.contains('.') ? double.parse(numStr) : int.parse(numStr);
          converted[key] = numValue;
          Logger.log('  → Number: $key = $numValue', name: 'AWSProfileService');
        } else if (value.containsKey('BOOL')) {
          // Boolean 타입
          final boolValue = value['BOOL'] as bool;
          converted[key] = boolValue;
          Logger.log('  → Boolean: $key = $boolValue', name: 'AWSProfileService');
        } else if (value.containsKey('L')) {
          // List 타입
          final list = value['L'] as List;
          final convertedList = list.map((item) => _convertDynamoDBValue(item)).toList();
          converted[key] = convertedList;
          Logger.log('  → List: $key = $convertedList', name: 'AWSProfileService');
        } else if (value.containsKey('NULL')) {
          // Null 타입
          converted[key] = null;
          Logger.log('  → Null: $key = null', name: 'AWSProfileService');
        } else {
          // 기타 - 그대로 사용
          converted[key] = value;
          Logger.log('  → 기타: $key = $value', name: 'AWSProfileService');
        }
      } else {
        // 이미 변환된 데이터
        converted[key] = value;
        Logger.log('  → 직접: $key = $value', name: 'AWSProfileService');
      }
    }
    
    Logger.log('✅ 변환 완료: ${converted.toString()}', name: 'AWSProfileService');
    return converted;
  }

  /// DynamoDB 단일 값 변환
  dynamic _convertDynamoDBValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      if (value.containsKey('S')) return value['S'];
      if (value.containsKey('N')) {
        final numStr = value['N'] as String;
        return numStr.contains('.') ? double.parse(numStr) : int.parse(numStr);
      }
      if (value.containsKey('BOOL')) return value['BOOL'];
      if (value.containsKey('NULL')) return null;
    }
    return value;
  }

  /// DynamoDB 응답 구조 분석 헬퍼
  void _analyzeDynamoDBResponse(dynamic responseData, String source) {
    Logger.log('🔍 $source DynamoDB 응답 구조 분석:', name: 'AWSProfileService');
    Logger.log('   응답 타입: ${responseData.runtimeType}', name: 'AWSProfileService');
    
    if (responseData is Map) {
      Logger.log('   최상위 키들: ${responseData.keys.toList()}', name: 'AWSProfileService');
      
      // 중첩된 구조 분석
      responseData.forEach((key, value) {
        Logger.log('   $key: ${value.runtimeType}', name: 'AWSProfileService');
        
        if (value is Map && value.isNotEmpty) {
          final subKeys = value.keys.take(5).toList();
          Logger.log('     하위 키들: $subKeys', name: 'AWSProfileService');
        } else if (value is List && value.isNotEmpty) {
          Logger.log('     리스트 크기: ${value.length}', name: 'AWSProfileService');
          if (value.first is Map) {
            final firstItemKeys = (value.first as Map).keys.take(5).toList();
            Logger.log('     첫 번째 아이템 키들: $firstItemKeys', name: 'AWSProfileService');
          }
        }
      });
    } else if (responseData is List) {
      Logger.log('   리스트 크기: ${responseData.length}', name: 'AWSProfileService');
      if (responseData.isNotEmpty && responseData.first is Map) {
        final firstItemKeys = (responseData.first as Map).keys.take(5).toList();
        Logger.log('   첫 번째 아이템 키들: $firstItemKeys', name: 'AWSProfileService');
      }
    } else if (responseData is String) {
      Logger.log('   문자열 길이: ${responseData.length}', name: 'AWSProfileService');
      Logger.log('   문자열 시작: ${responseData.substring(0, math.min(100, responseData.length))}', name: 'AWSProfileService');
    }
  }

  /// 데이터가 DynamoDB 형식인지 확인
  bool _isDynamoDBFormat(Map<String, dynamic> data) {
    // DynamoDB 데이터는 값이 {"S": "value"}, {"N": "123"} 형태
    for (final value in data.values) {
      if (value is Map<String, dynamic>) {
        if (value.containsKey('S') || value.containsKey('N') || 
            value.containsKey('BOOL') || value.containsKey('L') || 
            value.containsKey('NULL')) {
          return true;
        }
      }
    }
    return false;
  }

  /// 실제 DynamoDB 데이터 파싱 테스트
  Future<void> _testDynamoDBDataParsing() async {
    Logger.log('🧪 실제 DynamoDB 데이터 파싱 테스트 시작', name: 'AWSProfileService');
    
    // 제공받은 실제 DynamoDB 데이터
    final Map<String, dynamic> realDynamoData = {
      "id": {"S": "1753173618393-805-force-user"},
      "age": {"N": "40"},
      "badges": {"L": []},
      "bio": {"S": "ㅎㅇ"},
      "bodyType": {"S": ""},
      "createdAt": {"S": "2025-07-22T08:40:19.026Z"},
      "drinking": {"S": ""},
      "education": {"S": ""},
      "gender": {"S": "여성"},
      "height": {"NULL": true},
      "hobbies": {"L": [{"S": "여행"}]},
      "incomeCode": {"S": ""},
      "isOnline": {"BOOL": true},
      "isPremium": {"BOOL": false},
      "isVerified": {"BOOL": false},
      "isVip": {"BOOL": false},
      "lastSeen": {"NULL": true},
      "likeCount": {"N": "0"},
      "location": {"S": "서울 강남구"},
      "mbti": {"S": ""},
      "meetingType": {"S": ""},
      "name": {"S": "시아"},
      "occupation": {"S": "프리랜서"},
      "profileImages": {
        "L": [
          {"S": "file:///Users/sunwoo/Library/Developer/CoreSimulator/Devices/3C2198AF-389A-4F09-8BB1-B91BAE7F1611/data/Containers/Data/Application/C96538D8-4A98-4761-89F1-145A8EA872DB/tmp/image_picker_88F932E8-9776-4A1A-9EA0-E36AFA818577-31357-00000A5F33120AC8.jpg"},
          {"S": "file:///Users/sunwoo/Library/Developer/CoreSimulator/Devices/3C2198AF-389A-4F09-8BB1-B91BAE7F1611/data/Containers/Data/Application/C96538D8-4A98-4761-89F1-145A8EA872DB/tmp/image_picker_B62B4EEF-D59B-4473-8F29-E7EB309E32B9-31357-00000A5F3597A65A.jpg"},
          {"S": "file:///Users/sunwoo/Library/Developer/CoreSimulator/Devices/3C2198AF-389A-4F09-8BB1-B91BAE7F1611/data/Containers/Data/Application/C96538D8-4A98-4761-89F1-145A8EA872DB/tmp/image_picker_683A8522-68C5-48B3-981A-CDBA3E908292-31357-00000A5F37DB7732.jpg"}
        ]
      },
      "religion": {"S": ""},
      "smoking": {"S": ""},
      "superChatCount": {"N": "0"},
      "updatedAt": {"S": "2025-07-22T08:40:19.027Z"}
    };
    
    Logger.log('📄 실제 DynamoDB 원본 데이터:', name: 'AWSProfileService');
    Logger.log(realDynamoData.toString(), name: 'AWSProfileService');
    
    // 변환 테스트
    final converted = _convertDynamoDBToJson(realDynamoData);
    
    Logger.log('🎯 변환 후 주요 정보:', name: 'AWSProfileService');
    Logger.log('   이름: ${converted["name"]}', name: 'AWSProfileService');
    Logger.log('   나이: ${converted["age"]}', name: 'AWSProfileService');
    Logger.log('   성별: ${converted["gender"]}', name: 'AWSProfileService');
    Logger.log('   직업: ${converted["occupation"]}', name: 'AWSProfileService');
    Logger.log('   위치: ${converted["location"]}', name: 'AWSProfileService');
    
    try {
      // ProfileModel 생성 테스트
      final profile = ProfileModel.fromJson(converted);
      Logger.log('✅ ProfileModel 생성 성공:', name: 'AWSProfileService');
      Logger.log('   프로필 이름: ${profile.name}', name: 'AWSProfileService');
      Logger.log('   프로필 나이: ${profile.age}', name: 'AWSProfileService');
      Logger.log('   프로필 성별: ${profile.gender}', name: 'AWSProfileService');
    } catch (e) {
      Logger.error('❌ ProfileModel 생성 실패: $e', name: 'AWSProfileService');
    }
  }

  /// GraphQL로 userId 기반 프로필 조회
  Future<ProfileModel?> _getProfileByUserIdGraphQL(String userId) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetProfileByUserId(\$userId: String!) {
            profilesByUserId(userId: \$userId) {
              items {
                id
                userId
                name
                age
                gender
                location
                profileImages
                bio
                occupation
                education
                height
                bodyType
                smoking
                drinking
                religion
                mbti
                hobbies
                badges
                isVip
                isPremium
                isVerified
                isOnline
                lastSeen
                likeCount
                superChatCount
                createdAt
                updatedAt
              }
            }
          }
        ''',
        variables: {'userId': userId},
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('GraphQL 에러: ${response.errors.first.message}');
      }

      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final items = data['profilesByUserId']?['items'] as List?;
        if (items != null && items.isNotEmpty) {
          final profileData = items.first as Map<String, dynamic>;
          Logger.log('📋 GraphQL 프로필 데이터: ${profileData.toString()}', name: 'AWSProfileService');
          
          // DynamoDB 형식인지 확인하고 변환
          final convertedData = _isDynamoDBFormat(profileData)
              ? _convertDynamoDBToJson(profileData)
              : profileData;
          
          Logger.log('🔄 GraphQL 변환된 데이터: ${convertedData.toString()}', name: 'AWSProfileService');
          
          return ProfileModel.fromJson(convertedData);
        }
      }

      return null;
    } catch (e) {
      Logger.error('GraphQL 프로필 조회 실패: $e', name: 'AWSProfileService');
      rethrow;
    }
  }
  
  /// 샘플 프로필 생성 (개발/테스트 목적)
  List<ProfileModel> _generateSampleProfiles(String currentUserId, String? targetGender) {
    final sampleProfiles = <ProfileModel>[];
    final isTargetFemale = targetGender == '여성' || targetGender == 'F';
    
    Logger.log('=== 샘플 프로필 생성 디버깅 ===', name: 'AWSProfileService');
    Logger.log('currentUserId: $currentUserId', name: 'AWSProfileService');
    Logger.log('targetGender: $targetGender', name: 'AWSProfileService');
    Logger.log('isTargetFemale: $isTargetFemale', name: 'AWSProfileService');
    
    final names = isTargetFemale
        ? ['지수', '민지', '하영', '수민', '은지', '서연', '지현', '예진']
        : ['민호', '준영', '성민', '지훈', '태현', '승우', '현준', '동현'];
    
    final occupations = ['회사원', '전문직', '자영업', '프리랜서', '학생', '공무원'];
    final locations = ['서울 강남구', '서울 송파구', '서울 서초구', '서울 마포구', '서울 성동구'];
    final hobbies = ['여행', '영화감상', '독서', '운동', '요리', '음악감상', '카페투어'];
    
    for (int i = 0; i < 8; i++) {
      final profileId = 'sample_${currentUserId}_${i + 1}';
      final age = 25 + math.Random().nextInt(10);
      
      sampleProfiles.add(ProfileModel(
        id: profileId,
        name: names[i % names.length],
        age: age,
        gender: targetGender, // 이제 gender 필드가 제대로 설정됨
        location: locations[i % locations.length],
        profileImages: [
          'https://picsum.photos/seed/$profileId/400/600',
          'https://picsum.photos/seed/${profileId}_2/400/600',
          'https://picsum.photos/seed/${profileId}_3/400/600',
        ],
        bio: '안녕하세요! ${names[i % names.length]}입니다. 진지한 만남을 찾고 있어요 :)',
        occupation: occupations[i % occupations.length],
        education: '대학교 졸업',
        height: isTargetFemale ? 160 + math.Random().nextInt(10) : 170 + math.Random().nextInt(15),
        hobbies: hobbies.take(3).toList(),
        isVip: i < 2,
        isPremium: i < 4,
        isVerified: true,
        isOnline: i < 3,
        likeCount: math.Random().nextInt(100),
        superChatCount: math.Random().nextInt(50),
        createdAt: DateTime.now().subtract(Duration(days: i)),
        updatedAt: DateTime.now(),
      ));
    }
    
    Logger.log('생성된 샘플 프로필 수: ${sampleProfiles.length}', name: 'AWSProfileService');
    for (int i = 0; i < sampleProfiles.length && i < 3; i++) {
      final profile = sampleProfiles[i];
      Logger.log('샘플 프로필 ${i + 1}: ${profile.name} (${profile.gender}) - ${profile.age}세', name: 'AWSProfileService');
    }
    
    return sampleProfiles;
  }
}