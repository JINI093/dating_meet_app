# AWS S3를 사용한 Admin 페이지 배포 가이드

## 개요
GitHub Pages 대신 AWS S3를 사용하여 Dating Meet Admin 페이지를 호스팅합니다.

## 필요 사항
- AWS 계정
- AWS CLI 설치 및 설정
- S3 버킷 생성 권한
- (선택) CloudFront 사용 권한

## 설정 단계

### 1. AWS CLI 설치 및 설정
```bash
# AWS CLI 설치 (macOS)
brew install awscli

# AWS 자격 증명 설정
aws configure
# AWS Access Key ID, Secret Access Key, Region 입력
```

### 2. 로컬 배포 (수동)
```bash
# 스크립트 실행
./scripts/deploy-to-aws.sh
```

### 3. GitHub Actions 자동 배포 설정

#### 3-1. GitHub Secrets 설정
Repository Settings → Secrets and variables → Actions에서 추가:
- `AWS_ACCESS_KEY_ID`: AWS 액세스 키
- `AWS_SECRET_ACCESS_KEY`: AWS 비밀 액세스 키
- `CLOUDFRONT_DISTRIBUTION_ID`: (선택) CloudFront ID

#### 3-2. 워크플로우 활성화
`.github/workflows/deploy-to-aws.yml` 파일이 자동으로 실행됩니다.

### 4. S3 버킷 설정 (수동으로 하는 경우)

#### 4-1. S3 버킷 생성
```bash
aws s3api create-bucket \
    --bucket dating-meet-admin \
    --region ap-northeast-2 \
    --create-bucket-configuration LocationConstraint=ap-northeast-2
```

#### 4-2. 정적 웹사이트 호스팅 활성화
```bash
aws s3 website s3://dating-meet-admin/ \
    --index-document index.html \
    --error-document index.html
```

#### 4-3. 버킷 정책 설정
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::dating-meet-admin/*"
        }
    ]
}
```

## CloudFront 설정 (선택사항)

### 1. CloudFront 배포 생성
```bash
aws cloudfront create-distribution \
    --origin-domain-name dating-meet-admin.s3.amazonaws.com \
    --default-root-object index.html
```

### 2. 장점
- HTTPS 자동 지원
- 전 세계 엣지 로케이션 활용
- 더 빠른 로딩 속도
- DDoS 보호

## 접속 URL

### S3 직접 접속
```
http://dating-meet-admin.s3-website-ap-northeast-2.amazonaws.com
```

### CloudFront 접속 (설정한 경우)
```
https://[distribution-id].cloudfront.net
```

## 커스텀 도메인 설정

### 1. Route 53에서 도메인 구매 또는 연결
### 2. CloudFront에 커스텀 도메인 연결
### 3. SSL 인증서 설정 (ACM 사용)

## 비용

### S3 비용 (서울 리전 기준)
- 저장: $0.025/GB/월
- 요청: $0.0004/1000 GET 요청
- 데이터 전송: 첫 10TB까지 $0.126/GB

### CloudFront 비용
- 데이터 전송: $0.085/GB (한국 기준)
- HTTP/HTTPS 요청: $0.0075/10,000 요청

## 문제 해결

### 1. 403 Forbidden 오류
- S3 버킷 정책 확인
- 파일 권한 확인

### 2. 404 Not Found 오류
- index.html 파일 존재 확인
- 정적 웹사이트 호스팅 설정 확인

### 3. 캐시 문제
- CloudFront 캐시 무효화 실행
- 브라우저 캐시 삭제

## 모니터링

### 1. CloudWatch 활용
- S3 버킷 메트릭 모니터링
- CloudFront 배포 메트릭 확인

### 2. 알람 설정
- 비정상적인 트래픽 감지
- 비용 임계값 알림

## 보안 고려사항

### 1. IAM 권한 최소화
- 배포에 필요한 최소 권한만 부여
- 정기적인 액세스 키 교체

### 2. S3 버킷 보안
- 버킷 정책 정기 검토
- 불필요한 퍼블릭 액세스 차단

### 3. CloudFront 보안
- WAF 규칙 적용 고려
- Origin Access Identity 사용