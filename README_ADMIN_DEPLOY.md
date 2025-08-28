# 관리자 페이지 GitHub Pages 배포 가이드

## 개요
`admin_main.dart`를 GitHub Pages에 배포하여 웹에서 관리자 대시보드에 접근할 수 있도록 설정합니다.

## 배포 과정

### 1. 자동 배포 (GitHub Actions)
- 파일 위치: `.github/workflows/deploy-admin.yml`
- 트리거: `development` 또는 `main` 브랜치에 push할 때 자동 실행
- 배포 URL: `https://jini093.github.io/dating_meet_app/admin/`

### 2. 수동 배포 (로컬에서)

#### 2-1. Flutter Web 활성화
```bash
flutter config --enable-web
```

#### 2-2. 관리자 앱 빌드
```bash
flutter build web \
  --web-renderer html \
  --base-href "/dating_meet_app/" \
  --target lib/admin_main.dart \
  --output build/admin_web
```

#### 2-3. GitHub Pages 설정
1. GitHub 저장소 → Settings → Pages
2. Source: Deploy from a branch
3. Branch: gh-pages (GitHub Actions에서 자동 생성)
4. Folder: / (root)

### 3. 접근 URL
- 메인 URL: `https://jini093.github.io/dating_meet_app/admin/`
- 대시보드: `https://jini093.github.io/dating_meet_app/admin/#/admin/dashboard`

## 파일 구조

```
.github/workflows/
├── deploy-admin.yml          # 자동 배포 워크플로우

web/
├── admin_index.html          # 관리자용 HTML 템플릿
├── index.html                # 일반 앱용 HTML
├── manifest.json
└── favicon.png

lib/
├── admin_main.dart           # 관리자 앱 진입점
├── main.dart                 # 일반 앱 진입점
└── admin/                    # 관리자 관련 파일들
```

## 주의사항

### 1. 보안 고려사항
- **중요**: 프로덕션 환경에서는 인증 시스템 활성화 필요
- 현재 `admin_main.dart`는 인증 없이 모든 관리자 기능 접근 가능
- AWS Amplify 인증 설정 필요

### 2. API 연동
- AWS Amplify 설정이 웹에서도 작동하는지 확인
- CORS 설정 확인
- API 엔드포인트가 HTTPS인지 확인

### 3. 성능 최적화
```bash
# 최적화된 빌드
flutter build web \
  --web-renderer html \
  --base-href "/dating_meet_app/" \
  --target lib/admin_main.dart \
  --output build/admin_web \
  --release \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://unpkg.com/canvaskit-wasm@0.33.0/bin/
```

## 배포 확인

### 1. 로컬 테스트
```bash
# 로컬 서버로 테스트
cd build/admin_web
python -m http.server 8000
# 브라우저에서 http://localhost:8000 접속
```

### 2. 빌드 로그 확인
- GitHub Actions 탭에서 워크플로우 실행 상태 확인
- 빌드 오류 시 로그에서 원인 파악

### 3. 브라우저 개발자 도구
- Console에서 JavaScript 오류 확인
- Network 탭에서 리소스 로딩 확인

## 문제 해결

### 1. 빌드 실패
```bash
# 의존성 확인
flutter pub get

# 웹 지원 확인
flutter devices

# 캐시 정리
flutter clean
flutter pub get
```

### 2. 라우팅 문제
- `base-href` 설정 확인
- GoRouter 설정에서 경로 확인

### 3. AWS 연동 문제
- Amplify 설정 파일 확인
- CORS 정책 확인
- API Gateway 설정 확인

## 업데이트 방법

1. 코드 수정
2. Git에 커밋 및 푸시
```bash
git add .
git commit -m "관리자 페이지 업데이트"
git push origin development
```
3. GitHub Actions에서 자동 배포 확인
4. 배포 URL에서 업데이트 확인

## 도메인 연결 (선택사항)

### Custom Domain 설정
1. 도메인 구매 (예: admin.datingmeet.com)
2. GitHub Pages 설정에서 Custom domain 입력
3. DNS 설정:
```
Type: CNAME
Name: admin
Value: jini093.github.io
```

### SSL 인증서
- GitHub Pages는 자동으로 Let's Encrypt SSL 제공
- Custom domain 설정 후 자동 활성화

## 모니터링

### 1. 사용량 추적
- Google Analytics 연동 가능
- GitHub Pages는 기본적으로 사용량 제한 있음

### 2. 에러 추적
- Sentry 또는 기타 에러 추적 도구 연동
- 브라우저 Console 로그 모니터링

## 백업 및 복구

### 1. 코드 백업
- Git 저장소가 백업 역할
- 정기적인 브랜치 백업 권장

### 2. 배포 히스토리
- GitHub Actions에서 이전 배포 버전 확인 가능
- 필요 시 특정 커밋으로 롤백

---

**배포 완료 후 접속 URL**: https://jini093.github.io/dating_meet_app/admin/