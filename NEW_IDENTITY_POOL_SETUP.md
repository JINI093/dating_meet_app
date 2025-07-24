# 새로운 Identity Pool 설정 가이드

## 새로운 Identity Pool 정보
- **Identity Pool ID**: `ap-northeast-2:b0244a25-b53b-4870-b740-3baed7eac93a`
- **Region**: `ap-northeast-2`
- **S3 Bucket**: `meet-project`

## 필수 설정 단계

### 1. IAM 역할 확인 및 권한 설정

**AWS Console → IAM → Roles**에서 새로 생성된 역할들을 찾으세요:
- `Cognito_[PoolName]Auth_Role` (인증된 사용자용)
- `Cognito_[PoolName]Unauth_Role` (인증되지 않은 사용자용)

### 2. Authenticated Role에 S3 권한 추가

**인증된 사용자 역할**에 다음 정책을 추가하세요:

#### 정책 이름: `S3ProfileImageAccess`
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::meet-project/profile-images/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::meet-project"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "profile-images/*"
                    ]
                }
            }
        }
    ]
}
```

### 3. S3 버킷 CORS 설정

**AWS Console → S3 → meet-project → Permissions → CORS**:

```json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "PUT",
            "POST",
            "DELETE",
            "HEAD"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": [
            "ETag",
            "x-amz-meta-custom-header"
        ],
        "MaxAgeSeconds": 3000
    }
]
```

### 4. Identity Pool 인증 공급자 설정

**AWS Console → Cognito → Identity pools → [새로운 풀] → Authentication providers**:

1. **Cognito User Pool** 탭에서:
   - User Pool ID: `ap-northeast-2_lKdTmyEaP`
   - App Client ID: `cqu5l148pkrtoh0e28bh385ns`

2. **Unauthenticated identities** 활성화 (선택사항)

### 5. 설정 테스트

다음 명령어로 설정을 확인하세요:

```bash
# 새로운 Identity Pool 정보 확인
aws cognito-identity describe-identity-pool \
  --identity-pool-id "ap-northeast-2:b0244a25-b53b-4870-b740-3baed7eac93a" \
  --region ap-northeast-2

# 권한 확인 스크립트 실행
cd /Users/sunwoo/Desktop/development/dating_meet_app
./scripts/check_s3_permissions.sh
```

### 6. 앱에서 테스트

1. **앱 완전 재시작** (Hot Reload가 아닌 완전 재빌드)
2. **로그인 후 프로필 이미지 업로드 시도**
3. **로그 확인**:
   - ✅ "인증 상태: true" 메시지 확인
   - ✅ "S3 업로드 성공" 메시지 확인
   - ❌ "InvalidIdentityPoolConfigurationException" 에러가 없어야 함

## 예상 로그 메시지

성공적인 업로드 시:
```
[AWSProfileService] 🔄 이미지 S3 업로드 시작: 3장
[AWSProfileService] 인증 상태: true
[AWSProfileService] 이미지 압축 완료: [크기] bytes
[AWSProfileService] S3 업로드 시작: profile-images/[userId]/[timestamp]-[id].jpg
[AWSProfileService] S3 업로드 성공: profile-images/[userId]/[timestamp]-[id].jpg
[AWSProfileService] ✅ 이미지 1/3 업로드 완료: https://meet-project.s3.ap-northeast-2.amazonaws.com/...
```

## 문제 해결

만약 여전히 문제가 발생한다면:
1. **IAM 역할 신뢰 관계** 확인
2. **Cognito User Pool과 Identity Pool 연결** 확인
3. **앱 완전 재시작** (캐시 삭제)

## 주의사항

- 새 Identity Pool 설정이 적용되려면 **5-10분** 정도 소요될 수 있습니다
- 앱은 **완전히 재시작**해야 새 설정이 적용됩니다
- 문제가 지속되면 **디버깅 로그**를 확인하여 구체적인 에러 메시지를 찾으세요