import 'dart:io';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'lib/services/aws_profile_service.dart';
import 'lib/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Amplify가 구성되어 있다고 가정
  await testGenderFiltering();
  exit(0);
}

Future<void> testGenderFiltering() async {
  print('=== DynamoDB Gender 필드 디버깅 테스트 ===');
  
  final profileService = AWSProfileService();
  
  try {
    // 1. gender 필터 없이 모든 프로필 조회
    print('\n1. gender 필터 없이 모든 프로필 조회');
    final allProfiles = await profileService.getDiscoverProfiles(
      currentUserId: 'test_user_123',
      gender: null, // 성별 필터 제거
      minAge: null,
      maxAge: null,
      maxDistance: null,
      location: null,
      limit: 50,
    );
    
    print('총 프로필 수: ${allProfiles.length}');
    
    if (allProfiles.isNotEmpty) {
      print('\n=== 실제 DynamoDB 데이터 분석 ===');
      
      // 성별 분포 분석
      final genderDistribution = <String, int>{};
      for (final profile in allProfiles) {
        final gender = profile.gender ?? 'null/empty';
        genderDistribution[gender] = (genderDistribution[gender] ?? 0) + 1;
      }
      
      print('성별 분포:');
      genderDistribution.forEach((gender, count) {
        print('  $gender: $count명');
      });
      
      // 몇 개 프로필의 상세 정보 출력
      print('\n=== 프로필 상세 정보 (처음 5개) ===');
      for (int i = 0; i < allProfiles.length && i < 5; i++) {
        final profile = allProfiles[i];
        print('프로필 ${i + 1}:');
        print('  ID: ${profile.id}');
        print('  이름: ${profile.name}');
        print('  나이: ${profile.age}');
        print('  성별: "${profile.gender}" (타입: ${profile.gender.runtimeType})');
        print('  성별 길이: ${profile.gender?.length ?? 0}');
        print('  성별이 빈 문자열인가? ${profile.gender == ""}');
        print('  성별이 null인가? ${profile.gender == null}');
        print('  위치: ${profile.location}');
        print('');
      }
    } else {
      print('⚠️ 조회된 프로필이 없습니다.');
    }
    
    // 2. 특정 성별로 필터링 테스트
    print('\n2. 성별 필터링 테스트');
    
    final genderFilters = ['남성', '여성', 'M', 'F', 'male', 'female'];
    
    for (final genderFilter in genderFilters) {
      print('\n성별 필터: "$genderFilter"');
      final filteredProfiles = await profileService.getDiscoverProfiles(
        currentUserId: 'test_user_123',
        gender: genderFilter,
        limit: 10,
      );
      
      print('  결과: ${filteredProfiles.length}개 프로필');
      
      if (filteredProfiles.isNotEmpty) {
        print('  첫 번째 프로필:');
        final first = filteredProfiles.first;
        print('    이름: ${first.name}');
        print('    성별: "${first.gender}"');
      }
    }
    
    // 3. 빈 문자열 성별 필터링 테스트
    print('\n3. 빈 문자열 성별 필터링 테스트');
    final emptyGenderProfiles = await profileService.getDiscoverProfiles(
      currentUserId: 'test_user_123',
      gender: '', // 빈 문자열
      limit: 10,
    );
    print('빈 문자열 필터 결과: ${emptyGenderProfiles.length}개');
    
    // 4. DynamoDB 스캔 테스트 (내부 메서드 호출)
    print('\n4. DynamoDB 직접 스캔 테스트');
    print('다음 단계: AWS Lambda 함수나 GraphQL API의 실제 구현을 확인해야 합니다.');
    print('DynamoDB에서 gender 필드가 어떤 형식으로 저장되어 있는지 확인이 필요합니다.');
    
  } catch (e, stackTrace) {
    print('❌ 테스트 실행 중 오류 발생:');
    print('에러: $e');
    print('스택 트레이스: $stackTrace');
  }
}