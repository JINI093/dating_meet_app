import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import '../../models/SettlementRecord.dart';

// Provider for settlement records
final settlementRecordsProvider = StateNotifierProvider<SettlementRecordsNotifier, SettlementRecordsState>((ref) {
  return SettlementRecordsNotifier();
});

// State class
class SettlementRecordsState {
  final List<SettlementRecord> records;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int pageSize;

  SettlementRecordsState({
    required this.records,
    required this.isLoading,
    this.error,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
  });

  SettlementRecordsState copyWith({
    List<SettlementRecord>? records,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? pageSize,
  }) {
    return SettlementRecordsState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

// Notifier class
class SettlementRecordsNotifier extends StateNotifier<SettlementRecordsState> {
  SettlementRecordsNotifier() : super(SettlementRecordsState(
    records: [], 
    isLoading: false, 
    currentPage: 1, 
    totalPages: 1, 
    pageSize: 15
  )) {
    loadRecords();
  }

  // Load all settlement records from AWS
  Future<void> loadRecords({int page = 1, int? pageSize}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final newPageSize = pageSize ?? state.pageSize;
      
      // AWS에서 정산 기록 데이터 로드 시도
      try {
        final request = GraphQLRequest<String>(
          document: '''query ListSettlementRecords(
            \$limit: Int
            \$nextToken: String
          ) {
            listSettlementRecords(limit: \$limit, nextToken: \$nextToken) {
              items {
                id
                requestDate
                memberName
                pointCount
                settlementAmount
                accountNumber
                settlementStatus
                userId
                createdAt
                updatedAt
              }
              nextToken
            }
          }''',
          variables: {
            'limit': newPageSize,
          },
        );
        final response = await Amplify.API.query(request: request).response;
        
        if (response.data != null && response.errors.isEmpty) {
          // JSON 문자열을 파싱
          final jsonData = json.decode(response.data!);
          final items = jsonData['listSettlementRecords']['items'] as List?;
          
          if (items != null) {
            final records = items
                .map((item) => SettlementRecord.fromJson(item as Map<String, dynamic>))
                .toList();
            
            // 총 페이지 수 계산 (실제로는 AWS에서 총 개수를 받아야 함)
            final totalPages = (records.length / newPageSize).ceil();
            
            state = state.copyWith(
              records: records,
              isLoading: false,
              currentPage: page,
              totalPages: totalPages > 0 ? totalPages : 1,
              pageSize: newPageSize,
            );
          } else {
            // 데이터가 없으면 빈 리스트
            state = state.copyWith(
              records: [],
              isLoading: false,
              currentPage: 1,
              totalPages: 1,
              pageSize: newPageSize,
            );
          }
        } else {
          // 데이터가 없으면 빈 리스트
          state = state.copyWith(
            records: [],
            isLoading: false,
            currentPage: 1,
            totalPages: 1,
            pageSize: newPageSize,
          );
        }
      } catch (e) {
        // AWS 연결 실패 시 빈 리스트 표시
        print('AWS 연결 실패, 빈 테이블 표시: $e');
        state = state.copyWith(
          records: [],
          isLoading: false,
          currentPage: 1,
          totalPages: 1,
          pageSize: newPageSize,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '정산 내역을 불러오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Change page size
  Future<void> changePageSize(int pageSize) async {
    await loadRecords(page: 1, pageSize: pageSize);
  }

  // Go to specific page
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= state.totalPages) {
      await loadRecords(page: page, pageSize: state.pageSize);
    }
  }

  // Update settlement status
  Future<void> updateSettlementStatus(String recordId, String newStatus) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 먼저 로컬 상태 업데이트
      final updatedRecords = state.records.map((record) {
        if (record.id == recordId) {
          return record.copyWith(settlementStatus: newStatus);
        }
        return record;
      }).toList();
      
      state = state.copyWith(
        records: updatedRecords,
        isLoading: false,
      );
      
      // AWS에 업데이트 시도
      try {
        final request = GraphQLRequest<SettlementRecord>(
          document: '''mutation UpdateSettlementRecord(\$input: UpdateSettlementRecordInput!) {
            updateSettlementRecord(input: \$input) {
              id
              requestDate
              memberName
              pointCount
              settlementAmount
              accountNumber
              settlementStatus
              userId
              createdAt
              updatedAt
            }
          }''',
          variables: {
            'input': {
              'id': recordId,
              'settlementStatus': newStatus,
            }
          },
          decodePath: 'updateSettlementRecord',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 업데이트 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '정산 상태 변경 중 오류가 발생했습니다: $e',
      );
    }
  }
}