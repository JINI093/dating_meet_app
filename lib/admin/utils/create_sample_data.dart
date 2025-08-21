import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';

class SampleDataCreator {
  static Future<void> createSamplePayments() async {
    final samplePayments = [
      {
        'userName': '김철수',
        'productName': '3개월 VIP',
        'productType': 'vip',
        'amount': 69000,
        'paymentMethod': 'creditCard',
        'status': 'completed',
        'transactionId': 'TXN20240821001',
        'userId': 'user_001',
      },
      {
        'userName': '이영희',
        'productName': '슈퍼챗 50개',
        'productType': 'superchat',
        'amount': 45000,
        'paymentMethod': 'paypal',
        'status': 'completed',
        'transactionId': 'TXN20240821002',
        'userId': 'user_002',
      },
      {
        'userName': '박민수',
        'productName': '1개월 VIP',
        'productType': 'vip',
        'amount': 29000,
        'paymentMethod': 'googlePlay',
        'status': 'failed',
        'failureReason': '카드 한도 초과',
        'userId': 'user_003',
      },
      {
        'userName': '정수연',
        'productName': '프로필 부스트',
        'productType': 'boost',
        'amount': 5000,
        'paymentMethod': 'creditCard',
        'status': 'completed',
        'transactionId': 'TXN20240821003',
        'userId': 'user_004',
      },
      {
        'userName': '최지민',
        'productName': '포인트 1000개',
        'productType': 'points',
        'amount': 10000,
        'paymentMethod': 'appStore',
        'status': 'completed',
        'transactionId': 'TXN20240821004',
        'userId': 'user_005',
      },
      {
        'userName': '홍길동',
        'productName': '6개월 VIP',
        'productType': 'vip',
        'amount': 120000,
        'paymentMethod': 'creditCard',
        'status': 'refunded',
        'transactionId': 'TXN20240820001',
        'refundAmount': 120000,
        'refundReason': '서비스 불만족',
        'userId': 'user_006',
      },
      {
        'userName': '강민정',
        'productName': '슈퍼챗 100개',
        'productType': 'superchat',
        'amount': 80000,
        'paymentMethod': 'bankTransfer',
        'status': 'completed',
        'transactionId': 'TXN20240821005',
        'userId': 'user_007',
      },
      {
        'userName': '윤서현',
        'productName': '1주일 구독',
        'productType': 'subscription',
        'amount': 7000,
        'paymentMethod': 'kakaoPay',
        'status': 'cancelled',
        'userId': 'user_008',
      },
      {
        'userName': '김민수',
        'productName': '2개월 VIP',
        'productType': 'vip',
        'amount': 49000,
        'paymentMethod': 'creditCard',
        'status': 'completed',
        'transactionId': 'TXN20240819001',
        'userId': 'user_009',
      },
      {
        'userName': '박지영',
        'productName': '포인트 500개',
        'productType': 'points',
        'amount': 5000,
        'paymentMethod': 'naverpay',
        'status': 'partialRefund',
        'transactionId': 'TXN20240820002',
        'refundAmount': 2000,
        'refundReason': '부분 취소',
        'userId': 'user_010',
      },
    ];

    safePrint('🔥 결제 샘플 데이터 생성 시작...');

    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < samplePayments.length; i++) {
      final payment = samplePayments[i];
      
      try {
        const graphQLDocument = '''
          mutation CreatePayment(\$input: CreatePaymentInput!) {
            createPayment(input: \$input) {
              id
              userName
              productName
              amount
              status
              createdAt
            }
          }
        ''';

        final request = GraphQLRequest<String>(
          document: graphQLDocument,
          variables: {'input': payment},
        );

        final response = await Amplify.API.mutate(request: request).response;

        if (response.hasErrors) {
          safePrint('❌ 결제 ${i + 1} 생성 실패: ${response.errors?.first.message}');
          failCount++;
        } else {
          final data = response.data;
          if (data != null) {
            final jsonResponse = json.decode(data);
            final createdPayment = jsonResponse['createPayment'];
            safePrint('✅ 결제 ${i + 1} 생성 성공: ${createdPayment['userName']} - ${createdPayment['productName']}');
            successCount++;
          }
        }
      } catch (e) {
        safePrint('❌ 결제 ${i + 1} 생성 오류: $e');
        failCount++;
      }

      // 약간의 딜레이 추가
      await Future.delayed(const Duration(milliseconds: 500));
    }

    safePrint('🎉 결제 샘플 데이터 생성 완료!');
    safePrint('✅ 성공: $successCount개');
    safePrint('❌ 실패: $failCount개');
  }

  static Future<void> createSampleReports() async {
    final sampleReports = [
      {
        'reporterUserId': 'user_001',
        'reporterName': '김철수',
        'reportedUserId': 'user_002',
        'reportedName': '이영희',
        'reportType': 'inappropriateContent',
        'reportReason': '부적절한 프로필 사진',
        'reportContent': '해당 사용자가 부적절한 프로필 사진을 사용하고 있습니다.',
        'evidence': ['image1.jpg'],
        'status': 'pending',
        'priority': 'high',
      },
      {
        'reporterUserId': 'user_003',
        'reporterName': '박민수',
        'reportedUserId': 'user_004',
        'reportedName': '정수연',
        'reportType': 'harassment',
        'reportReason': '지속적인 괴롭힘',
        'reportContent': '해당 사용자가 지속적으로 불쾌한 메시지를 보내고 있습니다.',
        'evidence': ['chat_log.txt'],
        'status': 'inProgress',
        'priority': 'urgent',
      },
      {
        'reporterUserId': 'user_005',
        'reporterName': '최지민',
        'reportedUserId': 'user_006',
        'reportedName': '홍길동',
        'reportType': 'spam',
        'reportReason': '스팸 메시지',
        'reportContent': '광고성 메시지를 계속 보내고 있습니다.',
        'evidence': ['spam_messages.txt'],
        'status': 'resolved',
        'priority': 'normal',
      }
    ];

    safePrint('🔥 신고 샘플 데이터 생성 시작...');

    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < sampleReports.length; i++) {
      final report = sampleReports[i];
      
      try {
        const graphQLDocument = '''
          mutation CreateReport(\$input: CreateReportInput!) {
            createReport(input: \$input) {
              id
              reporterName
              reportedName
              reportType
              status
              createdAt
            }
          }
        ''';

        final request = GraphQLRequest<String>(
          document: graphQLDocument,
          variables: {'input': report},
        );

        final response = await Amplify.API.mutate(request: request).response;

        if (response.hasErrors) {
          safePrint('❌ 신고 ${i + 1} 생성 실패: ${response.errors?.first.message}');
          failCount++;
        } else {
          final data = response.data;
          if (data != null) {
            final jsonResponse = json.decode(data);
            final createdReport = jsonResponse['createReport'];
            safePrint('✅ 신고 ${i + 1} 생성 성공: ${createdReport['reporterName']} -> ${createdReport['reportedName']}');
            successCount++;
          }
        }
      } catch (e) {
        safePrint('❌ 신고 ${i + 1} 생성 오류: $e');
        failCount++;
      }

      // 약간의 딜레이 추가
      await Future.delayed(const Duration(milliseconds: 500));
    }

    safePrint('🎉 신고 샘플 데이터 생성 완료!');
    safePrint('✅ 성공: $successCount개');
    safePrint('❌ 실패: $failCount개');
  }
}