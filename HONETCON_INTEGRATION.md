# HonetCon API 포인트 전환 통합 가이드

## 개요

HonetCon API를 이용하여 앱 내 포인트를 실제 상품권으로 전환하는 기능이 구현되었습니다. 사용자는 '내 정보' 페이지의 '포인트 전환' 버튼을 통해 포인트를 상품권으로 교환할 수 있습니다.

## 구현된 기능

### 🎯 핵심 기능
- **포인트 → 상품권 전환**: 1,000P = 100,000원 상품권
- **HonetCon API 연동**: 실제 상품권 발급 서비스
- **이메일 전송**: 상품권 코드를 이메일로 발송
- **전환 히스토리**: 전환 내역 추적 및 상태 확인

### 🛠️ 기술 구현

#### 1. HonetCon API Service (`lib/services/honetcon_api_service.dart`)
```dart
class HonetConApiService {
  // 포인트를 상품권으로 전환
  Future<GiftCardExchangeResult> exchangePointsToGiftCard();
  
  // 사용 가능한 상품권 종류 조회
  Future<List<GiftCardType>> getAvailableGiftCardTypes();
  
  // 전환 상태 확인
  Future<ExchangeStatus> checkExchangeStatus();
}
```

#### 2. Point Exchange Provider (`lib/providers/point_exchange_provider.dart`)
- Riverpod를 이용한 상태 관리
- 포인트 차감 및 전환 프로세스 관리
- 오류 처리 및 사용자 피드백

#### 3. UI Integration (`lib/screens/point_exchange/point_exchange_main_screen.dart`)
- 사용자 입력 다이얼로그 (이메일, 전화번호, 메모)
- 실시간 로딩 상태 표시
- 전환 성공/실패 피드백

## 사용 방법

### 1. 사용자 플로우
1. **내 정보 페이지** → **포인트 전환** 버튼 클릭
2. **전환신청하기** 버튼 클릭
3. **상품권 정보 입력**:
   - 이메일 주소 (필수)
   - 전화번호 (선택)
   - 메모 (선택)
4. **전환 처리** → **성공 페이지** 이동

### 2. 시스템 프로세스
1. **포인트 확인**: 사용자 보유 포인트 검증 (최소 1,000P)
2. **HonetCon API 호출**: 상품권 발급 요청
3. **포인트 차감**: 성공 시 사용자 포인트에서 차감
4. **이메일 발송**: 상품권 정보를 사용자 이메일로 전송

## API 설정

### HonetCon API 설정 필요사항

1. **API 키 설정**:
```dart
// lib/services/honetcon_api_service.dart
static const String _apiKey = 'YOUR_HONETCON_API_KEY'; // 실제 API 키로 교체
```

2. **API 엔드포인트**:
```dart
static const String _baseUrl = 'https://api.honetcon.com/v1';
```

### API 요청 구조

#### 상품권 전환 요청
```json
POST /giftcard/exchange
{
  "user_id": "string",
  "points": 1000,
  "gift_card_type": "random",
  "gift_card_value": 100000,
  "recipient_email": "user@example.com",
  "recipient_phone": "010-1234-5678",
  "message": "추가 메모",
  "exchange_timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### 응답 구조
```json
{
  "success": true,
  "exchange_id": "exc_123456789",
  "gift_card_id": "gc_987654321",
  "gift_card_code": "ABCD-1234-EFGH-5678",
  "gift_card_type": "hyundai_dept",
  "gift_card_value": 100000,
  "points_deducted": 1000,
  "status": "pending",
  "exchange_date": "2024-01-01T00:00:00.000Z",
  "estimated_delivery_date": "2024-01-15T00:00:00.000Z"
}
```

## 데이터 모델

### GiftCardExchangeResult
- `exchangeId`: 전환 거래 ID
- `giftCardId`: 상품권 ID
- `giftCardCode`: 상품권 사용 코드
- `giftCardType`: 상품권 종류 (현대, 신세계, 롯데 등)
- `pointsDeducted`: 차감된 포인트
- `status`: 처리 상태
- `estimatedDeliveryDate`: 예상 배송일

### GiftCardType
- `id`: 상품권 타입 ID
- `name`: 상품권 이름
- `brand`: 브랜드명
- `availableValues`: 사용 가능한 금액
- `conversionRate`: 포인트 전환 비율

## 오류 처리

### 일반적인 오류 상황
1. **보유 포인트 부족**: 최소 1,000P 필요
2. **이메일 형식 오류**: 올바른 이메일 주소 검증
3. **API 통신 실패**: 네트워크 오류 처리
4. **상품권 발급 실패**: HonetCon 서버 오류

### 오류 메시지 예시
```dart
try {
  // 전환 로직
} on HonetConApiException catch (e) {
  // API 특정 오류 처리
  _showErrorDialog(e.message);
} catch (e) {
  // 일반 오류 처리
  _showErrorDialog('전환 중 오류가 발생했습니다: $e');
}
```

## 보안 고려사항

1. **API 키 보안**: 실제 배포 시 환경변수 또는 보안 저장소 사용
2. **사용자 인증**: 로그인된 사용자만 전환 가능
3. **중복 요청 방지**: 동시 전환 요청 차단
4. **포인트 검증**: 실시간 포인트 잔액 확인

## 테스트 방법

### 1. 개발 환경 테스트
```dart
// debug_config.dart에서 테스트 모드 활성화
static const bool enableTestMode = kDebugMode && true;
```

### 2. API 테스트 도구
- Postman 또는 Insomnia를 이용한 API 엔드포인트 테스트
- Mock 서버를 이용한 응답 시뮬레이션

### 3. 단위 테스트
```dart
test('포인트 전환 성공 테스트', () async {
  // Given
  final service = HonetConApiService();
  
  // When
  final result = await service.exchangePointsToGiftCard(...);
  
  // Then
  expect(result.success, true);
  expect(result.pointsDeducted, 1000);
});
```

## 배포 체크리스트

- [ ] HonetCon API 키 설정
- [ ] 프로덕션 API 엔드포인트 확인
- [ ] 오류 로깅 설정
- [ ] 사용자 가이드 업데이트
- [ ] 상품권 브랜드별 이미지 추가
- [ ] 전환 한도 설정 (일일/월별)

## 향후 개선사항

1. **다양한 상품권 브랜드**: 사용자 선택 옵션 추가
2. **전환 히스토리**: 상세한 전환 내역 페이지
3. **푸시 알림**: 상품권 발급 완료 알림
4. **자동 전환**: 설정된 포인트 달성 시 자동 전환
5. **상품권 관리**: 발급된 상품권 통합 관리 기능

## 문의 및 지원

- **API 문의**: HonetCon 고객지원센터
- **기술 문의**: 개발팀 슬랙 채널
- **오류 보고**: GitHub Issues 또는 버그 트래킹 시스템