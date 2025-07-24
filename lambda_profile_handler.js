import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand, GetCommand, ScanCommand } from "@aws-sdk/lib-dynamodb";

export const handler = async (event) => {
    console.log('=== Lambda Event Debug ===');
    console.log('Full event:', JSON.stringify(event, null, 2));
    console.log('HTTP Method:', event.httpMethod);
    console.log('Path Parameters:', event.pathParameters);

    try {
        // OPTIONS 요청 처리
        if (event.httpMethod === 'OPTIONS') {
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
        if (event.httpMethod === 'GET') {
            console.log('=== GET 요청: 프로필 조회 ===');
            
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
                // 방법 1: userId로 직접 조회 (권장)
                console.log('DynamoDB GetCommand 실행 중...');
                const getResult = await dynamoDb.send(new GetCommand({
                    TableName: 'Profiles',
                    Key: { id: userId }
                }));

                if (getResult.Item) {
                    console.log('✅ 프로필 조회 성공:', getResult.Item.name);
                    console.log('조회된 성별:', getResult.Item.gender);
                    
                    return {
                        statusCode: 200,
                        headers: {
                            'Content-Type': 'application/json',
                            'Access-Control-Allow-Origin': '*'
                        },
                        body: JSON.stringify({
                            success: true,
                            message: "Profile found",
                            data: getResult.Item
                        })
                    };
                }

                // 방법 2: userId가 id와 다른 경우, userId 필드로 스캔
                console.log('Direct lookup failed, trying scan by userId...');
                const scanResult = await dynamoDb.send(new ScanCommand({
                    TableName: 'Profiles',
                    FilterExpression: 'userId = :userId OR id = :userId',
                    ExpressionAttributeValues: {
                        ':userId': userId
                    },
                    Limit: 1
                }));

                if (scanResult.Items && scanResult.Items.length > 0) {
                    const profile = scanResult.Items[0];
                    console.log('✅ 스캔으로 프로필 조회 성공:', profile.name);
                    console.log('조회된 성별:', profile.gender);
                    
                    return {
                        statusCode: 200,
                        headers: {
                            'Content-Type': 'application/json',
                            'Access-Control-Allow-Origin': '*'
                        },
                        body: JSON.stringify({
                            success: true,
                            message: "Profile found via scan",
                            data: profile
                        })
                    };
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
        if (event.httpMethod === 'POST') {
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

            // DynamoDB 저장
            const profileData = {
                id: userId,
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
                message: `Method ${event.httpMethod} not allowed`,
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