const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand, QueryCommand } = require('@aws-sdk/lib-dynamodb');
const jwt = require('jsonwebtoken');

// AWS DynamoDB 설정
const client = new DynamoDBClient({ region: 'ap-northeast-2' });
const dynamodb = DynamoDBDocumentClient.from(client);

// 테이블 이름
const MESSAGES_TABLE = 'DatingMeet-Messages-dev';
const MATCHES_TABLE = 'DatingMeet-Matches-dev';

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
    'Content-Type': 'application/json'
};

exports.handler = async (event) => {
    console.log('🚀 Messages Lambda 시작:', JSON.stringify(event, null, 2));

    // CORS preflight 처리
    if (event.httpMethod === 'OPTIONS') {
        return {
            statusCode: 200,
            headers: corsHeaders,
            body: JSON.stringify({ message: 'CORS preflight response' })
        };
    }

    try {
        // JWT 토큰 확인
        const authToken = event.headers.Authorization || event.headers.authorization;
        if (!authToken) {
            console.log('❌ Authorization 헤더가 없습니다');
            return {
                statusCode: 401,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Authorization header required',
                    message: 'JWT 토큰이 필요합니다.'
                })
            };
        }

        // Bearer 토큰에서 실제 토큰 추출
        const token = authToken.startsWith('Bearer ') ? authToken.slice(7) : authToken;
        console.log('🔑 JWT 토큰 확인 중...');

        // AWS Cognito에서 사용자 정보 확인 (간단히 디코드만)
        const decodedToken = jwt.decode(token);
        if (!decodedToken || !decodedToken.sub) {
            console.log('❌ 유효하지 않은 JWT 토큰');
            return {
                statusCode: 401,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Invalid token',
                    message: '유효하지 않은 JWT 토큰입니다.'
                })
            };
        }

        const currentUserId = decodedToken.sub;
        console.log('✅ 인증된 사용자:', currentUserId);

        const method = event.httpMethod;
        const path = event.path;

        console.log(`📍 처리 중: ${method} ${path}`);

        // 라우팅 처리
        if (method === 'POST' && path === '/messages') {
            return await sendMessage(event, currentUserId);
        } else if (method === 'GET' && path.startsWith('/messages/match/')) {
            return await getMessages(event, currentUserId);
        } else if (method === 'PUT' && path.startsWith('/messages/read/')) {
            return await updateMessage(event, currentUserId);
        } else {
            return {
                statusCode: 404,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Not Found',
                    message: `경로 ${method} ${path}를 찾을 수 없습니다.`
                })
            };
        }

    } catch (error) {
        console.error('❌ Messages Lambda 오류:', error);
        return {
            statusCode: 500,
            headers: corsHeaders,
            body: JSON.stringify({ 
                error: 'Internal Server Error',
                message: error.message
            })
        };
    }
};

