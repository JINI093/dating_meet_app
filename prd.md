# Flutter 데이팅앱 기능 구현 PRD (Product Requirements Document)

## 프로젝트 개요
- **목표**: 기존 UI를 유지하면서 Flutter 데이팅앱의 핵심 기능 구현
- **제약사항**: UI 절대 변경 금지, 테스트용 검증 우회 기능 제거
- **백엔드**: AWS 기반 (기본 설정 완료)

## 1. 프로젝트 분석 및 준비
**요구사항:**
- 현재 UI 구조와 플로우 분석
- 테스트용 필수항목 검증 우회 기능 완전 제거
- 기존 AWS 설정 확인 및 검증

## 2. AWS 인증 및 로그인 기능 구현
**핵심 기능:**
- AWS Cognito 기반 사용자 인증
- 회원가입, 로그인, 로그아웃
- JWT 토큰 관리 및 자동 갱신
- 인증 상태에 따른 화면 라우팅

**기술 요구사항:**
- 기존 AWS 설정 코드 활용
- 토큰 로컬 저장 (secure_storage)
- 인증 실패 시 적절한 에러 메시지 표시

## 3. 프로필 등록 및 서버 저장
**핵심 기능:**
- 사용자 프로필 정보 수집 및 검증
- 이미지 업로드 (AWS S3)
- 프로필 데이터 저장 (DynamoDB/RDS)
- 프로필 수정 및 조회

**데이터 필드:**
- 기본 정보: 이름, 나이, 성별, 지역
- 상세 정보: 직업, 학력, 취미, 자기소개
- 이미지: 프로필 사진 (최대 6장)
- 설정: 매칭 조건, 알림 설정

**검증 규칙:**
- 필수 항목 검증 로직 강화
- 이미지 크기 및 형식 제한
- 부적절한 콘텐츠 필터링

## 4. 호감 전송 기능
**핵심 기능:**
- 다른 사용자에게 호감 표시 (Like/Pass)
- 호감 데이터 서버 저장
- 중복 호감 방지
- 일일 호감 전송 제한

**비즈니스 로직:**
- 하루 호감 전송 제한 (예: 20회)
- 이미 평가한 사용자 재표시 방지
- 호감 받은 사용자 알림

## 5. 슈퍼챗 전송 기능
**핵심 기능:**
- 프리미엄 메시지 전송
- 포인트/결제 시스템 연동
- 슈퍼챗 우선순위 처리
- 전송 이력 관리

**비즈니스 로직:**
- 슈퍼챗 비용 차감
- 매칭 전 메시지 전송 가능
- 상대방 알림 우선순위 높음

## 6. 매칭 및 채팅 기능
**핵심 기능:**
- 상호 호감 시 매칭 성사
- 실시간 채팅 (WebSocket/AppSync)
- 채팅 메시지 저장 및 동기화
- 매칭 상대 목록 관리

**기술 요구사항:**
- 실시간 메시지 송수신
- 메시지 읽음 상태 표시
- 채팅방 생성 및 관리
- 오프라인 메시지 동기화

## 데이터 모델 설계

### User
```json
{
  "userId": "string",
  "email": "string",
  "cognitoId": "string",
  "createdAt": "timestamp",
  "lastActive": "timestamp"
}
```

### Profile
```json
{
  "userId": "string",
  "name": "string",
  "age": "number",
  "gender": "string",
  "location": "string",
  "bio": "string",
  "photos": ["string"],
  "interests": ["string"],
  "occupation": "string",
  "education": "string"
}
```

### Like
```json
{
  "fromUserId": "string",
  "toUserId": "string",
  "isLike": "boolean",
  "isSuperChat": "boolean",
  "message": "string",
  "createdAt": "timestamp"
}
```

### Match
```json
{
  "matchId": "string",
  "user1Id": "string",
  "user2Id": "string",
  "createdAt": "timestamp",
  "lastMessageAt": "timestamp"
}
```

### Message
```json
{
  "messageId": "string",
  "matchId": "string",
  "senderId": "string",
  "content": "string",
  "messageType": "text|image|superChat",
  "isRead": "boolean",
  "createdAt": "timestamp"
}
```

## API 엔드포인트

### 인증
- `POST /auth/register` - 회원가입
- `POST /auth/login` - 로그인
- `POST /auth/refresh` - 토큰 갱신
- `POST /auth/logout` - 로그아웃

### 프로필
- `GET /profile/me` - 내 프로필 조회
- `PUT /profile/me` - 프로필 수정
- `POST /profile/photos` - 사진 업로드
- `GET /profile/discover` - 매칭 대상 조회

### 호감/매칭
- `POST /likes` - 호감 전송
- `POST /likes/super` - 슈퍼챗 전송
- `GET /matches` - 매칭 목록
- `GET /likes/received` - 받은 호감 목록

### 채팅
- `GET /matches/{matchId}/messages` - 채팅 메시지 조회
- `POST /matches/{matchId}/messages` - 메시지 전송
- `PUT /messages/{messageId}/read` - 읽음 처리

## 보안 요구사항
- JWT 토큰 기반 인증
- API 호출 시 Authorization 헤더 필수
- 사용자별 데이터 접근 권한 검증
- 이미지 업로드 시 악성 파일 검사
- 개인정보 암호화 저장

## 성능 요구사항
- 앱 실행 후 3초 내 메인 화면 로딩
- 채팅 메시지 1초 내 전송
- 이미지 업로드 10초 내 완료
- 매칭 대상 조회 2초 내 완료

## 에러 처리
- 네트워크 연결 오류 처리
- 서버 에러 시 재시도 로직
- 사용자 친화적 에러 메시지
- 로그 수집 및 모니터링

## 테스트 요구사항
- 각 기능별 단위 테스트
- 통합 테스트 시나리오
- 성능 테스트
- 보안 테스트

## 배포 및 모니터링
- AWS 인프라 배포 자동화
- 로그 수집 및 분석
- 성능 모니터링
- 에러 트래킹

## 개발 우선순위
1. **Phase 1**: 인증 및 프로필 등록
2. **Phase 2**: 호감 전송 및 매칭
3. **Phase 3**: 채팅 기능
4. **Phase 4**: 슈퍼챗 및 고급 기능