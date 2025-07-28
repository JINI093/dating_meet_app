#!/bin/bash

# DynamoDB Lambda 함수들 배포 스크립트
echo "🚀 DynamoDB Lambda 함수들 배포 시작..."

# 임시 디렉토리 생성
DEPLOY_DIR="lambda-dynamodb-deploy"
rm -rf $DEPLOY_DIR
mkdir $DEPLOY_DIR

echo "📦 의존성 설치 중..."

# package.json 생성
cat > $DEPLOY_DIR/package.json << EOF
{
  "name": "dating-app-lambda-dynamodb",
  "version": "1.0.0",
  "dependencies": {
    "@aws-sdk/client-dynamodb": "^3.848.0",
    "@aws-sdk/lib-dynamodb": "^3.850.0",
    "uuid": "^10.0.0"
  }
}
EOF

# 의존성 설치
cd $DEPLOY_DIR
npm install --production

echo "📄 Lambda 함수 별도 패키지 생성 중..."

# Superchat Lambda 패키지 생성
echo "⭐ Superchat DynamoDB Lambda 패키지 생성..."
mkdir -p superchat-lambda
cp -r node_modules superchat-lambda/
cp ../lambda_superchat_dynamodb.js superchat-lambda/index.js
cd superchat-lambda && zip -r ../../superchat-lambda-dynamodb.zip . -x "*.git*" "*.DS_Store*" && cd ..

# Likes Lambda 패키지 생성
echo "🔥 Likes DynamoDB Lambda 패키지 생성..."
mkdir -p likes-lambda
cp -r node_modules likes-lambda/
cp ../lambda_likes_dynamodb.js likes-lambda/index.js
cd likes-lambda && zip -r ../../likes-lambda-dynamodb.zip . -x "*.git*" "*.DS_Store*" && cd ..

# Notifications Lambda 패키지 생성
echo "🔔 Notifications DynamoDB Lambda 패키지 생성..."
mkdir -p notifications-lambda
cp -r node_modules notifications-lambda/
cp ../lambda_notifications_dynamodb.js notifications-lambda/index.js
cd notifications-lambda && zip -r ../../notifications-lambda-dynamodb.zip . -x "*.git*" "*.DS_Store*" && cd ..

# 정리
rm -rf superchat-lambda likes-lambda notifications-lambda

cd ..
rm -rf $DEPLOY_DIR

echo "✅ 배포 패키지 생성 완료!"
echo "   - superchat-lambda-dynamodb.zip"
echo "   - likes-lambda-dynamodb.zip"
echo "   - notifications-lambda-dynamodb.zip"
echo ""
echo "🔧 AWS Lambda 함수 업데이트 방법:"
echo ""
echo "1. superchat-handler 업데이트:"
echo "   - AWS Lambda 콘솔에서 superchat-handler 함수 선택"
echo "   - 코드 탭에서 '업로드' → '.zip 파일 업로드'"
echo "   - superchat-lambda-dynamodb.zip 선택"
echo "   - 핸들러를 'index.handler'로 설정"
echo "   - Deploy 클릭"
echo ""
echo "2. likes-handler 업데이트:"
echo "   - AWS Lambda 콘솔에서 likes-handler 함수 선택"
echo "   - 코드 탭에서 '업로드' → '.zip 파일 업로드'"
echo "   - likes-lambda-dynamodb.zip 선택"
echo "   - 핸들러를 'index.handler'로 설정"
echo "   - Deploy 클릭"
echo ""
echo "3. notifications-handler 생성/업데이트:"
echo "   - AWS Lambda 콘솔에서 notifications-handler 함수 생성/선택"
echo "   - 런타임: Node.js 18.x"
echo "   - 코드 탭에서 '업로드' → '.zip 파일 업로드'"
echo "   - notifications-lambda-dynamodb.zip 선택"
echo "   - 핸들러를 'index.handler'로 설정"
echo "   - Deploy 클릭"
echo ""
echo "4. API Gateway 경로 설정:"
echo "   - /notifications/user/{userId} → GET"
echo "   - /notifications/unread-count/{userId} → GET"
echo "   - /notifications/recent/{userId} → GET"
echo "   - /notifications/{notificationId}/read → PUT"
echo "   - /notifications/read-all → PUT"
echo ""
echo "💡 중요: 각 Lambda 함수의 실행 역할에 DynamoDB 권한이 있는지 확인하세요!"