import 'dart:convert';

void main() async {
  // This is a simple script to create sample payment data
  print('Creating sample payment data...');
  
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
  ];

  for (int i = 0; i < samplePayments.length; i++) {
    final payment = samplePayments[i];
    
    print('Creating payment ${i + 1}: ${payment['productName']} - ${payment['userName']}');
    
    // You would use this GraphQL mutation in your app
    final mutation = '''
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
    
    print('GraphQL mutation for payment ${i + 1}:');
    print('Variables: ${json.encode({"input": payment})}');
    print('---');
  }
  
  print('\nSample payment data structure ready!');
  print('Total payments: ${samplePayments.length}');
  print('\nTo actually create this data, you need to:');
  print('1. Ensure Amplify is initialized in your app');
  print('2. Use the createPayment GraphQL mutation');
  print('3. Or create the data through AWS AppSync console');
}