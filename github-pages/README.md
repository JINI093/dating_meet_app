# PASS 인증 서버 - GitHub Pages

이 레포지토리는 PASS 본인인증을 위한 웹 인터페이스를 GitHub Pages로 호스팅합니다.

## 📋 파일 구조

```
├── index.html          # 메인 페이지
├── test.html           # 서버 연결 테스트 페이지
├── pass-auth.html      # PASS 인증 메인 페이지
├── pass-simple.html    # PASS 인증 시뮬레이션 페이지
└── README.md          # 이 파일
```

## 🌐 접근 URL

- **메인 페이지**: https://jini093.github.io/sagilrae-temp/
- **테스트 페이지**: https://jini093.github.io/sagilrae-temp/test.html
- **PASS 인증**: https://jini093.github.io/sagilrae-temp/pass-auth.html

## ⚠️ 중요 사항

### GitHub Pages 제한사항
- **정적 파일만 지원**: PHP, 서버사이드 스크립트 불가
- **외부 API 제한**: CORS 정책으로 일부 외부 API 호출 제한
- **HTTPS 강제**: 모든 접근이 HTTPS로 자동 리다이렉트

### PASS 인증 동작
- **시뮬레이션 모드**: 실제 PASS API 대신 테스트 데이터 사용
- **WebView 호환**: Flutter WebView에서 정상 작동
- **결과 전송**: JavaScript PostMessage로 결과 전달

## 🚀 배포 방법

1. **GitHub 레포지토리에 파일 업로드**
   ```bash
   git add .
   git commit -m "PASS 인증 페이지 추가"
   git push origin main
   ```

2. **GitHub Pages 활성화**
   - Repository Settings → Pages
   - Source: Deploy from a branch
   - Branch: main / (root)

3. **자동 배포**
   - 파일 변경 시 자동으로 재배포됨
   - 보통 1-2분 내에 반영

## 📱 Flutter 앱 설정

Flutter 앱에서 다음 URL을 사용하도록 설정:

```dart
_webServerUrl = 'https://jini093.github.io/sagilrae-temp';
_webPassUrl = '$_webServerUrl/pass-auth.html';
```

## 🔧 개발 및 테스트

### 로컬 테스트
```bash
# 간단한 HTTP 서버 실행
python -m http.server 8000
# 또는
python3 -m http.server 8000

# 브라우저에서 http://localhost:8000 접근
```

### 디버깅
- 브라우저 개발자 도구 콘솔 확인
- Flutter 앱에서 WebView 디버깅 활성화

## 📞 지원

문제가 발생하면:
1. GitHub Pages 상태 확인
2. 브라우저 콘솔 로그 확인  
3. Flutter WebView 설정 확인
4. CORS 오류 여부 확인

## 🔄 업데이트 이력

- **2024-XX-XX**: 초기 GitHub Pages 설정
- **2024-XX-XX**: PASS 인증 시뮬레이션 모드 추가
- **2024-XX-XX**: Flutter WebView 호환성 개선