const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, QueryCommand, UpdateCommand, ScanCommand } = require("@aws-sdk/lib-dynamodb");

exports.handler = async (event) => {
    console.log('=== Notifications DynamoDB Handler ===');
    console.log('Full Event:', JSON.stringify(event, null, 2));
    
    try {
        const client = new DynamoDBClient({ region: "ap-northeast-2" });
        const dynamoDb = DynamoDBDocumentClient.from(client);
        
        // HTTP 메서드 확인
        const httpMethod = event.httpMethod || 
                          event.requestContext?.httpMethod || 
                          event.requestContext?.http?.method ||
                          'GET';
        
        const pathParameters = event.pathParameters || {};
        const queryStringParameters = event.queryStringParameters || {};
        
        console.log('HTTP Method:', httpMethod);
        console.log('Path Parameters:', pathParameters);
        console.log('Query Parameters:', queryStringParameters);
        
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
        
        // 경로별 라우팅
        if (httpMethod === 'GET') {
            if (pathParameters.userId) {
                if (event.resource && event.resource.includes('/unread-count/')) {
                    // 읽지 않은 알림 개수 조회
                    return await getUnreadNotificationCount(dynamoDb, pathParameters.userId);
                } else if (event.resource && event.resource.includes('/recent/')) {
                    // 최근 알림 조회 (폴링용)
                    const since = queryStringParameters.since;
                    return await getRecentNotifications(dynamoDb, pathParameters.userId, since);
                } else {
                    // 사용자 알림 전체 조회
                    return await getUserNotifications(dynamoDb, pathParameters.userId);
                }
            }
        } else if (httpMethod === 'PUT') {
            if (pathParameters.notificationId && event.resource && event.resource.includes('/read')) {
                // 특정 알림 읽음 처리
                let requestBody = {};
                if (event.body) {
                    try {
                        requestBody = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
                    } catch (e) {
                        console.error('Body parsing error:', e);
                    }
                }
                return await markNotificationAsRead(dynamoDb, pathParameters.notificationId, requestBody.userId);
            } else if (event.resource && event.resource.includes('/read-all')) {
                // 모든 알림 읽음 처리
                let requestBody = {};
                if (event.body) {
                    try {
                        requestBody = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
                    } catch (e) {
                        console.error('Body parsing error:', e);
                    }
                }
                return await markAllNotificationsAsRead(dynamoDb, requestBody.userId);
            }
        }
        
        // 지원하지 않는 경로
        return {
            statusCode: 404,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                message: "지원하지 않는 경로입니다",
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
                message: "서버 오류가 발생했습니다: " + error.message,
                data: null
            })
        };
    }
};

// 사용자의 모든 알림 조회
async function getUserNotifications(dynamoDb, userId) {
    try {
        console.log(`📥 사용자 알림 조회: ${userId}`);
        
        const response = await dynamoDb.send(new QueryCommand({
            TableName: 'Notifications',
            IndexName: 'notificationsByUserId',
            KeyConditionExpression: 'userId = :userId',
            ExpressionAttributeValues: {
                ':userId': userId
            },
            ScanIndexForward: false, // 최신 순으로 정렬
            Limit: 50 // 최대 50개
        }));
        
        const notifications = response.Items || [];
        console.log(`✅ 알림 ${notifications.length}개 조회 완료`);
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: true,
                message: "알림 조회 성공",
                data: notifications
            })
        };
        
    } catch (error) {
        console.error('사용자 알림 조회 실패:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                message: "알림 조회 실패: " + error.message,
                data: []
            })
        };
    }
}

// 읽지 않은 알림 개수 조회
async function getUnreadNotificationCount(dynamoDb, userId) {
    try {
        console.log(`📊 읽지 않은 알림 개수 조회: ${userId}`);
        
        const response = await dynamoDb.send(new QueryCommand({
            TableName: 'Notifications',
            IndexName: 'notificationsByUserId',
            KeyConditionExpression: 'userId = :userId',
            FilterExpression: 'isRead = :isRead',
            ExpressionAttributeValues: {
                ':userId': userId,
                ':isRead': false
            },
            Select: 'COUNT'
        }));
        
        const unreadCount = response.Count || 0;
        console.log(`✅ 읽지 않은 알림 개수: ${unreadCount}`);
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: true,
                message: "읽지 않은 알림 개수 조회 성공",
                data: { unreadCount: unreadCount }
            })
        };
        
    } catch (error) {
        console.error('읽지 않은 알림 개수 조회 실패:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                message: "읽지 않은 알림 개수 조회 실패: " + error.message,
                data: { unreadCount: 0 }
            })
        };
    }
}

