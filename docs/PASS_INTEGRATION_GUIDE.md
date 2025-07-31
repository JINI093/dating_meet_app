# PASS API 실제 연동 가이드

## 1. 필요한 준비사항

### 1.1 키 파일 처리
- **현재 상태**: `mok_keyInfo.dat 2` 파일이 바이너리 형태로 암호화됨
- **필요 작업**: 키 파일 파싱 및 개인키/공개키 추출

#### 방법 A: PASS에서 제공하는 도구 사용
```bash
# PASS SDK에서 제공하는 키 파싱 도구 사용
# (정확한 도구명은 PASS 문서 참조)
pass-key-parser -i "mok_keyInfo.dat 2" -o keys/
```

#### 방법 B: OpenSSL 사용 (표준 PKCS#12 형식인 경우)
```bash
# 개인키 추출
openssl pkcs12 -in "mok_keyInfo.dat 2" -out private_key.pem -nocerts -nodes

# 인증서 추출
openssl pkcs12 -in "mok_keyInfo.dat 2" -out certificate.pem -clcerts -nokeys

# 공개키 추출
openssl x509 -pubkey -noout -in certificate.pem > public_key.pem
```

### 1.2 환경변수 설정
키 추출 후 `.env` 파일에 실제 키 값 설정:

```env
# PASS 키 정보 (추출된 실제 값으로 교체)
PASS_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC...\n-----END PRIVATE KEY-----
PASS_PUBLIC_KEY=-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...\n-----END PUBLIC KEY-----
PASS_CERTIFICATE=-----BEGIN CERTIFICATE-----\nMIIDXTCCAkWgAwIBAgIJAKoK/OvD...\n-----END CERTIFICATE-----
```

## 2. API 엔드포인트 확인

### 2.1 개발환경
- **현재 설정**: `https://dev-pass.mobileid.go.kr`
- **상태**: 연결 불가 (Connection refused)

### 2.2 운영환경
- **일반적인 URL**: `https://pass.mobileid.go.kr` 또는 `https://api.pass.go.kr`
- **확인 필요**: PASS 공식 문서에서 정확한 운영 URL 확인

### 2.3 API 엔드포인트 구조
```
POST /api/v1/identity/verify     - 본인인증 요청
GET  /api/v1/identity/status/{txId} - 인증 상태 확인
POST /api/v1/identity/result     - 인증 결과 조회
```

## 3. 네트워크 및 보안 설정

### 3.1 방화벽 설정
- PASS 서버 IP 대역 허용
- 아웃바운드 HTTPS (443) 포트 허용

### 3.2 SSL/TLS 인증서
- PASS 서버의 SSL 인증서 신뢰 설정
- 클라이언트 인증서 설정 (필요한 경우)

### 3.3 콜백 URL 설정
- **현재**: `https://your-app.com/pass-callback`
- **변경 필요**: 실제 앱의 딥링크 스킴으로 변경
- **예시**: `meetapp://pass-callback`

## 4. 실제 연동 활성화 단계

### 4.1 시뮬레이션 모드 비활성화
```dart
// login_screen.dart에서 시뮬레이션 모드 제거
_navigateToPassVerification('소셜로그인', {
  'socialProvider': 'KAKAO',
  'socialLoginData': authState.currentUser?.toJson(),
  // 'enableSimulation': true, // 이 줄 제거
});
```

### 4.2 키 정보 확인
- `.env` 파일의 PASS 키 정보가 올바르게 설정되었는지 확인
- 앱 시작 시 키 로딩 로그 확인

### 4.3 네트워크 연결 테스트
```bash
# PASS 서버 연결 테스트
curl -v https://dev-pass.mobileid.go.kr/api/v1/health
curl -v https://pass.mobileid.go.kr/api/v1/health
```

## 5. 문제 해결

### 5.1 연결 오류 (Connection refused)
- **원인**: 잘못된 URL 또는 서버 다운
- **해결**: PASS 담당자에게 정확한 API URL 문의

### 5.2 인증 오류 (401/403)
- **원인**: 잘못된 서비스 ID 또는 서명
- **해결**: 키 정보 및 서명 알고리즘 확인

### 5.3 키 파싱 오류
- **원인**: 키 파일 형식 불일치
- **해결**: PASS에서 제공하는 공식 파싱 도구 사용

## 6. 연락처 및 지원

### 6.1 PASS 기술지원
- **담당자**: PASS API 기술지원팀
- **문의사항**: 
  - 정확한 API URL
  - 키 파일 파싱 방법
  - 서명 알고리즘 세부사항

### 6.2 체크리스트
- [ ] 키 파일 파싱 완료
- [ ] 환경변수에 실제 키 정보 설정
- [ ] 정확한 API URL 확인
- [ ] 네트워크 연결 테스트
- [ ] 시뮬레이션 모드 비활성화
- [ ] 실제 인증 테스트

## 7. 현재 구현 상태

✅ **완료된 사항**:
- PASS API 연동 구조 완성
- 에러 처리 및 폴백 시스템
- 시뮬레이션 모드 구현
- UI/UX 완성

⚠️ **추가 필요사항**:
- 키 파일 파싱
- 정확한 API URL 확인
- 실제 서버 연결 테스트