// 메시지 전송
async function sendMessage(event, currentUserId) {
    try {
        const body = JSON.parse(event.body);
        console.log('📨 메시지 전송 요청:', body);

        const { matchId, receiverId, content, messageType = 'text', superchatPoints } = body;

        if (!matchId || !receiverId || !content) {
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Bad Request',
                    message: 'matchId, receiverId, content가 필요합니다.'
                })
            };
        }

        // 매칭 확인
        const matchParams = {
            TableName: MATCHES_TABLE,
            Key: { id: matchId }
        };

        const matchResult = await dynamodb.send(new GetCommand(matchParams));
        if (!matchResult.Item) {
            console.log('❌ 매칭을 찾을 수 없음:', matchId);
            return {
                statusCode: 404,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Match Not Found',
                    message: '매칭을 찾을 수 없습니다.'
                })
            };
        }
        
        // 매칭 권한 확인 (메시지 전송)
        const match = matchResult.Item;
        console.log('🔍 메시지 전송 권한 확인:', {
            matchId: matchId,
            currentUserId: currentUserId,
            user1Id: match.user1Id,
            user2Id: match.user2Id,
            isUser1: match.user1Id === currentUserId,
            isUser2: match.user2Id === currentUserId
        });
        
        if (match.user1Id !== currentUserId && match.user2Id !== currentUserId) {
            console.log('❌ 권한 없음 - 사용자가 매칭에 포함되지 않음');
            return {
                statusCode: 403,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Forbidden',
                    message: '이 매칭에서 메시지를 보낼 권한이 없습니다.'
                })
            };
        }

        // 메시지 생성
        const messageId = `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const now = new Date().toISOString();

        const messageItem = {
            id: messageId,
            chatRoomId: matchId,
            senderId: currentUserId,
            receiverId: receiverId,
            content: content,
            messageType: messageType,
            status: 'sent',
            createdAt: now,
            updatedAt: now
        };

        // 슈퍼챗인 경우 포인트 정보 추가
        if (messageType === 'superchat' && superchatPoints) {
            messageItem.superchatPoints = superchatPoints;
        }

        // DynamoDB에 메시지 저장
        const messageParams = {
            TableName: MESSAGES_TABLE,
            Item: messageItem
        };

        await dynamodb.send(new PutCommand(messageParams));
        console.log('✅ 메시지 저장 완료:', messageId);

        // 매칭의 마지막 메시지 업데이트
        const updateMatchParams = {
            TableName: MATCHES_TABLE,
            Key: { id: matchId },
            UpdateExpression: 'SET lastMessage = :lastMessage, lastMessageAt = :lastMessageAt, lastMessageSenderId = :senderId, updatedAt = :updatedAt',
            ExpressionAttributeValues: {
                ':lastMessage': content,
                ':lastMessageAt': now,
                ':senderId': currentUserId,
                ':updatedAt': now
            }
        };

        await dynamodb.send(new UpdateCommand(updateMatchParams));
        console.log('✅ 매칭 마지막 메시지 업데이트 완료');

        return {
            statusCode: 201,
            headers: corsHeaders,
            body: JSON.stringify({
                message: '메시지 전송 성공',
                data: messageItem
            })
        };

    } catch (error) {
        console.error('❌ 메시지 전송 오류:', error);
        return {
            statusCode: 500,
            headers: corsHeaders,
            body: JSON.stringify({ 
                error: 'Message Send Failed',
                message: error.message
            })
        };
    }
}

// 메시지 목록 조회
async function getMessages(event, currentUserId) {
    try {
        // /messages/match/{matchId} 경로에서 matchId 추출
        const pathParts = event.path.split('/');
        const matchId = pathParts[pathParts.length - 1];
        const limit = parseInt(event.queryStringParameters?.limit) || 50;
        const nextToken = event.queryStringParameters?.nextToken;

        console.log(`📥 메시지 조회 요청: matchId=${matchId}, limit=${limit}`);

        if (!matchId) {
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Bad Request',
                    message: 'matchId가 필요합니다.'
                })
            };
        }

        // 매칭 권한 확인
        const matchParams = {
            TableName: MATCHES_TABLE,
            Key: { id: matchId }
        };

        const matchResult = await dynamodb.send(new GetCommand(matchParams));
        if (!matchResult.Item) {
            return {
                statusCode: 404,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Match Not Found',
                    message: '매칭을 찾을 수 없습니다.'
                })
            };
        }

        const match = matchResult.Item;
        console.log('🔍 매칭 권한 확인:', {
            matchId: matchId,
            currentUserId: currentUserId,
            user1Id: match.user1Id,
            user2Id: match.user2Id,
            isUser1: match.user1Id === currentUserId,
            isUser2: match.user2Id === currentUserId
        });
        
        if (match.user1Id !== currentUserId && match.user2Id !== currentUserId) {
            console.log('❌ 권한 없음 - 사용자가 매칭에 포함되지 않음');
            return {
                statusCode: 403,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Forbidden',
                    message: '이 매칭의 메시지에 접근할 권한이 없습니다.'
                })
            };
        }

        // 메시지 조회
        const queryParams = {
            TableName: MESSAGES_TABLE,
            IndexName: 'chatRoomId-createdAt-index', // GSI 사용
            KeyConditionExpression: 'chatRoomId = :chatRoomId',
            ExpressionAttributeValues: {
                ':chatRoomId': matchId
            },
            ScanIndexForward: false, // 최신순 정렬
            Limit: limit
        };

        if (nextToken) {
            queryParams.ExclusiveStartKey = JSON.parse(Buffer.from(nextToken, 'base64').toString());
        }

        const result = await dynamodb.send(new QueryCommand(queryParams));
        
        const messages = result.Items.map(item => ({
            ...item,
            isFromCurrentUser: item.senderId === currentUserId
        }));

        const response = {
            messages: messages,
            nextToken: result.LastEvaluatedKey ? 
                Buffer.from(JSON.stringify(result.LastEvaluatedKey)).toString('base64') : null
        };

        console.log(`✅ 메시지 조회 완료: ${messages.length}개`);

        return {
            statusCode: 200,
            headers: corsHeaders,
            body: JSON.stringify({
                message: '메시지 조회 성공',
                data: response
            })
        };

    } catch (error) {
        console.error('❌ 메시지 조회 오류:', error);
        return {
            statusCode: 500,
            headers: corsHeaders,
            body: JSON.stringify({ 
                error: 'Message Fetch Failed',
                message: error.message
            })
        };
    }
}

// 메시지 읽음 처리
async function updateMessage(event, currentUserId) {
    try {
        // /messages/read/{messageId} 경로에서 messageId 추출
        const pathParts = event.path.split('/');
        const messageId = pathParts[pathParts.length - 1];
        const body = JSON.parse(event.body);
        
        console.log(`📝 메시지 업데이트 요청: messageId=${messageId}`, body);

        if (!messageId) {
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Bad Request',
                    message: 'messageId가 필요합니다.'
                })
            };
        }

        // 메시지 존재 확인
        const getParams = {
            TableName: MESSAGES_TABLE,
            Key: { id: messageId }
        };

        const messageResult = await dynamodb.send(new GetCommand(getParams));
        if (!messageResult.Item) {
            return {
                statusCode: 404,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Message Not Found',
                    message: '메시지를 찾을 수 없습니다.'
                })
            };
        }

        const message = messageResult.Item;
        
        // 읽음 처리는 수신자만 가능
        if (message.receiverId !== currentUserId) {
            return {
                statusCode: 403,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Forbidden',
                    message: '이 메시지를 읽음 처리할 권한이 없습니다.'
                })
            };
        }

        // 메시지 업데이트
        const updateParams = {
            TableName: MESSAGES_TABLE,
            Key: { id: messageId },
            UpdateExpression: 'SET #status = :status, readAt = :readAt, updatedAt = :updatedAt',
            ExpressionAttributeNames: {
                '#status': 'status'
            },
            ExpressionAttributeValues: {
                ':status': 'read',
                ':readAt': new Date().toISOString(),
                ':updatedAt': new Date().toISOString()
            },
            ReturnValues: 'ALL_NEW'
        };

        const result = await dynamodb.send(new UpdateCommand(updateParams));
        console.log('✅ 메시지 읽음 처리 완료:', messageId);

        return {
            statusCode: 200,
            headers: corsHeaders,
            body: JSON.stringify({
                message: '메시지 업데이트 성공',
                data: result.Attributes
            })
        };

    } catch (error) {
        console.error('❌ 메시지 업데이트 오류:', error);
        return {
            statusCode: 500,
            headers: corsHeaders,
            body: JSON.stringify({ 
                error: 'Message Update Failed',
                message: error.message
            })
        };
    }
}