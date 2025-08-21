# PASS 인증 서버 배포 가이드

## 개요
sagilrae.com 도메인에 PASS 인증 파일을 배포하는 방법을 설명합니다.

## 서버 준비사항

### 1. 필요한 PHP 확장 모듈
- PHP 7.0 이상
- OpenSSL
- mbstring
- json
- curl
- composer (phpseclib 설치용)

### 2. 디렉토리 구조
```
/public_html/mok/
├── mok.html
├── mok_std_request.php
├── mok_std_result.php
├── mok_keyInfo.dat
├── mok_simple.html
├── mobileOK_manager_phpseclib_v3.0_v1.0.2.php
├── phpseclib_path_3.0.php
├── debug.php
├── test.html
└── vendor/ (phpseclib 설치 후 생성)
```

## 배포 순서

### 1. 서버에 mok 디렉토리 생성
```bash
mkdir -p /public_html/mok
```

### 2. 파일 업로드
FTP 또는 SSH를 통해 `/pass/` 디렉토리의 모든 파일을 서버의 `/public_html/mok/` 디렉토리로 업로드

### 3. phpseclib 설치
```bash
cd /public_html/mok
composer require phpseclib/phpseclib:~3.0
```

### 4. 파일 권한 설정
```bash
chmod 644 *.php *.html
chmod 600 mok_keyInfo.dat  # 키 파일은 보안을 위해 읽기 권한만
```

### 5. SSL 인증서 확인
- https://sagilrae.com 이 정상적으로 작동하는지 확인
- Let's Encrypt 등을 사용하여 SSL 인증서 설치

## 테스트

### 1. 브라우저에서 확인
```
https://sagilrae.com/mok/test.html
https://sagilrae.com/mok/debug.php
```

### 2. Flutter 앱에서 테스트
- 앱을 실행하고 회원가입 버튼 클릭
- 웹뷰에서 PASS 인증 페이지가 정상적으로 로드되는지 확인

## 보안 주의사항

### 1. 키 파일 보호
- `mok_keyInfo.dat` 파일은 웹에서 직접 접근할 수 없도록 설정
- .htaccess 파일 추가:
```apache
<Files "mok_keyInfo.dat">
    Order allow,deny
    Deny from all
</Files>
```

### 2. 에러 로그 숨기기
- PHP 에러가 화면에 표시되지 않도록 설정
```php
ini_set('display_errors', 0);
error_reporting(0);
```

### 3. CORS 설정 (필요시)
- Flutter 웹뷰에서 접근 시 CORS 문제가 발생하면 헤더 추가
```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');
```

## 운영 환경 전환

### 1. PASS API URL 변경
`mok_std_result.php` 파일에서:
```php
// 개발에서 운영으로 변경
$MOK_RESULT_REQUEST_URL = "https://cert.mobile-ok.com/gui/service/v1/result/request";  //운영
```

### 2. 키 파일 교체
- 개발용 키 파일을 운영용 키 파일로 교체

### 3. 환경변수 설정
Flutter 앱의 `.env` 파일:
```
WEB_SERVER_URL=https://sagilrae.com
ENVIRONMENT=production
```

## 문제 해결

### phpseclib 오류
- Composer가 설치되어 있지 않으면 수동으로 phpseclib 다운로드
- https://github.com/phpseclib/phpseclib/releases 에서 3.0 버전 다운로드

### PASS SDK 로드 실패
- JavaScript 콘솔에서 오류 확인
- 네트워크 탭에서 SDK 로드 상태 확인

### 인증 결과가 전달되지 않음
- PHP 세션 설정 확인
- 쿠키 정책 확인