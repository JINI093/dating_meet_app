import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/payment_model.dart';
import '../../utils/logger.dart';

/// 관리자 결제 관리 서비스 (AWS Amplify)
class AdminPaymentServiceAmplify {
  /// 결제 목록 조회
  Future<Map<String, dynamic>> getPayments({
    int page = 1,
    int pageSize = 20,
    PaymentStatus? status,
    PaymentMethod? paymentMethod,
    String searchQuery = '',
    DateTime? startDate,
    DateTime? endDate,
    String? sortField,
    bool sortAscending = false, // 최신순이 기본
  }) async {
    try {
      Logger.log('📋 결제 목록 조회 시작 (AWS)', name: 'AdminPaymentServiceAmplify');

      String nextToken = '';
      List<PaymentModel> allPayments = [];
      bool hasMoreData = true;

      // 전체 결제 데이터를 가져오기 (필터링을 위해)
      do {
        const graphQLDocument = '''
          query ListPayments(\$limit: Int, \$nextToken: String) {
            listPayments(limit: \$limit, nextToken: \$nextToken) {
              items {
                id
                userId
                userName
                productName
                productType
                amount
                paymentMethod
                status
                transactionId
                gatewayResponse
                refundAmount
                refundReason
                refundedAt
                failureReason
                createdAt
                updatedAt
              }
              nextToken
            }
          }
        ''';

        final request = GraphQLRequest<String>(
          document: graphQLDocument,
          variables: {
            'limit': 100, // 한 번에 많은 데이터 가져오기
            if (nextToken.isNotEmpty) 'nextToken': nextToken,
          },
        );

        final response = await Amplify.API.query(request: request).response;

        if (response.hasErrors) {
          Logger.error('결제 목록 조회 에러: ${response.errors}', name: 'AdminPaymentServiceAmplify');
          throw Exception('결제 목록 조회 실패: ${response.errors.first.message}');
        }

        final data = response.data;
        if (data != null) {
          final jsonResponse = json.decode(data);
          final payments = jsonResponse['listPayments']['items'] as List;
          
          for (final paymentJson in payments) {
            try {
              final payment = _parsePaymentFromGraphQL(paymentJson);
              allPayments.add(payment);
            } catch (e) {
              Logger.error('결제 파싱 에러: $e', name: 'AdminPaymentServiceAmplify');
            }
          }

          nextToken = jsonResponse['listPayments']['nextToken'] ?? '';
          hasMoreData = nextToken.isNotEmpty;
        } else {
          hasMoreData = false;
        }
      } while (hasMoreData);

      Logger.log('📊 총 ${allPayments.length}개 결제 가져옴', name: 'AdminPaymentServiceAmplify');

      // 필터링 적용
      List<PaymentModel> filteredPayments = allPayments;

      if (status != null) {
        filteredPayments = filteredPayments.where((p) => p.status == status).toList();
      }
      if (paymentMethod != null) {
        filteredPayments = filteredPayments.where((p) => p.paymentMethod == paymentMethod).toList();
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filteredPayments = filteredPayments.where((p) => 
          p.userName.toLowerCase().contains(query) ||
          p.productName.toLowerCase().contains(query) ||
          p.id.toLowerCase().contains(query) ||
          (p.transactionId ?? '').toLowerCase().contains(query)
        ).toList();
      }
      if (startDate != null) {
        filteredPayments = filteredPayments.where((p) => 
          p.createdAt.isAfter(startDate.subtract(const Duration(days: 1)))
        ).toList();
      }
      if (endDate != null) {
        filteredPayments = filteredPayments.where((p) => 
          p.createdAt.isBefore(endDate.add(const Duration(days: 1)))
        ).toList();
      }

      // 정렬 적용
      if (sortField != null) {
        filteredPayments.sort((a, b) {
          int comparison = 0;
          switch (sortField) {
            case 'createdAt':
              comparison = a.createdAt.compareTo(b.createdAt);
              break;
            case 'updatedAt':
              comparison = a.updatedAt.compareTo(b.updatedAt);
              break;
            case 'amount':
              comparison = a.amount.compareTo(b.amount);
              break;
            case 'userName':
              comparison = a.userName.compareTo(b.userName);
              break;
            case 'productName':
              comparison = a.productName.compareTo(b.productName);
              break;
            default:
              // 기본 정렬: 최신순
              comparison = b.createdAt.compareTo(a.createdAt);
          }
          return sortAscending ? comparison : -comparison;
        });
      } else {
        // 기본 정렬: 최신순
        filteredPayments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      // 페이징 적용
      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      final pagedPayments = filteredPayments.length > startIndex 
          ? filteredPayments.sublist(startIndex, endIndex > filteredPayments.length ? filteredPayments.length : endIndex)
          : <PaymentModel>[];

      return {
        'payments': pagedPayments,
        'totalCount': filteredPayments.length,
        'totalPages': (filteredPayments.length / pageSize).ceil(),
      };
    } catch (e) {
      Logger.error('결제 목록 조회 실패: $e', name: 'AdminPaymentServiceAmplify');
      throw Exception('결제 목록 조회 실패: $e');
    }
  }

  /// 결제 상세 조회
  Future<PaymentModel> getPayment(String paymentId) async {
    try {
      Logger.log('📄 결제 상세 조회: $paymentId (AWS)', name: 'AdminPaymentServiceAmplify');

      const graphQLDocument = '''
        query GetPayment(\$id: ID!) {
          getPayment(id: \$id) {
            id
            userId
            userName
            productName
            productType
            amount
            paymentMethod
            status
            transactionId
            gatewayResponse
            refundAmount
            refundReason
            refundedAt
            failureReason
            createdAt
            updatedAt
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {'id': paymentId},
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.hasErrors) {
        Logger.error('결제 상세 조회 에러: ${response.errors}', name: 'AdminPaymentServiceAmplify');
        throw Exception('결제 상세 조회 실패: ${response.errors.first.message}');
      }

      final data = response.data;
      if (data != null) {
        final jsonResponse = json.decode(data);
        final paymentJson = jsonResponse['getPayment'];
        
        if (paymentJson == null) {
          throw Exception('결제를 찾을 수 없습니다');
        }

        return _parsePaymentFromGraphQL(paymentJson);
      } else {
        throw Exception('결제를 찾을 수 없습니다');
      }
    } catch (e) {
      Logger.error('결제 상세 조회 실패: $e', name: 'AdminPaymentServiceAmplify');
      throw Exception('결제 상세 조회 실패: $e');
    }
  }

  /// 환불 처리
  Future<PaymentModel> processRefund(String paymentId, RefundProcessDto dto) async {
    try {
      Logger.log('💰 환불 처리 시작: $paymentId (AWS)', name: 'AdminPaymentServiceAmplify');

      // 기존 결제 정보 조회
      final existingPayment = await getPayment(paymentId);
      
      if (!existingPayment.canRefund) {
        throw Exception('환불할 수 없는 결제입니다');
      }

      if (dto.refundAmount > existingPayment.refundableAmount) {
        throw Exception('환불 가능 금액을 초과했습니다');
      }

      // 환불 상태 결정
      PaymentStatus newStatus;
      if (dto.refundAmount == existingPayment.amount) {
        newStatus = PaymentStatus.refunded; // 전액 환불
      } else {
        newStatus = PaymentStatus.partialRefund; // 부분 환불
      }

      const graphQLDocument = '''
        mutation UpdatePayment(\$input: UpdatePaymentInput!) {
          updatePayment(input: \$input) {
            id
            userId
            userName
            productName
            productType
            amount
            paymentMethod
            status
            transactionId
            gatewayResponse
            refundAmount
            refundReason
            refundedAt
            failureReason
            createdAt
            updatedAt
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {
          'input': {
            'id': paymentId,
            'status': newStatus.name,
            'refundAmount': dto.refundAmount,
            'refundReason': dto.refundReason,
            'refundedAt': DateTime.now().toIso8601String(),
          },
        },
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        Logger.error('환불 처리 에러: ${response.errors}', name: 'AdminPaymentServiceAmplify');
        throw Exception('환불 처리 실패: ${response.errors.first.message}');
      }

      final data = response.data;
      if (data != null) {
        final jsonResponse = json.decode(data);
        final paymentJson = jsonResponse['updatePayment'];
        
        Logger.log('💰 환불 처리 완료: $paymentId', name: 'AdminPaymentServiceAmplify');
        return _parsePaymentFromGraphQL(paymentJson);
      } else {
        throw Exception('환불 처리 실패');
      }
    } catch (e) {
      Logger.error('환불 처리 실패: $e', name: 'AdminPaymentServiceAmplify');
      throw Exception('환불 처리 실패: $e');
    }
  }

  /// 결제 상태 변경
  Future<PaymentModel> updatePaymentStatus(String paymentId, PaymentStatus status) async {
    try {
      Logger.log('🔄 결제 상태 변경: $paymentId -> ${status.name} (AWS)', name: 'AdminPaymentServiceAmplify');

      const graphQLDocument = '''
        mutation UpdatePayment(\$input: UpdatePaymentInput!) {
          updatePayment(input: \$input) {
            id
            userId
            userName
            productName
            productType
            amount
            paymentMethod
            status
            transactionId
            gatewayResponse
            refundAmount
            refundReason
            refundedAt
            failureReason
            createdAt
            updatedAt
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {
          'input': {
            'id': paymentId,
            'status': status.name,
          },
        },
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        Logger.error('결제 상태 변경 에러: ${response.errors}', name: 'AdminPaymentServiceAmplify');
        throw Exception('결제 상태 변경 실패: ${response.errors.first.message}');
      }

      final data = response.data;
      if (data != null) {
        final jsonResponse = json.decode(data);
        final paymentJson = jsonResponse['updatePayment'];
        
        Logger.log('📊 결제 상태 변경 완료: $paymentId', name: 'AdminPaymentServiceAmplify');
        return _parsePaymentFromGraphQL(paymentJson);
      } else {
        throw Exception('결제 상태 변경 실패');
      }
    } catch (e) {
      Logger.error('결제 상태 변경 실패: $e', name: 'AdminPaymentServiceAmplify');
      throw Exception('결제 상태 변경 실패: $e');
    }
  }

  /// GraphQL 응답을 PaymentModel로 파싱
  PaymentModel _parsePaymentFromGraphQL(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      productName: json['productName'] ?? '',
      productType: ProductType.values.firstWhere(
        (type) => type.name == json['productType'],
        orElse: () => ProductType.points,
      ),
      amount: json['amount'] ?? 0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == json['paymentMethod'],
        orElse: () => PaymentMethod.creditCard,
      ),
      status: PaymentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: json['transactionId'],
      gatewayResponse: json['gatewayResponse'],
      refundAmount: json['refundAmount'],
      refundReason: json['refundReason'],
      refundedAt: json['refundedAt'] != null 
          ? DateTime.tryParse(json['refundedAt'])
          : null,
      failureReason: json['failureReason'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// 결제 통계 조회
  Future<Map<String, dynamic>> getPaymentStats() async {
    try {
      Logger.log('📊 결제 통계 조회 시작 (AWS)', name: 'AdminPaymentServiceAmplify');

      // 전체 결제 가져와서 통계 계산
      final result = await getPayments(page: 1, pageSize: 10000); // 충분히 큰 수로 전체 가져오기
      final payments = result['payments'] as List<PaymentModel>;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final thisMonthStart = DateTime(now.year, now.month, 1);

      // 오늘 결제
      final todayPayments = payments.where((p) => 
        p.createdAt.isAfter(today) && p.status == PaymentStatus.completed
      ).toList();

      // 이번 주 결제
      final thisWeekPayments = payments.where((p) => 
        p.createdAt.isAfter(thisWeekStart) && p.status == PaymentStatus.completed
      ).toList();

      // 이번 달 결제
      final thisMonthPayments = payments.where((p) => 
        p.createdAt.isAfter(thisMonthStart) && p.status == PaymentStatus.completed
      ).toList();

      // 실패 결제
      final failedPayments = payments.where((p) => p.status == PaymentStatus.failed).toList();
      final totalAttempts = payments.length;
      final failureRate = totalAttempts > 0 ? (failedPayments.length / totalAttempts * 100) : 0.0;

      final stats = {
        'todayAmount': todayPayments.fold<int>(0, (sum, p) => sum + p.amount),
        'todayCount': todayPayments.length,
        'weekAmount': thisWeekPayments.fold<int>(0, (sum, p) => sum + p.amount),
        'weekCount': thisWeekPayments.length,
        'monthAmount': thisMonthPayments.fold<int>(0, (sum, p) => sum + p.amount),
        'monthCount': thisMonthPayments.length,
        'failedCount': failedPayments.length,
        'failureRate': failureRate,
      };

      Logger.log('📊 결제 통계: $stats', name: 'AdminPaymentServiceAmplify');
      return stats;
    } catch (e) {
      Logger.error('결제 통계 조회 실패: $e', name: 'AdminPaymentServiceAmplify');
      // 실패 시 기본값 반환
      return {
        'todayAmount': 0,
        'todayCount': 0,
        'weekAmount': 0,
        'weekCount': 0,
        'monthAmount': 0,
        'monthCount': 0,
        'failedCount': 0,
        'failureRate': 0.0,
      };
    }
  }
}