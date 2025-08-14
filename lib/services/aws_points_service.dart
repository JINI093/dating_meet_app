import 'package:amplify_flutter/amplify_flutter.dart';

import '../models/user_points_model.dart';
import '../utils/logger.dart';

class AWSPointsService {
  static const String _tableName = 'UserPoints';
  
  /// 사용자 포인트 정보 조회
  Future<UserPointsModel?> getUserPoints(String userId) async {
    try {
      Logger.log('사용자 포인트 조회 시작: $userId', name: 'AWSPointsService');
      
      // 기존 포인트 데이터 조회
      const listQuery = '''
        query ListUserPoints(\$filter: ModelUserPointsFilterInput) {
          listUserPoints(filter: \$filter) {
            items {
              id
              userId
              currentPoints
              totalEarned
              totalSpent
              lastUpdated
            }
          }
        }
      ''';

      final listRequest = GraphQLRequest<String>(
        document: listQuery,
        variables: {
          'filter': {
            'userId': {'eq': userId}
          }
        },
      );

      final listResponse = await Amplify.API.query(request: listRequest).response;
      
      Logger.log('GraphQL 응답 - hasErrors: ${listResponse.hasErrors}', name: 'AWSPointsService');
      
      if (listResponse.hasErrors) {
        Logger.error('GraphQL 오류: ${listResponse.errors}', name: 'AWSPointsService');
        // 에러 발생시 초기 포인트 생성
        return await _createInitialUserPoints(userId);
      }

      if (listResponse.data != null) {
        final data = listResponse.data as Map<String, dynamic>;
        final listData = data['listUserPoints'] as Map<String, dynamic>;
        final items = listData['items'] as List<dynamic>;
        
        Logger.log('조회된 포인트 데이터 개수: ${items.length}', name: 'AWSPointsService');
        
        if (items.isNotEmpty) {
          final userPointsData = items.first as Map<String, dynamic>;
          Logger.log('포인트 조회 성공: ${userPointsData['currentPoints']}P', name: 'AWSPointsService');
          
          return UserPointsModel(
            userId: userPointsData['userId'],
            currentPoints: userPointsData['currentPoints'],
            totalEarned: userPointsData['totalEarned'],
            totalSpent: userPointsData['totalSpent'],
            lastUpdated: DateTime.parse(userPointsData['lastUpdated']),
            transactions: [], // 별도로 로드
          );
        }
      }

      // 사용자 포인트가 없으면 새로 생성
      Logger.log('포인트 데이터가 없음 - 새로 생성', name: 'AWSPointsService');
      return await _createInitialUserPoints(userId);
      
    } catch (e) {
      Logger.error('포인트 조회 실패: $e', name: 'AWSPointsService');
      // 실패시 초기 포인트 생성 시도
      return await _createInitialUserPoints(userId);
    }
  }

  /// 초기 사용자 포인트 생성
  Future<UserPointsModel?> _createInitialUserPoints(String userId) async {
    try {
      Logger.log('초기 포인트 생성 시작: $userId', name: 'AWSPointsService');
      
      const mutation = '''
        mutation CreateUserPoints(\$input: CreateUserPointsInput!) {
          createUserPoints(input: \$input) {
            id
            userId
            currentPoints
            totalEarned
            totalSpent
            lastUpdated
          }
        }
      ''';

      final now = DateTime.now().toUtc().toIso8601String();
      final request = GraphQLRequest<String>(
        document: mutation,
        variables: {
          'input': {
            'userId': userId,
            'currentPoints': 0,
            'totalEarned': 0,
            'totalSpent': 0,
            'lastUpdated': now,
          }
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.hasErrors) {
        Logger.error('초기 포인트 생성 GraphQL 오류: ${response.errors}', name: 'AWSPointsService');
        // 에러 발생시에도 초기 포인트 반환
        return UserPointsModel.initial(userId);
      }

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final userPointsData = data['createUserPoints'] as Map<String, dynamic>;
        
        Logger.log('초기 포인트 생성 완료: ${userPointsData['currentPoints']}P', name: 'AWSPointsService');
        
        return UserPointsModel(
          userId: userPointsData['userId'],
          currentPoints: userPointsData['currentPoints'],
          totalEarned: userPointsData['totalEarned'],
          totalSpent: userPointsData['totalSpent'],
          lastUpdated: DateTime.parse(userPointsData['lastUpdated']),
          transactions: [],
        );
      }
      
      // 생성 실패시 기본 포인트 반환
      return UserPointsModel.initial(userId);
    } catch (e) {
      Logger.error('초기 포인트 생성 실패: $e', name: 'AWSPointsService');
      // 에러 발생시에도 초기 포인트 반환
      return UserPointsModel.initial(userId);
    }
  }

