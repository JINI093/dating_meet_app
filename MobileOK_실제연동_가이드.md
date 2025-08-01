# MobileOK 실제 연동 가이드

## 🎯 현재 상황

### ✅ 완료된 사항
1. **MobileOK 키 정보 설정 완료**
   - 키 파일: `mok_keyInfo.dat 2` 
   - 패스워드: `Sinsa507!`
   - Client Prefix: `61624356-3699-4e48-aa27-41f1652eb928`

2. **Flutter 클라이언트 구현 완료**
   - 웹뷰 기반 인증 UI
   - JavaScript SDK 연동
   - 인증 결과 처리 로직

### ⚠️ 추가 필요사항

## 1. 서버 측 구현 필요

MobileOK는 보안상 서버 측 처리가 필수입니다. PHP 예제 코드를 참고하여 다음 API 엔드포인트 구현이 필요합니다:

### 1.1 인증 요청 API
```
POST /api/mobileok/request
```
- 키 파일로 데이터 암호화
- 거래 ID 생성 및 세션 저장
- MobileOK 서버로 전달할 데이터 생성

### 1.2 인증 결과 수신 API  
```
POST /api/mobileok/result
```
- MobileOK 서버에서 결과 수신
- 데이터 복호화 및 검증
- 클라이언트로 결과 전달

## 2. 서버 구현 옵션

### 옵션 A: AWS Lambda 사용 (권장)
```javascript
// lambda/mobileok-request.js
exports.handler = async (event) => {
    // 1. 키 파일 로드 (S3 또는 환경변수)
    // 2. 거래 정보 암호화
    // 3. MobileOK 요청 데이터 생성
    // 4. 응답 반환
};
```

### 옵션 B: Express.js 서버
```javascript
// server/mobileok.js
app.post('/api/mobileok/request', async (req, res) => {
    // PHP 로직을 JavaScript로 변환
});
```

### 옵션 C: PHP 서버 직접 사용
- 제공된 PHP 파일들을 서버에 배포
- Flutter에서 해당 URL로 요청

## 3. 현재 작동 방식

### 시뮬레이션 모드
현재는 실제 서버 연동 없이 시뮬레이션으로 작동:
```dart
// 강제 시뮬레이션 활성화
additionalParams: {
  'forceSimulation': true
}
```

### 실제 연동 시
1. 서버 API 구현 완료
2. Flutter 코드에서 API URL 설정
3. 웹뷰에서 서버 API 호출

## 4. 빠른 테스트 방법

### 4.1 임시 서버 구축
```bash
# PHP 내장 서버 사용
cd pass/
php -S localhost:8000
```

### 4.2 ngrok으로 외부 접근 허용
```bash
ngrok http 8000
```

### 4.3 Flutter 코드 수정
```dart
// mobileok_verification_service.dart
const requestUrl = 'https://[ngrok-url]/mok_std_request.php';
```

## 5. 주요 파일 역할

- `mok_std_request.php`: 인증 요청 생성
- `mok_std_result.php`: 인증 결과 처리
- `mobileOK_manager_*.php`: 암호화/복호화 처리

## 6. 보안 주의사항

1. **키 파일 보호**
   - 서버에만 저장
   - 클라이언트에 노출 금지

2. **세션 검증**
   - 거래 ID 일치 확인
   - 시간 제한 검증

3. **HTTPS 필수**
   - 모든 통신 암호화

## 7. 다음 단계

1. **서버 구현 방식 결정**
2. **API 엔드포인트 개발**
3. **Flutter 코드와 연동**
4. **실제 인증 테스트**

## 8. 임시 해결방안

서버 구현 전까지는:
- 시뮬레이션 모드 사용
- 개발/테스트 진행
- UI/UX 완성

실제 운영 시 서버 API만 연결하면 즉시 사용 가능합니다.