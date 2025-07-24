import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/point_model.dart';
import '../utils/logger.dart';

/// AWS 기반 포인트 관리 서비스
/// DynamoDB를 통한 포인트 잔액 및 거래 내역 관리
class AWSPointsService {
  static final AWSPointsService _instance = AWSPointsService._internal();
  factory AWSPointsService() => _instance;
  AWSPointsService._internal();

  static const int _dailyLoginBonus = 10;
  static const int _profileCompletionBonus = 100;
  static const String _lastLoginDateKey = 'last_login_date';
  static const String _profileCompletionRewardKey = 'profile_completion_reward_given';

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      if (!Amplify.isConfigured) {
        throw Exception('Amplify가 초기화되지 않았습니다.');
      }
      Logger.log('✅ AWSPointsService 초기화 완료', name: 'AWSPointsService');
    } catch (e) {
      Logger.error('❌ AWSPointsService 초기화 실패', error: e, name: 'AWSPointsService');
      rethrow;
    }
  }

  /// 사용자 포인트 잔액 조회
  Future<UserPointsModel?> getUserPoints(String userId) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetUserPoints(\$userId: String!) {
            getUserPoints(userId: \$userId) {
              userId
              totalPoints
              availablePoints
              pendingPoints
              usedPoints
              lastUpdated
            }
          }
        ''',
        variables: {'userId': userId},
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        Logger.error('포인트 조회 실패: ${response.errors.first.message}', name: 'AWSPointsService');
        return null;
      }

      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final pointsData = data['getUserPoints'];
        if (pointsData != null) {
          return UserPointsModel.fromJson(pointsData);
        }
      }

      return null;
    } catch (e) {
      Logger.error('포인트 조회 오류', error: e, name: 'AWSPointsService');
      return null;
    }
  }

  /// 사용자 포인트 잔액 생성 또는 업데이트
  Future<UserPointsModel?> createOrUpdateUserPoints({
    required String userId,
    int totalPoints = 0,
    int availablePoints = 0,
    int pendingPoints = 0,
    int usedPoints = 0,
  }) async {
    try {
      final now = DateTime.now();
      final pointsData = {
        'userId': userId,
        'totalPoints': totalPoints,
        'availablePoints': availablePoints,
        'pendingPoints': pendingPoints,
        'usedPoints': usedPoints,
        'lastUpdated': now.toIso8601String(),
      };

      final request = GraphQLRequest<String>(
        document: '''
          mutation CreateOrUpdateUserPoints(\$input: UserPointsInput!) {
            createOrUpdateUserPoints(input: \$input) {
              userId
              totalPoints
              availablePoints
              pendingPoints
              usedPoints
              lastUpdated
            }
          }
        ''',
        variables: {'input': pointsData},
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('포인트 업데이트 실패: ${response.errors.first.message}');
      }

      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final pointsData = data['createOrUpdateUserPoints'];
        if (pointsData != null) {
          return UserPointsModel.fromJson(pointsData);
        }
      }

      return null;
    } catch (e) {
      Logger.error('포인트 업데이트 오류', error: e, name: 'AWSPointsService');
      rethrow;
    }
  }

  /// 포인트 추가
  Future<bool> addPoints({
    required String userId,
    required int amount,
    required PointTransactionType type,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 1. 현재 포인트 잔액 조회
      final currentPoints = await getUserPoints(userId);
      if (currentPoints == null) {
        // 포인트 계정이 없으면 생성
        await createOrUpdateUserPoints(
          userId: userId,
          totalPoints: amount,
          availablePoints: amount,
        );
      } else {
        // 기존 계정에 포인트 추가
        await createOrUpdateUserPoints(
          userId: userId,
          totalPoints: currentPoints.totalPoints + amount,
          availablePoints: currentPoints.availablePoints + amount,
          pendingPoints: currentPoints.pendingPoints,
          usedPoints: currentPoints.usedPoints,
        );
      }

      // 2. 거래 기록 생성
      await _createPointTransaction(
        userId: userId,
        amount: amount,
        type: type,
        description: description,
        metadata: metadata,
      );

      Logger.log('포인트 추가 완료: $userId (+$amount)', name: 'AWSPointsService');
      return true;
    } catch (e) {
      Logger.error('포인트 추가 오류', error: e, name: 'AWSPointsService');
      return false;
    }
  }

  /// 포인트 차감
  Future<bool> deductPoints({
    required String userId,
    required int amount,
    required PointTransactionType type,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 1. 현재 포인트 잔액 조회
      final currentPoints = await getUserPoints(userId);
      if (currentPoints == null || !currentPoints.canAfford(amount)) {
        throw Exception('포인트가 부족합니다. 필요: $amount, 보유: ${currentPoints?.availablePoints ?? 0}');
      }

      // 2. 포인트 차감
      await createOrUpdateUserPoints(
        userId: userId,
        totalPoints: currentPoints.totalPoints,
        availablePoints: currentPoints.availablePoints - amount,
        pendingPoints: currentPoints.pendingPoints,
        usedPoints: currentPoints.usedPoints + amount,
      );

      // 3. 거래 기록 생성 (음수로 기록)
      await _createPointTransaction(
        userId: userId,
        amount: -amount,
        type: type,
        description: description,
        metadata: metadata,
      );

      Logger.log('포인트 차감 완료: $userId (-$amount)', name: 'AWSPointsService');
      return true;
    } catch (e) {
      Logger.error('포인트 차감 오류', error: e, name: 'AWSPointsService');
      rethrow;
    }
  }

  /// 포인트 거래 내역 조회
  Future<List<PointTransaction>> getPointTransactions({
    required String userId,
    int limit = 20,
    String? nextToken,
  }) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetPointTransactions(\$userId: String!, \$limit: Int, \$nextToken: String) {
            pointTransactionsByUserId(
              userId: \$userId, 
              limit: \$limit, 
              nextToken: \$nextToken,
              sortDirection: DESC
            ) {
              items {
                id
                amount
                type
                description
                createdAt
                relatedItemId
                metadata
              }
              nextToken
            }
          }
        ''',
        variables: {
          'userId': userId,
          'limit': limit,
          'nextToken': nextToken,
        },
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('거래 내역 조회 실패: ${response.errors.first.message}');
      }

      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final items = data['pointTransactionsByUserId']?['items'] as List?;
        if (items != null) {
          return items
              .map((item) => PointTransaction.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      Logger.error('거래 내역 조회 오류', error: e, name: 'AWSPointsService');
      return [];
    }
  }

  /// 일일 로그인 보너스 지급
  Future<bool> giveDailyLoginBonus(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      final lastLoginDate = prefs.getString('${_lastLoginDateKey}_$userId') ?? '';
      
      // 오늘 이미 보너스를 받았는지 확인
      if (lastLoginDate == todayString) {
        return false; // 이미 받음
      }

      // 보너스 지급
      final success = await addPoints(
        userId: userId,
        amount: _dailyLoginBonus,
        type: PointTransactionType.dailyLogin,
        description: '일일 출석 보너스',
        metadata: {'date': todayString},
      );

      if (success) {
        await prefs.setString('${_lastLoginDateKey}_$userId', todayString);
        Logger.log('일일 로그인 보너스 지급: $userId (+$_dailyLoginBonus)', name: 'AWSPointsService');
      }

      return success;
    } catch (e) {
      Logger.error('일일 로그인 보너스 지급 오류', error: e, name: 'AWSPointsService');
      return false;
    }
  }

  /// 프로필 완성 보너스 지급
  Future<bool> giveProfileCompletionBonus(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyGiven = prefs.getBool('${_profileCompletionRewardKey}_$userId') ?? false;
      
      // 이미 보너스를 받았는지 확인
      if (alreadyGiven) {
        return false; // 이미 받음
      }

      // 보너스 지급
      final success = await addPoints(
        userId: userId,
        amount: _profileCompletionBonus,
        type: PointTransactionType.profileCompletion,
        description: '프로필 완성 보너스',
        metadata: {'completedAt': DateTime.now().toIso8601String()},
      );

      if (success) {
        await prefs.setBool('${_profileCompletionRewardKey}_$userId', true);
        Logger.log('프로필 완성 보너스 지급: $userId (+$_profileCompletionBonus)', name: 'AWSPointsService');
      }

      return success;
    } catch (e) {
      Logger.error('프로필 완성 보너스 지급 오류', error: e, name: 'AWSPointsService');
      return false;
    }
  }

  /// 포인트 잔액 확인
  Future<bool> hasEnoughPoints(String userId, int requiredAmount) async {
    try {
      final userPoints = await getUserPoints(userId);
      return userPoints?.canAfford(requiredAmount) ?? false;
    } catch (e) {
      Logger.error('포인트 잔액 확인 오류', error: e, name: 'AWSPointsService');
      return false;
    }
  }

  /// 포인트 거래 기록 생성
  Future<void> _createPointTransaction({
    required String userId,
    required int amount,
    required PointTransactionType type,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final now = DateTime.now();
      final transactionData = {
        'userId': userId,
        'amount': amount,
        'type': type.name,
        'description': description,
        'metadata': metadata,
        'status': 'COMPLETED',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final request = GraphQLRequest<String>(
        document: '''
          mutation CreatePointTransaction(\$input: CreatePointTransactionInput!) {
            createPointTransaction(input: \$input) {
              id
              userId
              amount
              type
              description
              status
              createdAt
            }
          }
        ''',
        variables: {'input': transactionData},
      );

      await Amplify.API.mutate(request: request).response;
      
      Logger.log('포인트 거래 기록 생성: $userId, $amount, $type', name: 'AWSPointsService');
    } catch (e) {
      Logger.error('포인트 거래 기록 생성 오류', error: e, name: 'AWSPointsService');
      // 거래 기록 실패는 전체 프로세스를 중단시키지 않음
    }
  }

  /// 일일 로그인 보너스 수령 가능 여부 확인
  Future<bool> canReceiveDailyBonus(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      final lastLoginDate = prefs.getString('${_lastLoginDateKey}_$userId') ?? '';
      
      return lastLoginDate != todayString;
    } catch (e) {
      Logger.error('일일 보너스 수령 가능 여부 확인 오류', error: e, name: 'AWSPointsService');
      return false;
    }
  }

  /// 프로필 완성 보너스 수령 가능 여부 확인
  Future<bool> canReceiveProfileCompletionBonus(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyGiven = prefs.getBool('${_profileCompletionRewardKey}_$userId') ?? false;
      
      return !alreadyGiven;
    } catch (e) {
      Logger.error('프로필 완성 보너스 수령 가능 여부 확인 오류', error: e, name: 'AWSPointsService');
      return false;
    }
  }

  /// 포인트 통계 조회
  Future<Map<String, int>> getPointsStatistics(String userId) async {
    try {
      final transactions = await getPointTransactions(userId: userId, limit: 100);
      final userPoints = await getUserPoints(userId);

      int totalEarned = 0;
      int totalSpent = 0;
      int transactionsThisMonth = 0;

      final thisMonth = DateTime.now();
      final monthStart = DateTime(thisMonth.year, thisMonth.month, 1);

      for (final transaction in transactions) {
        if (transaction.amount > 0) {
          totalEarned += transaction.amount;
        } else {
          totalSpent += transaction.amount.abs();
        }

        if (transaction.createdAt.isAfter(monthStart)) {
          transactionsThisMonth++;
        }
      }

      return {
        'available': userPoints?.availablePoints ?? 0,
        'total': userPoints?.totalPoints ?? 0,
        'totalEarned': totalEarned,
        'totalSpent': totalSpent,
        'transactionsThisMonth': transactionsThisMonth,
        'dailyLoginBonusAmount': _dailyLoginBonus,
        'profileCompletionBonusAmount': _profileCompletionBonus,
      };
    } catch (e) {
      Logger.error('포인트 통계 조회 오류', error: e, name: 'AWSPointsService');
      return {};
    }
  }

  /// GraphQL 응답 파싱
  Map<String, dynamic> _parseGraphQLResponse(String response) {
    try {
      if (response.startsWith('{') || response.startsWith('[')) {
        return Map<String, dynamic>.from(response as Map);
      }
      return {};
    } catch (e) {
      Logger.error('GraphQL 응답 파싱 오류', error: e, name: 'AWSPointsService');
      return {};
    }
  }
}