#!/bin/bash

echo "🚀 DynamoDB 테이블 생성 시작..."

# AWS 계정 확인
echo "📋 현재 AWS 계정 확인:"
aws sts get-caller-identity

echo ""
echo "📊 DynamoDB 테이블 생성 중..."

# 1. DatingMeet-Likes-dev 테이블 생성
echo "❤️  Likes 테이블 생성 중..."
aws dynamodb create-table \
    --table-name DatingMeet-Likes-dev \
    --attribute-definitions \
        AttributeName=id,AttributeType=S \
        AttributeName=fromUserId,AttributeType=S \
        AttributeName=toProfileId,AttributeType=S \
        AttributeName=createdAt,AttributeType=S \
    --key-schema \
        AttributeName=id,KeyType=HASH \
    --global-secondary-indexes \
        '[{
            "IndexName": "fromUserId-createdAt-index",
            "KeySchema": [
                {"AttributeName": "fromUserId", "KeyType": "HASH"},
                {"AttributeName": "createdAt", "KeyType": "RANGE"}
            ],
            "Projection": {"ProjectionType": "ALL"},
            "ProvisionedThroughput": {"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}
        },
        {
            "IndexName": "toProfileId-createdAt-index",
            "KeySchema": [
                {"AttributeName": "toProfileId", "KeyType": "HASH"},
                {"AttributeName": "createdAt", "KeyType": "RANGE"}
            ],
            "Projection": {"ProjectionType": "ALL"},
            "ProvisionedThroughput": {"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}
        }]' \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region ap-northeast-2

echo "✅ Likes 테이블 생성 요청 완료"

# 2. DatingMeet-Matches-dev 테이블 생성
echo "💕 Matches 테이블 생성 중..."
aws dynamodb create-table \
    --table-name DatingMeet-Matches-dev \
    --attribute-definitions \
        AttributeName=id,AttributeType=S \
        AttributeName=user1Id,AttributeType=S \
        AttributeName=user2Id,AttributeType=S \
        AttributeName=createdAt,AttributeType=S \
    --key-schema \
        AttributeName=id,KeyType=HASH \
    --global-secondary-indexes \
        '[{
            "IndexName": "user1Id-createdAt-index",
            "KeySchema": [
                {"AttributeName": "user1Id", "KeyType": "HASH"},
                {"AttributeName": "createdAt", "KeyType": "RANGE"}
            ],
            "Projection": {"ProjectionType": "ALL"},
            "ProvisionedThroughput": {"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}
        },
        {
            "IndexName": "user2Id-createdAt-index",
            "KeySchema": [
                {"AttributeName": "user2Id", "KeyType": "HASH"},
                {"AttributeName": "createdAt", "KeyType": "RANGE"}
            ],
            "Projection": {"ProjectionType": "ALL"},
            "ProvisionedThroughput": {"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}
        }]' \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region ap-northeast-2

echo "✅ Matches 테이블 생성 요청 완료"

# 3. DatingMeet-Messages-dev 테이블 생성
echo "💬 Messages 테이블 생성 중..."
aws dynamodb create-table \
    --table-name DatingMeet-Messages-dev \
    --attribute-definitions \
        AttributeName=messageId,AttributeType=S \
        AttributeName=matchId,AttributeType=S \
        AttributeName=createdAt,AttributeType=S \
    --key-schema \
        AttributeName=messageId,KeyType=HASH \
    --global-secondary-indexes \
        '[{
            "IndexName": "matchId-createdAt-index",
            "KeySchema": [
                {"AttributeName": "matchId", "KeyType": "HASH"},
                {"AttributeName": "createdAt", "KeyType": "RANGE"}
            ],
            "Projection": {"ProjectionType": "ALL"},
            "ProvisionedThroughput": {"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}
        }]' \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region ap-northeast-2

echo "✅ Messages 테이블 생성 요청 완료"

echo ""
echo "⏳ 테이블 생성 대기 중... (약 1-2분 소요)"

# 테이블 생성 완료 대기
echo "🔍 Likes 테이블 상태 확인 중..."
aws dynamodb wait table-exists --table-name DatingMeet-Likes-dev --region ap-northeast-2
echo "✅ Likes 테이블 생성 완료!"

echo "🔍 Matches 테이블 상태 확인 중..."
aws dynamodb wait table-exists --table-name DatingMeet-Matches-dev --region ap-northeast-2
echo "✅ Matches 테이블 생성 완료!"

echo "🔍 Messages 테이블 상태 확인 중..."
aws dynamodb wait table-exists --table-name DatingMeet-Messages-dev --region ap-northeast-2
echo "✅ Messages 테이블 생성 완료!"

echo ""
echo "📊 생성된 테이블 정보:"

# 테이블 정보 확인
echo ""
echo "🏷️  DatingMeet-Likes-dev 테이블:"
aws dynamodb describe-table --table-name DatingMeet-Likes-dev --region ap-northeast-2 --query 'Table.{TableName:TableName,Status:TableStatus,ItemCount:ItemCount,TableSizeBytes:TableSizeBytes}' --output table

echo ""
echo "🏷️  DatingMeet-Matches-dev 테이블:"
aws dynamodb describe-table --table-name DatingMeet-Matches-dev --region ap-northeast-2 --query 'Table.{TableName:TableName,Status:TableStatus,ItemCount:ItemCount,TableSizeBytes:TableSizeBytes}' --output table

echo ""
echo "🏷️  DatingMeet-Messages-dev 테이블:"
aws dynamodb describe-table --table-name DatingMeet-Messages-dev --region ap-northeast-2 --query 'Table.{TableName:TableName,Status:TableStatus,ItemCount:ItemCount,TableSizeBytes:TableSizeBytes}' --output table

echo ""
echo "🎉 모든 DynamoDB 테이블 생성 완료!"
echo ""
echo "📋 테이블 구조:"
echo "   🔸 DatingMeet-Likes-dev:"
echo "     - Primary Key: id (String)"
echo "     - GSI: fromUserId-createdAt-index (보낸 좋아요 조회용)"
echo "     - GSI: toProfileId-createdAt-index (받은 좋아요 조회용)"
echo ""
echo "   🔸 DatingMeet-Matches-dev:"
echo "     - Primary Key: id (String)"
echo "     - GSI: user1Id-createdAt-index"
echo "     - GSI: user2Id-createdAt-index"
echo ""
echo "   🔸 DatingMeet-Messages-dev:"
echo "     - Primary Key: messageId (String)"
echo "     - GSI: matchId-createdAt-index (메시지 조회용)"
echo ""
echo "💡 다음 단계:"
echo "   1. Lambda 함수에 DynamoDB 권한 부여 확인"
echo "   2. API Gateway 테스트"
echo "   3. Flutter 앱에서 채팅 기능 테스트"