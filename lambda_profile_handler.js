const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand, GetCommand, ScanCommand } = require("@aws-sdk/lib-dynamodb");

exports.handler = async (event) => {
    console.log('=== Lambda Event Debug ===');
    console.log('Full event:', JSON.stringify(event, null, 2));
    console.log('HTTP Method:', event.httpMethod);
    console.log('Request Context Method:', event.requestContext?.httpMethod);
    console.log('Request Context HTTP Method:', event.requestContext?.http?.method);
    console.log('Path Parameters:', event.pathParameters);

    // HTTP 메서드 추출 (REST API vs HTTP API 호환)
    const httpMethod = event.httpMethod ||
                  event.requestContext?.httpMethod ||
                  event.requestContext?.http?.method ||
                  event.headers?.['X-HTTP-Method-Override'] ||
                  (event.routeKey ? event.routeKey.split(' ')[0] : undefined);
    
    console.log('Resolved HTTP Method:', httpMethod);

    try {
        // OPTIONS 요청 처리
        if (httpMethod === 'OPTIONS') {
            return {
                statusCode: 200,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
                },
                body: ''
            };
        }

        const client = new DynamoDBClient({ region: "ap-northeast-2" });
        const dynamoDb = DynamoDBDocumentClient.from(client);

        // GET 요청: 프로필 조회
        if (httpMethod === 'GET') {
            console.log('=== GET 요청: 프로필 조회 ===');
            console.log('요청 경로:', event.path);
            console.log('리소스 경로:', event.resource);
            console.log('경로 파라미터:', event.pathParameters);
            console.log('쿼리 파라미터:', event.queryStringParameters);
            
            // /profiles/discover 엔드포인트 처리
            // API Gateway의 resource가 /discover이거나 path에 discover가 포함된 경우
            const requestPath = event.path || event.rawPath || event.requestContext?.http?.path || '';
            const resourcePath = event.resource || '';
            
            if (resourcePath.includes('/discover') || 
                requestPath.includes('/discover')) {
                console.log('=== 프로필 탐색 (discover) 요청 ===');
                
                const queryParams = event.queryStringParameters || {};
                const currentUserId = queryParams.currentUserId;
                const gender = queryParams.gender;
                const limit = parseInt(queryParams.limit) || 20;
                
                console.log('탐색 파라미터:', { currentUserId, gender, limit });
                
                try {
                    // 모든 프로필 스캔
                    const scanResult = await dynamoDb.send(new ScanCommand({
                        TableName: 'Profiles'
                    }));
                    
                    let profiles = scanResult.Items || [];
                    console.log(`전체 프로필 수: ${profiles.length}`);
                    
                    // 현재 사용자 제외
                    profiles = profiles.filter(p => p.id !== currentUserId && p.userId !== currentUserId);
                    
                    // 성별 필터링
                    if (gender) {
                        profiles = profiles.filter(p => p.gender === gender);
                        console.log(`성별 필터링 후 프로필 수: ${profiles.length}`);
                    }
                    
                    // limit 적용
                    profiles = profiles.slice(0, limit);
                    
                    return {
                        statusCode: 200,
                        headers: {
                            'Content-Type': 'application/json',
                            'Access-Control-Allow-Origin': '*'
                        },
                        body: JSON.stringify({
                            success: true,
                            message: "Profiles found",
                            data: {
                                profiles: profiles,
                                nextToken: null
                            }
                        })
                    };
                } catch (error) {
                    console.error('프로필 탐색 오류:', error);
                    return {
                        statusCode: 500,
                        headers: {
                            'Content-Type': 'application/json',
                            'Access-Control-Allow-Origin': '*'
                        },
                        body: JSON.stringify({
                            success: false,
                            message: "프로필 탐색 실패: " + error.message,
                            data: null
                        })
                    };
                }
            }
            
            // URL 경로에서 userId 추출: /profiles/{userId}
            const userId = event.pathParameters?.userId || event.pathParameters?.id;
            console.log('조회할 userId:', userId);

            if (!userId) {
                return {
                    statusCode: 400,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    body: JSON.stringify({
                        success: false,
                        message: "userId가 필요합니다",
                        data: null
                    })
                };
            }

            try {
                // 먼저 id 필드로 직접 조회
                console.log('DynamoDB GetCommand로 id 검색 중:', userId);
                const getResult = await dynamoDb.send(new GetCommand({
                    TableName: 'Profiles',
                    Key: { id: userId }
                }));

                console.log('GetCommand 결과:', getResult);

                if (getResult.Item) {
                    console.log('✅ id로 프로필 조회 성공:', getResult.Item.name);
                    console.log('조회된 성별:', getResult.Item.gender);
                    console.log('전체 프로필 데이터:', JSON.stringify(getResult.Item, null, 2));
                    
                    return {
                        statusCode: 200,
                        headers: {
                            'Content-Type': 'application/json',
                            'Access-Control-Allow-Origin': '*'
                        },
                        body: JSON.stringify({
                            success: true,
                            message: "Profile found via id lookup",
                            data: getResult.Item
                        })
                    };
                }

                // userId 필드로 스캔 (새로운 데이터용)
                console.log('id 조회 실패, userId 필드로 스캔 중...');
                const scanByUserId = await dynamoDb.send(new ScanCommand({
                    TableName: 'Profiles',
                    FilterExpression: 'userId = :userId',
                    ExpressionAttributeValues: {
                        ':userId': userId
                    },
                    Limit: 1
                }));

                if (scanByUserId.Items && scanByUserId.Items.length > 0) {
                    const profile = scanByUserId.Items[0];
                    console.log('✅ userId로 프로필 조회 성공:', profile.name);
                    console.log('조회된 성별:', profile.gender);
                    
                    return {
                        statusCode: 200,
                        headers: {
                            'Content-Type': 'application/json',
                            'Access-Control-Allow-Origin': '*'
                        },
                        body: JSON.stringify({
                            success: true,
                            message: "Profile found via userId scan",
                            data: profile
                        })
                    };
                }

                // 전체 테이블 스캔 (최후 수단)
                console.log('userId 스캔 실패, 전체 테이블에서 사용자 검색 중...');
                const fullScan = await dynamoDb.send(new ScanCommand({
                    TableName: 'Profiles'
                }));

                console.log(`전체 ${fullScan.Items?.length || 0}개 프로필 검색 중...`);
                
                if (fullScan.Items && fullScan.Items.length > 0) {
                    // 요청된 userId와 일치하는 항목 찾기
                    for (const item of fullScan.Items) {
                        console.log(`검사 중: id=${item.id}, userId=${item.userId}, name=${item.name}`);
                        
                        if (item.id === userId || item.userId === userId) {
                            console.log('✅ 전체 스캔으로 프로필 발견:', item.name);
                            console.log('조회된 성별:', item.gender);
                            
                            return {
                                statusCode: 200,
                                headers: {
                                    'Content-Type': 'application/json',
                                    'Access-Control-Allow-Origin': '*'
                                },
                                body: JSON.stringify({
                                    success: true,
                                    message: "Profile found via full scan",
                                    data: item
                                })
                            };
                        }
                    }
                }

                // 프로필을 찾지 못한 경우
                console.log('❌ 프로필을 찾을 수 없음');
                return {
                    statusCode: 404,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    body: JSON.stringify({
                        success: false,
                        message: "Profile not found",
                        data: null
                    })
                };

            } catch (dbError) {
                console.error('DynamoDB 조회 오류:', dbError);
                return {
                    statusCode: 500,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    body: JSON.stringify({
                        success: false,
                        message: "Database query failed: " + dbError.message,
                        data: null
                    })
                };
            }
        }

        // POST 요청: 프로필 생성/업데이트 (기존 코드)
        if (httpMethod === 'POST') {
            console.log('=== POST 요청: 프로필 생성/업데이트 ===');
            
            let requestBody = {};

            // 여러 방법으로 데이터 추출 시도
            console.log('Event.body:', event.body);
            console.log('Event.body type:', typeof event.body);

            // 방법 1: event.body에서 추출
            if (event.body) {
                try {
                    if (typeof event.body === 'string') {
                        requestBody = JSON.parse(event.body);
                    } else if (typeof event.body === 'object') {
                        requestBody = event.body;
                    }
                } catch (e) {
                    console.log('Body parsing failed:', e);
                }
            }

            // 방법 2: event 자체에서 직접 추출 (API Gateway 프록시 통합)
            if (Object.keys(requestBody).length === 0) {
                console.log('Trying to extract from event directly...');
                if (event.userId || event.name || event.age) {
                    requestBody = event;
                    console.log('Using event as requestBody');
                }
            }

            // 방법 3: 중첩된 body 객체 확인
            if (Object.keys(requestBody).length === 0 && event.body && typeof event.body === 'object') {
                console.log('Checking nested body object...');
                requestBody = event.body.body || event.body;
            }

            console.log('Final requestBody:', JSON.stringify(requestBody, null, 2));
            console.log('RequestBody keys:', Object.keys(requestBody));

            // 테스트 데이터 사용하지 않음 - 실제 데이터만 처리
            if (Object.keys(requestBody).length === 0) {
                return {
                    statusCode: 400,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    body: JSON.stringify({
                        success: false,
                        message: "요청 데이터가 없습니다",
                        data: null
                    })
                };
            }

            const userId = requestBody.userId || requestBody.id;

            if (!userId) {
                return {
                    statusCode: 400,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    body: JSON.stringify({
                        success: false,
                        message: "userId가 필요합니다",
                        debug: {
                            eventKeys: Object.keys(event),
                            bodyType: typeof event.body,
                            hasBody: !!event.body,
                            requestBodyKeys: Object.keys(requestBody)
                        },
                        data: null
                    })
                };
            }

            // 고유한 프로필 ID 생성 (프로필 테이블의 기본 키)
            const profileId = requestBody.id || `${Date.now()}-${Math.random().toString(36).substring(2, 8)}`;
            
            // DynamoDB 저장
            const profileData = {
                id: profileId, // 고유한 프로필 ID
                userId: userId, // Cognito userId 추가 (검색용)
                name: String(requestBody.name || ''),
                age: Number(requestBody.age) || 0,
                location: String(requestBody.location || ''),
                profileImages: Array.isArray(requestBody.profileImages) ? requestBody.profileImages : [],
                bio: String(requestBody.bio || ''),
                occupation: String(requestBody.occupation || ''),
                education: String(requestBody.education || ''),
                height: requestBody.height ? Number(requestBody.height) : null,
                bodyType: String(requestBody.bodyType || ''),
                smoking: String(requestBody.smoking || ''),
                drinking: String(requestBody.drinking || ''),
                religion: String(requestBody.religion || ''),
                mbti: String(requestBody.mbti || ''),
                hobbies: Array.isArray(requestBody.hobbies) ? requestBody.hobbies : [],
                badges: Array.isArray(requestBody.badges) ? requestBody.badges : [],
                isVip: Boolean(requestBody.isVip),
                isPremium: Boolean(requestBody.isPremium),
                isVerified: Boolean(requestBody.isVerified),
                isOnline: Boolean(requestBody.isOnline !== false),
                likeCount: Number(requestBody.likeCount) || 0,
                superChatCount: Number(requestBody.superChatCount) || 0,
                gender: String(requestBody.gender || ''),
                meetingType: String(requestBody.meetingType || ''),
                incomeCode: String(requestBody.incomeCode || ''),
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString(),
                lastSeen: null
            };

            console.log('Saving profile:', profileData.name, profileData.age, profileData.gender);

            await dynamoDb.send(new PutCommand({
                TableName: 'Profiles',
                Item: profileData
            }));

            console.log('DynamoDB 저장 성공');

            return {
                statusCode: 200,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    success: true,
                    message: "Profile saved successfully",
                    data: profileData
                })
            };
        }

        // 지원하지 않는 HTTP 메서드
        return {
            statusCode: 405,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                message: `Method ${httpMethod} not allowed`,
                data: null
            })
        };

    } catch (error) {
        console.error('Lambda error:', error);

        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                message: error.message,
                data: null
            })
        };
    }
};