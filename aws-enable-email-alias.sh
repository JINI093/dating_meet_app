#!/bin/bash

# AWS Cognito User Pool에서 email alias 활성화 스크립트

USER_POOL_ID="ap-northeast-2_txpQqSwnW"
REGION="ap-northeast-2"

echo "🔧 AWS Cognito User Pool에서 email alias 활성화 중..."
echo "User Pool ID: $USER_POOL_ID"
echo "Region: $REGION"

# 현재 설정 확인
echo ""
echo "📋 현재 User Pool 설정 확인:"
aws cognito-idp describe-user-pool \
    --user-pool-id $USER_POOL_ID \
    --region $REGION \
    --query 'UserPool.{AliasAttributes:AliasAttributes,UsernameAttributes:UsernameAttributes}' \
    --output table

echo ""
echo "🔄 Email alias 활성화 중..."

# User Pool 업데이트 - email alias 활성화
aws cognito-idp update-user-pool \
    --user-pool-id $USER_POOL_ID \
    --region $REGION \
    --alias-attributes email \
    --username-attributes email \
    --auto-verified-attributes email

if [ $? -eq 0 ]; then
    echo "✅ Email alias 활성화 완료!"
    
    echo ""
    echo "📋 업데이트된 설정 확인:"
    aws cognito-idp describe-user-pool \
        --user-pool-id $USER_POOL_ID \
        --region $REGION \
        --query 'UserPool.{AliasAttributes:AliasAttributes,UsernameAttributes:UsernameAttributes}' \
        --output table
        
    echo ""
    echo "🎉 이제 이메일로 직접 로그인이 가능합니다!"
    echo "💡 앱을 재시작한 후 test002@naver.com으로 로그인해보세요."
else
    echo "❌ Email alias 활성화 실패"
    echo "💡 AWS CLI 설정과 권한을 확인해주세요."
fi