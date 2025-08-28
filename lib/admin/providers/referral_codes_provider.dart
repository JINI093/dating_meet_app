import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import 'dart:math';
import '../../models/ReferralCode.dart';

// Provider for referral codes
final referralCodesProvider = StateNotifierProvider<ReferralCodesNotifier, ReferralCodesState>((ref) {
  return ReferralCodesNotifier();
});

// State class
class ReferralCodesState {
  final List<ReferralCode> codes;
  final bool isLoading;
  final String? error;

  ReferralCodesState({
    required this.codes,
    required this.isLoading,
    this.error,
  });

  ReferralCodesState copyWith({
    List<ReferralCode>? codes,
    bool? isLoading,
    String? error,
  }) {
    return ReferralCodesState(
      codes: codes ?? this.codes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier class
class ReferralCodesNotifier extends StateNotifier<ReferralCodesState> {
  ReferralCodesNotifier() : super(ReferralCodesState(codes: [], isLoading: false)) {
    loadReferralCodes();
  }

  // Load all referral codes from AWS
  Future<void> loadReferralCodes() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // AWS에서 추천인 코드 데이터 로드 시도
      try {
        final request = GraphQLRequest<String>(
          document: '''query ListReferralCodes {
            listReferralCodes {
              items {
                id
                referralCode
                recipientUserId
                rewardPoints
                isUsed
                isActive
                createdAt
                updatedAt
              }
            }
          }''',
        );
        final response = await Amplify.API.query(request: request).response;
        
        if (response.data != null && response.errors.isEmpty) {
          // JSON 문자열을 파싱
          final jsonData = json.decode(response.data!);
          final items = jsonData['listReferralCodes']['items'] as List?;
          
          if (items != null) {
            final codes = items
                .map((item) => ReferralCode.fromJson(item as Map<String, dynamic>))
                .toList();
            
            state = state.copyWith(
              codes: codes,
              isLoading: false,
            );
          } else {
            // 데이터가 없으면 빈 리스트
            state = state.copyWith(
              codes: [],
              isLoading: false,
            );
          }
        } else {
          // 데이터가 없으면 빈 리스트
          state = state.copyWith(
            codes: [],
            isLoading: false,
          );
        }
      } catch (e) {
        // AWS 연결 실패 시 빈 리스트 표시
        print('AWS 연결 실패, 빈 테이블 표시: $e');
        state = state.copyWith(
          codes: [],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '추천인 코드를 불러오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Check if referral code is duplicate
  Future<bool> isReferralCodeDuplicate(String referralCode) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''query GetReferralCodeByCode(\$referralCode: String!) {
          listReferralCodes(filter: {referralCode: {eq: \$referralCode}}) {
            items {
              id
              referralCode
            }
          }
        }''',
        variables: {
          'referralCode': referralCode,
        },
      );
      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null && response.errors.isEmpty) {
        final jsonData = json.decode(response.data!);
        final items = jsonData['listReferralCodes']['items'] as List?;
        return items != null && items.isNotEmpty;
      }
      return false;
    } catch (e) {
      print('추천인 코드 중복 검사 실패: $e');
      // 로컬에서도 확인
      return state.codes.any((code) => code.referralCode == referralCode);
    }
  }

  // Generate unique referral code
  Future<String> generateUniqueReferralCode() async {
    String code;
    bool isDuplicate;
    int attempts = 0;
    const maxAttempts = 10;
    
    do {
      code = _generateRandomCode();
      isDuplicate = await isReferralCodeDuplicate(code);
      attempts++;
    } while (isDuplicate && attempts < maxAttempts);
    
    if (attempts >= maxAttempts) {
      throw Exception('고유한 추천인 코드 생성에 실패했습니다. 다시 시도해주세요.');
    }
    
    return code;
  }

  // Generate random referral code
  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Create a new referral code
  Future<void> createReferralCode({
    required String referralCode,
    required String recipientUserId,
    required int rewardPoints,
    bool isActive = true,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 추천인 코드 중복 검사
      if (await isReferralCodeDuplicate(referralCode)) {
        state = state.copyWith(
          isLoading: false,
          error: '이미 존재하는 추천인 코드입니다.',
        );
        return;
      }
      
      final newCode = ReferralCode(
        referralCode: referralCode,
        recipientUserId: recipientUserId,
        rewardPoints: rewardPoints,
        isUsed: false,
        isActive: isActive,
      );
      
      // 먼저 로컬 상태 업데이트
      final updatedCodes = List<ReferralCode>.from([...state.codes, newCode]);
      state = state.copyWith(
        codes: updatedCodes,
        isLoading: false,
      );
      
      // AWS에 저장 시도
      try {
        final request = GraphQLRequest<ReferralCode>(
          document: '''mutation CreateReferralCode(\$input: CreateReferralCodeInput!) {
            createReferralCode(input: \$input) {
              id
              referralCode
              recipientUserId
              rewardPoints
              isUsed
              isActive
              createdAt
              updatedAt
            }
          }''',
          variables: {
            'input': {
              'referralCode': newCode.referralCode,
              'recipientUserId': newCode.recipientUserId,
              'rewardPoints': newCode.rewardPoints,
              'isUsed': newCode.isUsed,
              'isActive': newCode.isActive,
            }
          },
          decodePath: 'createReferralCode',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 저장 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '추천인 코드 생성 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Update an existing referral code
  Future<void> updateReferralCode(ReferralCode referralCode) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 먼저 로컬 상태 업데이트
      final updatedCodes = List<ReferralCode>.from(
        state.codes.map((c) {
          return c.id == referralCode.id ? referralCode : c;
        })
      );
      
      state = state.copyWith(
        codes: updatedCodes,
        isLoading: false,
      );
      
      // AWS에 업데이트 시도
      try {
        final request = GraphQLRequest<ReferralCode>(
          document: '''mutation UpdateReferralCode(\$input: UpdateReferralCodeInput!) {
            updateReferralCode(input: \$input) {
              id
              referralCode
              recipientUserId
              rewardPoints
              isUsed
              isActive
              createdAt
              updatedAt
            }
          }''',
          variables: {
            'input': {
              'id': referralCode.id,
              'referralCode': referralCode.referralCode,
              'recipientUserId': referralCode.recipientUserId,
              'rewardPoints': referralCode.rewardPoints,
              'isUsed': referralCode.isUsed,
              'isActive': referralCode.isActive,
            }
          },
          decodePath: 'updateReferralCode',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 업데이트 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '추천인 코드 수정 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Delete a referral code
  Future<void> deleteReferralCode(String codeId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 먼저 로컬 상태 업데이트
      final updatedCodes = state.codes.where((c) => c.id != codeId).toList();
      state = state.copyWith(
        codes: updatedCodes,
        isLoading: false,
      );
      
      // AWS에서 삭제 시도
      try {
        final request = GraphQLRequest<ReferralCode>(
          document: '''mutation DeleteReferralCode(\$input: DeleteReferralCodeInput!) {
            deleteReferralCode(input: \$input) {
              id
            }
          }''',
          variables: {
            'input': {
              'id': codeId,
            }
          },
          decodePath: 'deleteReferralCode',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 삭제 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '추천인 코드 삭제 중 오류가 발생했습니다: $e',
      );
    }
  }
}