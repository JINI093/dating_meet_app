#!/bin/bash

# AWS S3 권한 확인 스크립트

echo "🔍 S3 버킷 권한 확인 중..."

# Cognito Identity Pool 정보
IDENTITY_POOL_ID="ap-northeast-2:b0244a25-b53b-4870-b740-3baed7eac93a"
S3_BUCKET="meet-project"
REGION="ap-northeast-2"

echo "Identity Pool ID: $IDENTITY_POOL_ID"
echo "S3 Bucket: $S3_BUCKET"
echo "Region: $REGION"

# 1. Identity Pool 정보 가져오기
echo -e "\n1. Cognito Identity Pool 정보:"
aws cognito-identity describe-identity-pool \
  --identity-pool-id $IDENTITY_POOL_ID \
  --region $REGION 2>/dev/null || echo "❌ Identity Pool 정보 조회 실패"

# 2. S3 버킷 정책 확인
echo -e "\n2. S3 버킷 정책:"
aws s3api get-bucket-policy \
  --bucket $S3_BUCKET \
  --region $REGION 2>/dev/null | jq '.' || echo "❌ S3 버킷 정책 없음"

# 3. S3 버킷 CORS 설정 확인
echo -e "\n3. S3 버킷 CORS 설정:"
aws s3api get-bucket-cors \
  --bucket $S3_BUCKET \
  --region $REGION 2>/dev/null | jq '.' || echo "❌ S3 버킷 CORS 설정 없음"

# 4. S3 버킷 ACL 확인
echo -e "\n4. S3 버킷 ACL:"
aws s3api get-bucket-acl \
  --bucket $S3_BUCKET \
  --region $REGION 2>/dev/null | jq '.' || echo "❌ S3 버킷 ACL 조회 실패"

echo -e "\n✅ 권한 확인 완료"
echo -e "\n📝 권한 수정이 필요한 경우:"
echo "1. AWS Console > Cognito > Identity Pool 에서 IAM 역할 확인"
echo "2. IAM 역할에 다음 권한 추가:"
echo "   - s3:PutObject"
echo "   - s3:GetObject"
echo "   - s3:DeleteObject"
echo "   경로: ${S3_BUCKET}/protected/*"