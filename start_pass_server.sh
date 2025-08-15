#!/bin/bash

# PASS 인증 웹서버 시작 스크립트

echo "🚀 PASS 인증 웹서버 시작"
echo "📍 서버 주소: http://localhost:8080"
echo "📂 문서 루트: $(pwd)"

# PHP 개발 서버 시작
echo "⚡ PHP 개발 서버 시작 중..."
# iOS 시뮬레이터를 위해 모든 인터페이스에서 수신
php -S 0.0.0.0:8080 -t . &

SERVER_PID=$!

echo "✅ 서버가 시작되었습니다. (PID: $SERVER_PID)"
echo "🌐 PASS 인증 URL: http://localhost:8080/pass/mok_std_request.php"
echo ""
echo "🔍 테스트 방법:"
echo "1. Flutter 앱에서 PASS 인증 버튼 클릭"
echo "2. 웹뷰에서 PASS 인증 진행"
echo "3. 인증 결과 확인"
echo ""
echo "⚠️  주의사항:"
echo "- mok_keyInfo.dat 파일이 pass/ 디렉토리에 있는지 확인"
echo "- 키 패스워드가 올바른지 확인"
echo "- 네트워크 연결 상태 확인"
echo ""
echo "🛑 서버 중지: Ctrl+C 또는 kill $SERVER_PID"

# 서버 프로세스 대기
wait $SERVER_PID