  /// 포인트 추가 (구매, 리워드 등)
  Future<UserPointsModel?> addPoints({
    required String userId,
    required int amount,
    required String description,
    PointTransactionType type = PointTransactionType.earned,
  }) async {
    try {
      Logger.log('포인트 추가 시작: $userId (+$amount)', name: 'AWSPointsService');
      
      final currentPoints = await getUserPoints(userId);
      if (currentPoints == null) {
        Logger.error('사용자 포인트 정보를 찾을 수 없음', name: 'AWSPointsService');
        return null;
      }

      final updatedPoints = currentPoints.addPoints(amount, description, type);
      
      // 먼저 트랜잭션 생성
      await _createTransaction(
        userId: userId,
        amount: amount,
        type: type.toStringValue(),
        description: description,
      );
      
      // 포인트 업데이트
      await _updateUserPoints(updatedPoints);
      
      Logger.log('포인트 추가 완료: ${updatedPoints.currentPoints}P', name: 'AWSPointsService');
      return updatedPoints;
      
    } catch (e) {
      Logger.error('포인트 추가 실패: $e', name: 'AWSPointsService');
      return null;
    }
  }

  /// 포인트 사용
  Future<UserPointsModel?> spendPoints({
    required String userId,
    required int amount,
    required String description,
    PointTransactionType type = PointTransactionType.spentOther,
  }) async {
    try {
      Logger.log('포인트 사용 시작: $userId (-$amount)', name: 'AWSPointsService');
      
      final currentPoints = await getUserPoints(userId);
      if (currentPoints == null) {
        Logger.error('사용자 포인트 정보를 찾을 수 없음', name: 'AWSPointsService');
        return null;
      }

      if (!currentPoints.canSpend(amount)) {
        throw Exception('포인트가 부족합니다. 현재: ${currentPoints.currentPoints}P, 필요: ${amount}P');
      }

      final updatedPoints = currentPoints.spendPoints(amount, description, type);
      
      // 먼저 트랜잭션 생성
      await _createTransaction(
        userId: userId,
        amount: -amount,
        type: type.toStringValue(),
        description: description,
      );
      
      // 포인트 업데이트
      await _updateUserPoints(updatedPoints);
      
      Logger.log('포인트 사용 완료: ${updatedPoints.currentPoints}P', name: 'AWSPointsService');
      return updatedPoints;
      
    } catch (e) {
      Logger.error('포인트 사용 실패: $e', name: 'AWSPointsService');
      return null;
    }
  }

  /// 포인트 구매
  Future<UserPointsModel?> purchasePoints({
    required String userId,
    required int amount,
    required int price,
    required String paymentMethod,
  }) async {
    try {
      Logger.log('포인트 구매 시작: $userId (+$amount, ₩$price)', name: 'AWSPointsService');
      
      return await addPoints(
        userId: userId,
        amount: amount,
        description: '포인트 구매 ($paymentMethod, ₩$price)',
        type: PointTransactionType.purchase,
      );
      
    } catch (e) {
      Logger.error('포인트 구매 실패: $e', name: 'AWSPointsService');
      return null;
    }
  }

