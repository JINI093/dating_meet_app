# MobileOK PHP 서버 설정 가이드

## 🚀 PHP 서버 설정 방법

### 1. PHP 설치 확인
```bash
php --version
```

### 2. Composer 설치 (phpseclib 설치용)
```bash
# macOS
brew install composer

# 또는 직접 다운로드
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
```

### 3. phpseclib 설치
```bash
cd /Users/sunwoo/Desktop/development/dating_meet_app/pass
composer require phpseclib/phpseclib:~3.0
```

### 4. PHP 내장 서버 실행
```bash
cd /Users/sunwoo/Desktop/development/dating_meet_app/pass
php -S localhost:8000
```

### 5. 테스트
브라우저에서 접속:
- http://localhost:8000/mok.html
- http://localhost:8000/mok_test_api.php

## 📱 Flutter 연동 설정

### Android 에뮬레이터에서 localhost 접근
Android 에뮬레이터에서는 `localhost` 대신 `10.0.2.2`를 사용:

```dart
// Android 에뮬레이터용
const phpServerUrl = 'http://10.0.2.2:8000';

// iOS 시뮬레이터 및 실제 기기용  
const phpServerUrl = 'http://localhost:8000';
```

### 실제 기기에서 테스트
1. 컴퓨터와 모바일이 같은 네트워크에 연결
2. 컴퓨터의 IP 주소 확인:
   ```bash
   ifconfig | grep "inet "
   ```
3. PHP 서버를 0.0.0.0으로 실행:
   ```bash
   php -S 0.0.0.0:8000
   ```
4. Flutter 코드에서 IP 주소 사용:
   ```dart
   const phpServerUrl = 'http://192.168.1.100:8000'; // 실제 IP로 변경
   ```

## 🔧 문제 해결

### CORS 오류
PHP 파일 상단에 추가:
```php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
```

### phpseclib 오류
vendor 폴더가 없는 경우:
1. composer 설치 후 재시도
2. 또는 phpseclib 수동 다운로드

### 키 파일 경로 오류
절대 경로 대신 상대 경로 사용:
```php
$key_path = __DIR__ . "/../mok_keyInfo.dat 2";
```

## 🌐 운영 환경 배포

### 옵션 1: AWS EC2
1. EC2 인스턴스 생성
2. Apache/Nginx + PHP 설치
3. SSL 인증서 설정 (HTTPS 필수)
4. 보안 그룹에서 443 포트 오픈

### 옵션 2: Heroku
1. Heroku 앱 생성
2. PHP buildpack 추가
3. 코드 배포

### 옵션 3: 기존 웹서버
1. FTP로 PHP 파일 업로드
2. 키 파일은 웹 루트 외부에 저장
3. 권한 설정 (키 파일은 600)

## 📝 체크리스트

- [ ] PHP 7.0 이상 설치
- [ ] Composer 설치
- [ ] phpseclib 3.0 설치
- [ ] 키 파일 경로 설정
- [ ] CORS 헤더 추가
- [ ] SSL 인증서 (운영환경)
- [ ] 방화벽 설정