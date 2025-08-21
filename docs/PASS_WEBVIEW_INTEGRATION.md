# PASS 웹뷰 통합 가이드

## 개요
이 문서는 Flutter 앱에서 웹뷰를 통한 PASS 본인인증 통합 방법을 설명합니다.

## 설정 방법

### 1. 웹서버 시작
```bash
# 프로젝트 루트에서 실행
./start_pass_server.sh
```

서버가 시작되면 http://localhost:8080 에서 접근 가능합니다.

### 2. PASS 인증 흐름

1. **회원가입 버튼 클릭**
   - 로그인 화면에서 "회원가입" 버튼 클릭
   
2. **웹뷰 PASS 인증 시작**
   - `PassVerificationService.startWebPassVerification()` 호출
   - 웹뷰로 `http://localhost:8080/pass/mok.html` 로드
   
3. **자동 인증 시작**
   - mok.html 로드 완료 시 자동으로 PASS 인증 버튼 클릭
   - PASS 표준창이 팝업으로 열림
   
4. **인증 진행**
   - 사용자가 PASS 앱에서 본인인증 진행
   - 인증 완료 시 결과가 mok_std_result.php로 전달
   
5. **결과 처리**
   - JavaScript 채널을 통해 Flutter로 결과 전송
   - 성공 시 회원가입 화면으로 이동 (인증 정보 포함)

## 파일 구조

```
/pass/
├── mok.html                    # PASS 인증 시작 페이지
├── mok_std_request.php         # PASS 요청 처리
├── mok_std_result.php          # PASS 결과 처리
├── mok_keyInfo.dat            # PASS 인증키 파일
├── mobileOK_manager_phpseclib_v3.0_v1.0.2.php  # PASS SDK
└── phpseclib_path_3.0.php     # 암호화 라이브러리 경로 설정
```

## 주요 설정 값

### PHP 파일 설정
- **mok_std_request.php**
  - 결과 URL: `http://localhost:8080/pass/mok_std_result.php`
  - 클라이언트 ID: `61624356-3699-4e48-aa27-41f1652eb928`
  
- **mok_std_result.php**
  - 키 파일 경로: `./mok_keyInfo.dat`
  - 키 패스워드: `Sinsa507!`
  - API URL (개발): `https://scert.mobile-ok.com/gui/service/v1/result/request`

### Flutter 설정
- **PassVerificationService**
  - 웹서버 URL: `http://localhost:8080`
  - PASS 페이지: `/pass/mok.html`
  - JavaScript 채널: `PassChannel`

## 테스트 방법

1. PHP 개발 서버 시작
2. Flutter 앱 실행
3. 로그인 화면에서 "회원가입" 버튼 클릭
4. 웹뷰에서 PASS 인증 진행
5. 인증 완료 후 회원가입 화면 확인

## 주의사항

1. **키 파일 보안**
   - `mok_keyInfo.dat` 파일은 절대 Git에 커밋하지 마세요
   - 운영 환경에서는 안전한 경로에 별도 보관
   
2. **개발/운영 환경 분리**
   - 개발: https://scert.mobile-ok.com
   - 운영: https://cert.mobile-ok.com
   
3. **CORS 설정**
   - 로컬 테스트 시 CORS 이슈 발생 가능
   - 필요시 Chrome에서 --disable-web-security 플래그 사용

## 문제 해결

### PASS 인증창이 열리지 않는 경우
1. 팝업 차단 해제 확인
2. JavaScript 콘솔에서 오류 확인
3. 네트워크 연결 상태 확인

### 인증 결과가 전달되지 않는 경우
1. JavaScript 채널 설정 확인
2. PHP 세션 설정 확인
3. 결과 URL 경로 확인

### 키 파일 오류
1. 키 파일 경로 확인
2. 패스워드 확인
3. 파일 권한 확인 (읽기 권한 필요)