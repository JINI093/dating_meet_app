#!/bin/bash

# AWS Cognito 사용자 수동 확인 스크립트

USER_POOL_ID="ap-northeast-2_txpQqSwnW"
USERNAME="$1"

if [ -z "$USERNAME" ]; then
    echo "사용법: ./confirm-user.sh <username>"
    echo "예시: ./confirm-user.sh test000_786692"
    exit 1
fi

echo "🔧 사용자 확인 중: $USERNAME"

# Admin으로 사용자 확인
aws cognito-idp admin-confirm-sign-up \
    --user-pool-id $USER_POOL_ID \
    --username $USERNAME \
    --region ap-northeast-2

if [ $? -eq 0 ]; then
    echo "✅ 사용자 확인 완료!"
    
    # 사용자 상태 확인
    echo ""
    echo "📋 사용자 정보:"
    aws cognito-idp admin-get-user \
        --user-pool-id $USER_POOL_ID \
        --username $USERNAME \
        --region ap-northeast-2 \
        --query 'UserStatus' \
        --output text
else
    echo "❌ 사용자 확인 실패"
fi