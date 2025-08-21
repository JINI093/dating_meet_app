import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../../utils/logger.dart';

/// 푸시 알림 전송 서비스
class PushNotificationService {
  static const String _defaultMessage = "인연은 타이밍, 지금 사귈래~ 🤍";
  
  /// 특정 사용자에게 푸시 알림 전송
  static Future<bool> sendNotificationToUser({
    required UserModel user,
    String? customMessage,
  }) async {
    try {
      Logger.log('📱 푸시 알림 전송 시작: ${user.name}', name: 'PushNotificationService');
      
      final message = customMessage ?? _defaultMessage;
      
      // Method 1: AWS SNS를 통한 푸시 알림 (실제 구현)
      final success = await _sendViaSNS(user, message);
      
      if (success) {
        Logger.log('✅ 푸시 알림 전송 성공', name: 'PushNotificationService');
        return true;
      } else {
        // Method 2: GraphQL Mutation을 통한 알림 전송 (백업)
        return await _sendViaGraphQL(user, message);
      }
    } catch (e) {
      Logger.error('❌ 푸시 알림 전송 실패: $e', name: 'PushNotificationService');
      return false;
    }
  }
  
  /// AWS SNS를 통한 푸시 알림 전송
  static Future<bool> _sendViaSNS(UserModel user, String message) async {
    try {
      // SNS Push Notification 구현
      const graphQLDocument = '''
        mutation SendPushNotification(\$input: PushNotificationInput!) {
          sendPushNotification(input: \$input) {
            success
            messageId
            error
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {
          'input': {
            'userId': user.id,
            'title': '새로운 인연이 기다려요!',
            'message': message,
            'type': 'ADMIN_MESSAGE',
            'data': {
              'senderId': 'admin',
              'timestamp': DateTime.now().toIso8601String(),
            },
          },
        },
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.data != null) {
        final jsonData = json.decode(response.data!);
        final result = jsonData['sendPushNotification'];
        
        if (result != null && result['success'] == true) {
          Logger.log('📨 SNS 알림 전송 성공: ${result['messageId']}', name: 'PushNotificationService');
          return true;
        } else {
          Logger.error('SNS 알림 전송 실패: ${result?['error']}', name: 'PushNotificationService');
        }
      }
      
      return false;
    } catch (e) {
      Logger.error('SNS 전송 오류: $e', name: 'PushNotificationService');
      return false;
    }
  }
  
  /// GraphQL을 통한 인앱 알림 전송 (백업 방법)
  static Future<bool> _sendViaGraphQL(UserModel user, String message) async {
    try {
      Logger.log('📲 GraphQL 알림 전송 시도', name: 'PushNotificationService');
      
      const graphQLDocument = '''
        mutation CreateNotification(\$input: CreateNotificationInput!) {
          createNotification(input: \$input) {
            id
            userId
            title
            message
            type
            isRead
            createdAt
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {
          'input': {
            'userId': user.id,
            'title': '새로운 인연이 기다려요!',
            'message': message,
            'type': 'ADMIN_MESSAGE',
            'isRead': false,
            'data': json.encode({
              'senderId': 'admin',
              'senderName': '관리자',
              'timestamp': DateTime.now().toIso8601String(),
              'category': 'dating_invitation',
            }),
          },
        },
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.data != null) {
        final jsonData = json.decode(response.data!);
        if (jsonData['createNotification'] != null) {
          Logger.log('✅ GraphQL 알림 생성 성공', name: 'PushNotificationService');
          return true;
        }
      }
      
      return false;
    } catch (e) {
      Logger.error('GraphQL 알림 전송 오류: $e', name: 'PushNotificationService');
      return false;
    }
  }
  
  
  /// 알림 전송 기록 저장
  static Future<void> _logNotificationSent({
    required UserModel user,
    required String message,
    required bool success,
  }) async {
    try {
      const graphQLDocument = '''
        mutation CreateNotificationLog(\$input: CreateNotificationLogInput!) {
          createNotificationLog(input: \$input) {
            id
            userId
            message
            success
            sentAt
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {
          'input': {
            'userId': user.id,
            'adminId': 'admin', // 실제로는 현재 관리자 ID
            'message': message,
            'success': success,
            'sentAt': DateTime.now().toIso8601String(),
            'type': 'PUSH_NOTIFICATION',
          },
        },
      );
      
      await Amplify.API.mutate(request: request).response;
      Logger.log('📝 알림 전송 기록 저장 완료', name: 'PushNotificationService');
    } catch (e) {
      Logger.error('알림 기록 저장 실패: $e', name: 'PushNotificationService');
    }
  }
  
  /// 시뮬레이션용 푸시 알림 전송 (개발/테스트용)
  static Future<bool> sendSimulatedNotification({
    required UserModel user,
    String? customMessage,
  }) async {
    try {
      Logger.log('🧪 시뮬레이션 푸시 알림 전송', name: 'PushNotificationService');
      
      final message = customMessage ?? _defaultMessage;
      
      // 시뮬레이션: 1-3초 랜덤 대기 (더 짧게)
      final delay = 1 + (DateTime.now().millisecond % 3);
      await Future.delayed(Duration(seconds: delay));
      
      // 95% 확률로 성공 (더 높은 성공률)
      final success = DateTime.now().millisecond % 20 != 0;
      
      // 로깅 먼저 수행 (비동기 로깅으로 인한 지연 방지)
      if (success) {
        Logger.log('✅ 시뮬레이션 알림 전송 성공: ${user.name}', name: 'PushNotificationService');
      } else {
        Logger.log('❌ 시뮬레이션 알림 전송 실패', name: 'PushNotificationService');
      }
      
      // 백그라운드에서 로깅 수행 (결과 반환에 영향 안주게)
      _logNotificationSent(
        user: user,
        message: message,
        success: success,
      ).catchError((e) {
        Logger.error('로깅 실패: $e', name: 'PushNotificationService');
      });
      
      return success;
    } catch (e) {
      Logger.error('시뮬레이션 알림 오류: $e', name: 'PushNotificationService');
      return false;
    }
  }
}