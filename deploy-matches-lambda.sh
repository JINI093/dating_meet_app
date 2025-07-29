#!/bin/bash

# AWS Lambda 배포 스크립트 - Matches Handler

echo "Matches Lambda 함수 배포 시작..."

# 작업 디렉토리 생성
WORK_DIR="lambda-matches-temp"
mkdir -p $WORK_DIR

# 파일 복사
cp lambda_matches_handler.js $WORK_DIR/
cd $WORK_DIR

# package.json 생성
cat > package.json << 'EOF'
{
  "name": "dating-app-matches-handler",
  "version": "1.0.0",
  "description": "Dating app matches handler",
  "main": "lambda_matches_handler.js",
  "dependencies": {
    "@aws-sdk/client-dynamodb": "^3.454.0",
    "@aws-sdk/lib-dynamodb": "^3.454.0"
  }
}
EOF

# 의존성 설치
npm install

# ZIP 파일 생성
zip -r ../lambda-matches-handler.zip .

# 정리
cd ..
rm -rf $WORK_DIR

# Lambda 함수 생성 또는 업데이트
echo "Lambda 함수 배포 중..."

# 함수가 존재하는지 확인
if aws lambda get-function --function-name dating-app-matches-handler --region ap-northeast-2 2>/dev/null; then
    echo "기존 함수 업데이트 중..."
    aws lambda update-function-code \
        --function-name dating-app-matches-handler \
        --zip-file fileb://lambda-matches-handler.zip \
        --region ap-northeast-2
else
    echo "새 함수 생성 중..."
    aws lambda create-function \
        --function-name dating-app-matches-handler \
        --runtime nodejs18.x \
        --role arn:aws:iam::213265226405:role/service-role/dating-app-likes-handler-role-02vhjwht \
        --handler lambda_matches_handler.handler \
        --zip-file fileb://lambda-matches-handler.zip \
        --timeout 30 \
        --memory-size 256 \
        --region ap-northeast-2
fi

echo "배포 완료!"
echo "생성된 파일:"
echo "- lambda-matches-handler.zip"