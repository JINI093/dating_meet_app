# Java PASS 본인인증 API 서버

이 프로젝트는 Flutter 앱에서 사용할 수 있는 Java 기반의 PASS 본인인증 API 서버입니다.

## 📁 프로젝트 구조

```
pass/java/
├── MobileOKController.java      # PASS 인증 API 컨트롤러
├── PassApiApplication.java      # Spring Boot 메인 애플리케이션
├── application.properties       # 애플리케이션 설정
├── pom.xml                     # Maven 프로젝트 설정
└── README.md                   # 이 파일
```

## 🚀 시작하기

### 1. 필수 요구사항

- Java 8 이상
- Maven 3.6 이상
- PASS 키 파일 (`mok_keyInfo.dat`)

### 2. 설정

1. **키 파일 설정**
   ```properties
   # application.properties
   mobileok.keyfile.path=/path/to/mok_keyInfo.dat
   mobileok.keyfile.password=your_key_password
   mobileok.client.prefix=DATING_APP_
   mobileok.return.url=https://your-domain.com/pass-api/api/pass/result
   mobileok.service.id=your_service_id
   ```

2. **PASS SDK JAR 파일 복사**
   ```bash
   # pass/WEB-INF/lib/mobileOKManager-jdk1.8_1.0.1.jar를
   # pass/java/lib/ 디렉토리로 복사
   cp ../WEB-INF/lib/mobileOKManager-jdk1.8_1.0.1.jar lib/
   ```

### 3. 빌드 및 실행

```bash
# 프로젝트 디렉토리로 이동
cd pass/java

# Maven으로 빌드
mvn clean package

# 애플리케이션 실행
java -jar target/pass-api-1.0.0.jar
```

또는 Maven으로 직접 실행:
```bash
mvn spring-boot:run
```

## 📡 API 엔드포인트

### 1. 인증 요청 생성
```
POST /api/pass/request
```

**응답 예시:**
```json
{
  "success": true,
  "requestData": "{\"usageCode\":\"01001\",\"serviceId\":\"...\",\"encryptReqClientInfo\":\"...\"}",
  "clientTxId": "DATING_APP_1234567890abcdef"
}
```

### 2. 인증 결과 처리
```
POST /api/pass/result
```

**요청 본문:**
```json
{
  "data": "encrypted_result_data_from_pass"
}
```

**응답 예시:**
```json
{
  "success": true,
  "result": {
    "resultCode": "0000",
    "resultMsg": "성공",
    "userName": "홍길동",
    "userPhone": "01012345678",
    "userBirthday": "19900101",
    "userGender": "1",
    "ci": "encrypted_ci",
    "di": "encrypted_di",
    "txId": "pass_transaction_id",
    "clientTxId": "DATING_APP_1234567890abcdef"
  }
}
```

## 🔧 Flutter 연동

### 1. 환경변수 설정
```env
# .env 파일
JAVA_PASS_API_URL=http://localhost:8080/pass-api
```

### 2. Flutter에서 사용
```dart
import 'package:your_app/services/java_pass_service.dart';

final passService = JavaPassService();
await passService.initialize();

final result = await passService.startVerification(
  context: context,
  purpose: '회원가입',
);
```

## 🔒 보안 고려사항

1. **키 파일 보안**
   - 키 파일은 웹 접근이 불가능한 안전한 경로에 저장
   - 파일 권한을 적절히 설정 (600 또는 400)

2. **HTTPS 사용**
   - 운영 환경에서는 반드시 HTTPS 사용
   - SSL 인증서 설정

3. **세션 관리**
   - 세션 타임아웃 설정 (기본 10분)
   - 세션 하이재킹 방지

4. **입력 검증**
   - 모든 입력 데이터 검증
   - SQL 인젝션 방지

## 🐛 문제 해결

### 1. 키 파일 오류
```
MobileOKException: 키 파일을 찾을 수 없습니다.
```
- 키 파일 경로 확인
- 파일 권한 확인
- 패스워드 확인

### 2. 네트워크 오류
```
Connection refused
```
- PASS 서버 URL 확인
- 방화벽 설정 확인
- 네트워크 연결 확인

### 3. 세션 오류
```
세션값에 저장된 거래ID 비교 실패
```
- 세션 설정 확인
- 세션 타임아웃 확인
- 동시 요청 처리 확인

## 📝 개발 환경

### 개발 URL
- PASS 개발 서버: `https://scert.mobile-ok.com`

### 운영 URL
- PASS 운영 서버: `https://cert.mobile-ok.com`

## 🔄 배포

### 1. JAR 파일 생성
```bash
mvn clean package -DskipTests
```

### 2. 서버 배포
```bash
# 서버에 JAR 파일 업로드
scp target/pass-api-1.0.0.jar user@server:/app/

# 서버에서 실행
java -jar /app/pass-api-1.0.0.jar
```

### 3. Docker 배포 (선택사항)
```dockerfile
FROM openjdk:8-jre-alpine
COPY target/pass-api-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

## 📞 지원

문제가 발생하면 다음을 확인하세요:

1. 로그 확인: `tail -f logs/application.log`
2. PASS 공식 문서 참조
3. 드림시큐리티 기술지원 문의

## 📄 라이선스

이 프로젝트는 PASS 본인인증 서비스를 위한 구현체입니다.
PASS 서비스 이용약관을 준수하여 사용하세요.