  /// 포인트 업데이트
  Future<bool> _updateUserPoints(UserPointsModel userPoints) async {
    try {
      // 먼저 기존 레코드 ID 조회
      const listQuery = '''
        query ListUserPoints(\$filter: ModelUserPointsFilterInput) {
          listUserPoints(filter: \$filter) {
            items {
              id
              userId
            }
          }
        }
      ''';

      final listRequest = GraphQLRequest<String>(
        document: listQuery,
        variables: {
          'filter': {
            'userId': {'eq': userPoints.userId}
          }
        },
      );

      final listResponse = await Amplify.API.query(request: listRequest).response;
      
      if (listResponse.hasErrors || listResponse.data == null) {
        Logger.error('사용자 포인트 ID 조회 실패', name: 'AWSPointsService');
        return false;
      }

      final data = listResponse.data as Map<String, dynamic>;
      final listData = data['listUserPoints'] as Map<String, dynamic>;
      final items = listData['items'] as List<dynamic>;
      
      if (items.isEmpty) {
        Logger.error('업데이트할 포인트 레코드를 찾을 수 없음', name: 'AWSPointsService');
        return false;
      }

      final pointsId = items.first['id'] as String;
      
      // 업데이트 실행
      const mutation = '''
        mutation UpdateUserPoints(\$input: UpdateUserPointsInput!) {
          updateUserPoints(input: \$input) {
            id
            userId
            currentPoints
            totalEarned
            totalSpent
            lastUpdated
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: mutation,
        variables: {
          'input': {
            'id': pointsId,
            'currentPoints': userPoints.currentPoints,
            'totalEarned': userPoints.totalEarned,
            'totalSpent': userPoints.totalSpent,
            'lastUpdated': userPoints.lastUpdated.toUtc().toIso8601String(),
          }
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.hasErrors) {
        Logger.error('포인트 업데이트 GraphQL 오류: ${response.errors}', name: 'AWSPointsService');
        return false;
      }

      Logger.log('포인트 업데이트 성공: ${userPoints.currentPoints}P', name: 'AWSPointsService');
      return true;
      
    } catch (e) {
      Logger.error('포인트 업데이트 실패: $e', name: 'AWSPointsService');
      return false;
    }
  }

  /// 트랜잭션 생성
  Future<bool> _createTransaction({
    required String userId,
    required int amount,
    required String type,
    required String description,
  }) async {
    try {
      const mutation = '''
        mutation CreatePointTransaction(\$input: CreatePointTransactionInput!) {
          createPointTransaction(input: \$input) {
            id
            userId
            amount
            type
            description
            timestamp
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: mutation,
        variables: {
          'input': {
            'userId': userId,
            'amount': amount,
            'type': type,
            'description': description,
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          }
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.hasErrors) {
        Logger.error('트랜잭션 생성 GraphQL 오류: ${response.errors}', name: 'AWSPointsService');
        return false;
      }

      Logger.log('트랜잭션 생성 성공: $type ($amount)', name: 'AWSPointsService');
      return true;
      
    } catch (e) {
      Logger.error('트랜잭션 생성 실패: $e', name: 'AWSPointsService');
      return false;
    }
  }

  /// 포인트 트랜잭션 목록 조회
  Future<List<PointTransaction>> getPointTransactions(String userId, {int limit = 20}) async {
    try {
      Logger.log('트랜잭션 목록 조회 시작: $userId', name: 'AWSPointsService');
      
      const listQuery = '''
        query ListPointTransactions(\$filter: ModelPointTransactionFilterInput, \$limit: Int) {
          listPointTransactions(filter: \$filter, limit: \$limit) {
            items {
              id
              userId
              amount
              type
              description
              timestamp
            }
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: listQuery,
        variables: {
          'filter': {
            'userId': {'eq': userId}
          },
          'limit': limit,
        },
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.hasErrors) {
        Logger.error('트랜잭션 조회 GraphQL 오류: ${response.errors}', name: 'AWSPointsService');
        return [];
      }

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final listData = data['listPointTransactions'] as Map<String, dynamic>;
        final items = listData['items'] as List<dynamic>;
        
        Logger.log('트랜잭션 조회 성공: ${items.length}개', name: 'AWSPointsService');
        
        return items.map((item) => PointTransaction(
          id: item['id'],
          userId: item['userId'],
          amount: item['amount'],
          type: PointTransactionTypeExtension.fromString(item['type']),
          description: item['description'],
          timestamp: DateTime.parse(item['timestamp']),
        )).toList();
      }
      
      return [];
    } catch (e) {
      Logger.error('트랜잭션 조회 실패: $e', name: 'AWSPointsService');
      return [];
    }
  }
}