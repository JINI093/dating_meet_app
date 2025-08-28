#!/bin/bash

# AWS S3 Admin Page Deployment Script
# 사용법: ./scripts/deploy-to-aws.sh

set -e

echo "🚀 Starting AWS S3 deployment for Dating Meet Admin..."

# 변수 설정 (필요에 따라 수정)
S3_BUCKET_NAME="dating-meet-admin"
AWS_REGION="ap-northeast-2"  # 서울 리전
CLOUDFRONT_DISTRIBUTION_ID=""  # CloudFront 사용 시 입력

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Flutter 웹 빌드
echo -e "${YELLOW}Building Flutter web app...${NC}"
flutter build web --target lib/admin_main.dart --release

# 1-1. admin_index.html을 index.html로 복사
echo -e "${YELLOW}Setting up admin index.html...${NC}"
if [ -f "web/admin_index.html" ]; then
    cp web/admin_index.html build/web/index.html
    echo -e "${GREEN}Admin index.html copied${NC}"
fi

# 2. S3 버킷 생성 (이미 있으면 스킵)
echo -e "${YELLOW}Checking S3 bucket...${NC}"
if aws s3api head-bucket --bucket "$S3_BUCKET_NAME" 2>/dev/null; then
    echo -e "${GREEN}Bucket already exists${NC}"
else
    echo -e "${YELLOW}Creating S3 bucket...${NC}"
    aws s3api create-bucket \
        --bucket "$S3_BUCKET_NAME" \
        --region "$AWS_REGION" \
        --create-bucket-configuration LocationConstraint="$AWS_REGION"
fi

# 3. 퍼블릭 액세스 차단 해제
echo -e "${YELLOW}Removing public access block...${NC}"
aws s3api put-public-access-block \
    --bucket "$S3_BUCKET_NAME" \
    --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# 4. S3 버킷 정적 웹사이트 호스팅 활성화
echo -e "${YELLOW}Configuring bucket for static website hosting...${NC}"
aws s3 website s3://"$S3_BUCKET_NAME"/ \
    --index-document index.html \
    --error-document index.html

# 5. 버킷 정책 설정 (퍼블릭 읽기 권한)
echo -e "${YELLOW}Setting bucket policy...${NC}"
cat > bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$S3_BUCKET_NAME/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy \
    --bucket "$S3_BUCKET_NAME" \
    --policy file://bucket-policy.json

rm bucket-policy.json

# 6. 파일 업로드
echo -e "${YELLOW}Uploading files to S3...${NC}"
aws s3 sync build/web/ s3://"$S3_BUCKET_NAME"/ \
    --delete \
    --cache-control "public, max-age=3600"

# 7. CloudFront 캐시 무효화 (CloudFront 사용 시)
if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    echo -e "${YELLOW}Invalidating CloudFront cache...${NC}"
    aws cloudfront create-invalidation \
        --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" \
        --paths "/*"
fi

# 8. 완료 메시지
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "Website URL: ${GREEN}http://$S3_BUCKET_NAME.s3-website.$AWS_REGION.amazonaws.com${NC}"

if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    CLOUDFRONT_URL=$(aws cloudfront get-distribution --id "$CLOUDFRONT_DISTRIBUTION_ID" --query "Distribution.DomainName" --output text)
    echo -e "CloudFront URL: ${GREEN}https://$CLOUDFRONT_URL${NC}"
fi