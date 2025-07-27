import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand, GetCommand, ScanCommand, QueryCommand, UpdateCommand, TransactWriteCommand } from "@aws-sdk/lib-dynamodb";
import { v4 as uuidv4 } from 'uuid';

export const handler = async (event) => {
    console.log('=== Likes Lambda Event Debug ===');
    console.log('Full event:', JSON.stringify(event, null, 2));
    
    const httpMethod = event.httpMethod || 
                      event.requestContext?.httpMethod || 
                      event.requestContext?.http?.method;
    
    console.log('Resolved HTTP Method:', httpMethod);

    try {
        const client = new DynamoDBClient({ region: "ap-northeast-2" });
        const dynamoDb = DynamoDBDocumentClient.from(client);

        // OPTIONS 요청 처리
        if (httpMethod === 'OPTIONS') {
            return {
                statusCode: 200,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
                },
                body: ''
            };
        }

        const requestPath = event.path || event.rawPath || event.requestContext?.http?.path || '';
        
        // POST /likes - 좋아요 전송
        if (httpMethod === 'POST' && requestPath.includes('/likes')) {
            console.log('=== 좋아요 전송 요청 ===');
            
            const requestBody = JSON.parse(event.body || '{}');
            const { fromUserId, toProfileId, likeType = 'LIKE' } = requestBody;
            
            console.log('좋아요 요청:', { fromUserId, toProfileId, likeType });
            
            if (!fromUserId || !toProfileId) {
                return {
                    statusCode: 400,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({
                        success: false,
                        message: "fromUserId와 toProfileId가 필요합니다",
                        data: null
                    })
                };
            }

            // 1. 자기 자신에게 좋아요 방지
            if (fromUserId === toProfileId) {
                return {
                    statusCode: 400,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({
                        success: false,
                        message: "자기 자신에게는 좋아요를 보낼 수 없습니다",
                        data: null
                    })
                };
            }

            try {
                // 2. 중복 좋아요 체크
                const existingLike = await dynamoDb.send(new QueryCommand({
                    TableName: 'Likes',
                    IndexName: 'likesByFromUserIdAndToProfileId',
                    KeyConditionExpression: 'fromUserId = :fromUserId AND toProfileId = :toProfileId',
                    ExpressionAttributeValues: {
                        ':fromUserId': fromUserId,
                        ':toProfileId': toProfileId
                    },
                    Limit: 1
                }));

                if (existingLike.Items && existingLike.Items.length > 0) {
                    return {
                        statusCode: 409,
                        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                        body: JSON.stringify({
                            success: false,
                            message: "이미 평가한 사용자입니다",
                            data: null
                        })
                    };
                }

                // 3. 일일 제한 체크 (서버사이드)
                const today = new Date().toISOString().split('T')[0];
                const todayLikes = await dynamoDb.send(new QueryCommand({
                    TableName: 'Likes',
                    IndexName: 'likesByFromUserId',
                    KeyConditionExpression: 'fromUserId = :fromUserId',
                    FilterExpression: 'begins_with(createdAt, :today) AND actionType = :likeType',
                    ExpressionAttributeValues: {
                        ':fromUserId': fromUserId,
                        ':today': today,
                        ':likeType': 'LIKE'
                    }
                }));

                const dailyLikeCount = todayLikes.Items?.length || 0;
                const DAILY_LIKE_LIMIT = 20;

                if (dailyLikeCount >= DAILY_LIKE_LIMIT) {
                    return {
                        statusCode: 429,
                        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                        body: JSON.stringify({
                            success: false,
                            message: `일일 좋아요 제한을 초과했습니다 (${DAILY_LIKE_LIMIT}회)`,
                            data: { dailyCount: dailyLikeCount, limit: DAILY_LIKE_LIMIT }
                        })
                    };
                }

                // 4. 상호 좋아요 체크
                const mutualLike = await dynamoDb.send(new QueryCommand({
                    TableName: 'Likes',
                    IndexName: 'likesByFromUserIdAndToProfileId',
                    KeyConditionExpression: 'fromUserId = :toProfileId AND toProfileId = :fromUserId',
                    FilterExpression: 'actionType = :likeType',
                    ExpressionAttributeValues: {
                        ':fromUserId': fromUserId,
                        ':toProfileId': toProfileId,
                        ':likeType': 'LIKE'
                    },
                    Limit: 1
                }));

                const isMatch = mutualLike.Items && mutualLike.Items.length > 0;

                // 5. 좋아요 데이터 생성
                const likeId = uuidv4();
                const now = new Date().toISOString();
                
                const likeData = {
                    id: likeId,
                    fromUserId: fromUserId,
                    toProfileId: toProfileId,
                    actionType: likeType,
                    isMatched: isMatch,
                    createdAt: now,
                    updatedAt: now,
                    isActive: true
                };

                // 6. 트랜잭션으로 좋아요 저장 및 매칭 처리
                const transactItems = [
                    {
                        Put: {
                            TableName: 'Likes',
                            Item: likeData
                        }
                    }
                ];

                // 매칭인 경우 Matches 테이블에 추가
                if (isMatch) {
                    const matchId = uuidv4();
                    const user1Id = fromUserId < toProfileId ? fromUserId : toProfileId;
                    const user2Id = fromUserId < toProfileId ? toProfileId : fromUserId;
                    
                    const matchData = {
                        id: matchId,
                        user1Id: user1Id,
                        user2Id: user2Id,
                        status: 'ACTIVE',
                        createdAt: now,
                        lastActivity: now
                    };

                    transactItems.push({
                        Put: {
                            TableName: 'Matches',
                            Item: matchData
                        }
                    });

                    // 양쪽 사용자에게 알림 추가
                    const notificationId1 = uuidv4();
                    const notificationId2 = uuidv4();

                    transactItems.push(
                        {
                            Put: {
                                TableName: 'Notifications',
                                Item: {
                                    id: notificationId1,
                                    userId: fromUserId,
                                    fromUserId: toProfileId,
                                    type: 'MATCH',
                                    message: '새로운 매칭이 생겼습니다! 💕',
                                    isRead: false,
                                    createdAt: now
                                }
                            }
                        },
                        {
                            Put: {
                                TableName: 'Notifications',
                                Item: {
                                    id: notificationId2,
                                    userId: toProfileId,
                                    fromUserId: fromUserId,
                                    type: 'MATCH',
                                    message: '새로운 매칭이 생겼습니다! 💕',
                                    isRead: false,
                                    createdAt: now
                                }
                            }
                        }
                    );
                } else {
                    // 일반 좋아요 알림
                    const notificationId = uuidv4();
                    transactItems.push({
                        Put: {
                            TableName: 'Notifications',
                            Item: {
                                id: notificationId,
                                userId: toProfileId,
                                fromUserId: fromUserId,
                                type: 'LIKE',
                                message: '누군가 회원님을 좋아합니다 ❤️',
                                isRead: false,
                                createdAt: now
                            }
                        }
                    });
                }

                // 트랜잭션 실행
                await dynamoDb.send(new TransactWriteCommand({
                    TransactItems: transactItems
                }));

                console.log(`✅ 좋아요 전송 완료: ${isMatch ? '매칭 성사!' : '좋아요 전송'}`);

                return {
                    statusCode: 200,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({
                        success: true,
                        message: isMatch ? '매칭이 성사되었습니다!' : '좋아요를 보냈습니다',
                        data: {
                            like: likeData,
                            isMatch: isMatch,
                            dailyCount: dailyLikeCount + 1,
                            remaining: DAILY_LIKE_LIMIT - (dailyLikeCount + 1)
                        }
                    })
                };

            } catch (error) {
                console.error('좋아요 전송 오류:', error);
                return {
                    statusCode: 500,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({
                        success: false,
                        message: "좋아요 전송 중 오류가 발생했습니다: " + error.message,
                        data: null
                    })
                };
            }
        }

        // GET /likes/{userId}/daily-limit - 일일 제한 조회
        if (httpMethod === 'GET' && requestPath.includes('/daily-limit')) {
            const userId = event.pathParameters?.userId;
            if (!userId) {
                return {
                    statusCode: 400,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({
                        success: false,
                        message: "userId가 필요합니다",
                        data: null
                    })
                };
            }

            try {
                const today = new Date().toISOString().split('T')[0];
                const todayLikes = await dynamoDb.send(new QueryCommand({
                    TableName: 'Likes',
                    IndexName: 'likesByFromUserId',
                    KeyConditionExpression: 'fromUserId = :userId',
                    FilterExpression: 'begins_with(createdAt, :today) AND actionType = :likeType',
                    ExpressionAttributeValues: {
                        ':userId': userId,
                        ':today': today,
                        ':likeType': 'LIKE'
                    }
                }));

                const dailyCount = todayLikes.Items?.length || 0;
                const DAILY_LIKE_LIMIT = 20;

                return {
                    statusCode: 200,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({
                        success: true,
                        message: "일일 제한 조회 성공",
                        data: {
                            dailyCount: dailyCount,
                            limit: DAILY_LIKE_LIMIT,
                            remaining: Math.max(0, DAILY_LIKE_LIMIT - dailyCount),
                            resetTime: new Date(new Date().setHours(24, 0, 0, 0)).toISOString()
                        }
                    })
                };

            } catch (error) {
                console.error('일일 제한 조회 오류:', error);
                return {
                    statusCode: 500,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({
                        success: false,
                        message: "일일 제한 조회 중 오류가 발생했습니다: " + error.message,
                        data: null
                    })
                };
            }
        }

        // GET /likes/{userId}/received - 받은 좋아요 조회
        if (httpMethod === 'GET' && requestPath.includes('/received')) {
            const userId = event.pathParameters?.userId;
            if (!userId) {
                return {
                    statusCode: 400,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({
                        success: false,
                        message: "userId가 필요합니다",
                        data: null
                    })
                };
            }

            try {
                const receivedLikes = await dynamoDb.send(new QueryCommand({
                    TableName: 'Likes',
                    IndexName: 'likesByToProfileId',
                    KeyConditionExpression: 'toProfileId = :userId',
                    FilterExpression: 'actionType = :likeType',
                    ExpressionAttributeValues: {
                        ':userId': userId,
                        ':likeType': 'LIKE'
                    },
                    ScanIndexForward: false // 최신순 정렬
                }));

                return {
                    statusCode: 200,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({
                        success: true,
                        message: "받은 좋아요 조회 성공",
                        data: {
                            likes: receivedLikes.Items || [],
                            count: receivedLikes.Items?.length || 0
                        }
                    })
                };

            } catch (error) {
                console.error('받은 좋아요 조회 오류:', error);
                return {
                    statusCode: 500,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({
                        success: false,
                        message: "받은 좋아요 조회 중 오류가 발생했습니다: " + error.message,
                        data: null
                    })
                };
            }
        }

        // 지원하지 않는 경로/메서드
        return {
            statusCode: 404,
            headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({
                success: false,
                message: `경로를 찾을 수 없습니다: ${httpMethod} ${requestPath}`,
                data: null
            })
        };

    } catch (error) {
        console.error('Lambda error:', error);
        return {
            statusCode: 500,
            headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({
                success: false,
                message: "서버 오류가 발생했습니다: " + error.message,
                data: null
            })
        };
    }
};