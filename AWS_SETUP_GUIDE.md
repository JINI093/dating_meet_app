# AWS S3 업로드 문제 해결 가이드

## 현재 문제
`InvalidIdentityPoolConfigurationException` 에러가 발생하여 S3 업로드가 실패하고 있습니다.

## 해결 방법

### 1. AWS Console에서 Cognito Identity Pool 확인

1. **AWS Console** → **Amazon Cognito** → **Identity pools** 이동
2. Identity Pool ID `ap-northeast-2:6b15af5c-77b3-447d-8eba-4f83e43fa1e0` 검색
3. 해당 Identity Pool을 찾아 클릭

### 2. IAM 역할 확인 및 설정

Identity Pool 상세 페이지에서:

1. **"Edit identity pool"** 버튼 클릭
2. **"Authentication providers"** 탭 확인
3. **Authenticated role**과 **Unauthenticated role**이 설정되어 있는지 확인

### 3. IAM 역할 권한 설정

**AWS Console** → **IAM** → **Roles**에서:

1. Cognito Identity Pool의 **Authenticated role** 찾기
2. 해당 역할의 **"Permissions"** 탭에서 **"Add permissions"** → **"Attach policies"**
3. 다음 정책 추가:

#### S3 접근 정책 (JSON)
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
                "arn:aws:s3:::meet-project/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::meet-project"
            ]
        }
    ]
}
```

### 4. S3 버킷 CORS 설정

**AWS Console** → **S3** → **meet-project** 버킷:

1. **"Permissions"** 탭 클릭
2. **"Cross-origin resource sharing (CORS)"** 섹션에서 **"Edit"** 클릭
3. 다음 CORS 정책 추가:

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
            "ETag"
        ],
        "MaxAgeSeconds": 3000
    }
]
```

### 5. S3 버킷 정책 설정 (선택사항)

S3 버킷의 **"Permissions"** → **"Bucket policy"**:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::213265226405:role/[YOUR_COGNITO_AUTHENTICATED_ROLE]"
            },
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::meet-project/*"
        }
    ]
}
```

### 6. 설정 확인 명령어

터미널에서 다음 명령어로 설정을 확인할 수 있습니다:

```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# Identity Pool 정보 확인
aws cognito-identity describe-identity-pool \
  --identity-pool-id "ap-northeast-2:6b15af5c-77b3-447d-8eba-4f83e43fa1e0" \
  --region ap-northeast-2

# S3 버킷 정책 확인
aws s3api get-bucket-policy \
  --bucket meet-project \
  --region ap-northeast-2
```

### 7. 앱에서 테스트

설정 완료 후:
1. 앱을 재시작
2. 프로필 이미지 업로드 시도
3. 로그에서 "S3 업로드 성공" 메시지 확인

## 주의사항

- 모든 설정 변경 후 **몇 분 정도 대기**가 필요할 수 있습니다
- IAM 역할 변경은 **즉시 적용**되지 않을 수 있습니다
- 문제가 지속되면 **Identity Pool을 새로 생성**하는 것을 고려해보세요

## 문제 해결 완료 확인

앱 로그에서 다음 메시지를 확인하세요:
- ✅ "S3 업로드 성공: profile-images/[userId]/[timestamp]-[id].jpg"
- ✅ "이미지 업로드 완료: https://meet-project.s3.ap-northeast-2.amazonaws.com/..."