// 최근 알림 조회 (실시간 폴링용)
async function getRecentNotifications(dynamoDb, userId, sinceTimestamp) {
    try {
        console.log(`🔄 최근 알림 조회: ${userId}, since: ${sinceTimestamp}`);
        
        let filterExpression = 'userId = :userId';
        const expressionAttributeValues = {
            ':userId': userId
        };
        
        if (sinceTimestamp) {
            filterExpression += ' AND createdAt > :since';
            expressionAttributeValues[':since'] = sinceTimestamp;
        }
        
        const response = await dynamoDb.send(new QueryCommand({
            TableName: 'Notifications',
            IndexName: 'notificationsByUserId',
            KeyConditionExpression: 'userId = :userId',
            FilterExpression: sinceTimestamp ? 'createdAt > :since' : undefined,
            ExpressionAttributeValues: expressionAttributeValues,
            ScanIndexForward: false, // 최신 순으로 정렬
            Limit: 20 // 최대 20개
        }));
        
        const notifications = response.Items || [];
        console.log(`✅ 최근 알림 ${notifications.length}개 조회 완료`);
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: true,
                message: "최근 알림 조회 성공",
                data: notifications
            })
        };
        
    } catch (error) {
        console.error('최근 알림 조회 실패:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                message: "최근 알림 조회 실패: " + error.message,
                data: []
            })
        };
    }
}

// 특정 알림 읽음 처리
async function markNotificationAsRead(dynamoDb, notificationId, userId) {
    try {
        console.log(`✅ 알림 읽음 처리: ${notificationId}, 사용자: ${userId}`);
        
        await dynamoDb.send(new UpdateCommand({
            TableName: 'Notifications',
            Key: { id: notificationId },
            UpdateExpression: 'SET isRead = :isRead, updatedAt = :updatedAt',
            ConditionExpression: 'userId = :userId', // 본인의 알림만 수정 가능
            ExpressionAttributeValues: {
                ':isRead': true,
                ':updatedAt': new Date().toISOString(),
                ':userId': userId
            }
        }));
        
        console.log(`✅ 알림 읽음 처리 완료: ${notificationId}`);
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: true,
                message: "알림 읽음 처리 성공",
                data: { notificationId: notificationId }
            })
        };
        
    } catch (error) {
        console.error('알림 읽음 처리 실패:', error);
        
        if (error.name === 'ConditionalCheckFailedException') {
            return {
                statusCode: 403,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    success: false,
                    message: "해당 알림에 대한 권한이 없습니다",
                    data: null
                })
            };
        }
        
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                message: "알림 읽음 처리 실패: " + error.message,
                data: null
            })
        };
    }
}

// 모든 알림 읽음 처리
async function markAllNotificationsAsRead(dynamoDb, userId) {
    try {
        console.log(`✅ 모든 알림 읽음 처리: ${userId}`);
        
        // 먼저 사용자의 읽지 않은 알림들을 조회
        const unreadNotifications = await dynamoDb.send(new QueryCommand({
            TableName: 'Notifications',
            IndexName: 'notificationsByUserId',
            KeyConditionExpression: 'userId = :userId',
            FilterExpression: 'isRead = :isRead',
            ExpressionAttributeValues: {
                ':userId': userId,
                ':isRead': false
            }
        }));
        
        const notifications = unreadNotifications.Items || [];
        console.log(`📝 읽지 않은 알림 ${notifications.length}개 발견`);
        
        // 각 알림을 읽음 상태로 업데이트
        const updatePromises = notifications.map(notification => 
            dynamoDb.send(new UpdateCommand({
                TableName: 'Notifications',
                Key: { id: notification.id },
                UpdateExpression: 'SET isRead = :isRead, updatedAt = :updatedAt',
                ExpressionAttributeValues: {
                    ':isRead': true,
                    ':updatedAt': new Date().toISOString()
                }
            }))
        );
        
        await Promise.all(updatePromises);
        console.log(`✅ 모든 알림 읽음 처리 완료: ${notifications.length}개`);
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: true,
                message: "모든 알림 읽음 처리 성공",
                data: { updatedCount: notifications.length }
            })
        };
        
    } catch (error) {
        console.error('모든 알림 읽음 처리 실패:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                message: "모든 알림 읽음 처리 실패: " + error.message,
                data: null
            })
        };
    }
}