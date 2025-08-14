#!/bin/bash

# AWS Lambda SMS 함수 배포 스크립트
# 사용법: ./deploy.sh [function-name] [region]

set -e

FUNCTION_NAME="${1:-SendSMSFunction}"
AWS_REGION="${2:-ap-northeast-2}"
ACCOUNT_ID="${3:-YOUR_ACCOUNT_ID}"

echo "🚀 AWS Lambda SMS 함수 배포 시작..."
echo "함수명: $FUNCTION_NAME"
echo "리전: $AWS_REGION"
echo "계정 ID: $ACCOUNT_ID"

# 1. 의존성 설치
echo "📦 의존성 설치 중..."
npm install --production

# 2. ZIP 파일 생성
echo "📦 배포 패키지 생성 중..."
if [ -f "send_sms_function.zip" ]; then
    rm send_sms_function.zip
fi
zip -r send_sms_function.zip . -x \
    "*.git*" \
    "node_modules/.cache/*" \
    "coverage/*" \
    "*.test.js" \
    "README.md" \
    "deploy.sh" \
    ".env*"

# 3. Lambda 함수 존재 여부 확인
echo "🔍 Lambda 함수 존재 여부 확인 중..."
if aws lambda get-function --function-name $FUNCTION_NAME --region $AWS_REGION >/dev/null 2>&1; then
    echo "📝 기존 함수 업데이트 중..."
    aws lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file fileb://send_sms_function.zip \
        --region $AWS_REGION
else
    echo "🆕 새 Lambda 함수 생성 중..."
    
    # IAM 역할 ARN 생성
    ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/LambdaSMSExecutionRole"
    
    aws lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime nodejs18.x \
        --role $ROLE_ARN \
        --handler send_sms_function.handler \
        --zip-file fileb://send_sms_function.zip \
        --timeout 30 \
        --memory-size 256 \
        --region $AWS_REGION \
        --environment Variables='{
            "AWS_REGION":"'$AWS_REGION'",
            "SMS_LOG_TABLE":"sms_logs"
        }'
fi

# 4. 환경 변수 업데이트
echo "🔧 환경 변수 업데이트 중..."
aws lambda update-function-configuration \
    --function-name $FUNCTION_NAME \
    --environment Variables='{
        "AWS_REGION":"'$AWS_REGION'",
        "SMS_LOG_TABLE":"sms_logs",
        "TWILIO_ACCOUNT_SID":"'${TWILIO_ACCOUNT_SID:-}'",
        "TWILIO_AUTH_TOKEN":"'${TWILIO_AUTH_TOKEN:-}'",
        "TWILIO_FROM_NUMBER":"'${TWILIO_FROM_NUMBER:-}'",
        "KT_SMS_API_URL":"'${KT_SMS_API_URL:-}'",
        "KT_API_KEY":"'${KT_API_KEY:-}'",
        "KT_SECRET_KEY":"'${KT_SECRET_KEY:-}'",
        "KT_SENDER_NUMBER":"'${KT_SENDER_NUMBER:-}'"
    }' \
    --region $AWS_REGION

# 5. API Gateway 연동 확인
echo "🌐 API Gateway 연동 확인 중..."
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='SMS-API'].id" --output text --region $AWS_REGION)

if [ "$API_ID" != "None" ] && [ -n "$API_ID" ]; then
    echo "✅ 기존 API Gateway 발견: $API_ID"
    API_URL="https://$API_ID.execute-api.$AWS_REGION.amazonaws.com/prod"
    echo "🔗 API Gateway URL: $API_URL"
else
    echo "⚠️  API Gateway가 설정되지 않았습니다."
    echo "📋 다음 명령어로 API Gateway를 생성하세요:"
    echo "   aws apigateway create-rest-api --name SMS-API --region $AWS_REGION"
fi

# 6. DynamoDB 테이블 생성 (로그 저장용)
echo "📊 DynamoDB 테이블 확인 중..."
if ! aws dynamodb describe-table --table-name sms_logs --region $AWS_REGION >/dev/null 2>&1; then
    echo "🆕 DynamoDB 테이블 생성 중..."
    aws dynamodb create-table \
        --table-name sms_logs \
        --attribute-definitions \
            AttributeName=id,AttributeType=S \
        --key-schema \
            AttributeName=id,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region $AWS_REGION
    
    echo "⏳ DynamoDB 테이블 생성 대기 중..."
    aws dynamodb wait table-exists --table-name sms_logs --region $AWS_REGION
fi

echo ""
echo "✅ 배포 완료!"
echo "📝 Lambda 함수명: $FUNCTION_NAME"
echo "🌍 리전: $AWS_REGION"

if [ -n "$API_URL" ]; then
    echo "🔗 API URL: $API_URL/sms/send"
    echo ""
    echo "📱 테스트 명령어:"
    echo "curl -X POST $API_URL/sms/send \\"
    echo "  -H \"Content-Type: application/json\" \\"
    echo "  -d '{\"phoneNumber\":\"+821012345678\",\"message\":\"테스트 메시지\",\"provider\":\"sns\"}'"
fi

echo ""
echo "🔧 환경 변수를 확인하고 필요시 AWS Console에서 수정하세요:"
echo "  - TWILIO_ACCOUNT_SID"
echo "  - TWILIO_AUTH_TOKEN" 
echo "  - TWILIO_FROM_NUMBER"
echo "  - KT_API_KEY"
echo "  - KT_SECRET_KEY"
echo "  - KT_SENDER_NUMBER"

# 정리
rm -f send_sms_function.zip
echo "🧹 임시 파일 정리 완료"