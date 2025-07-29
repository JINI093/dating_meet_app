const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, QueryCommand, ScanCommand, GetCommand } = require('@aws-sdk/lib-dynamodb');

const dynamoClient = new DynamoDBClient({ region: 'ap-northeast-2' });
const dynamoDb = DynamoDBDocumentClient.from(dynamoClient);

const MATCHES_TABLE = 'DatingMeet-Matches-dev';
const MESSAGES_TABLE = 'DatingMeet-Messages-dev';
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('=== MATCHES LAMBDA START ===');
  console.log('Event:', JSON.stringify(event, null, 2));
  
  // CORS preflight 처리
  if (event.httpMethod === 'OPTIONS') {
    console.log('Handling CORS preflight');
    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: ''
    };
  }
  
  try {
    const path = event.path;
    const method = event.httpMethod;
    
    console.log('Processing request:', method, path);
    
    // 사용자의 매칭 목록 조회 - /matches/user/{userId}
    if (method === 'GET' && path.match(/^\/matches\/user\/[^\/]+$/)) {
      const userId = path.split('/')[3];
      console.log('Getting matches for userId:', userId);
      return await getUserMatches(userId);
    }
    
    // 특정 매칭 조회 - /matches/{matchId}
    if (method === 'GET' && path.match(/^\/matches\/[^\/]+$/)) {
      const matchId = path.split('/')[2];
      console.log('Getting match details for matchId:', matchId);
      return await getMatch(matchId);
    }
    
    console.log('No matching route found for:', method, path);
    return {
      statusCode: 404,
      headers: CORS_HEADERS,
      body: JSON.stringify({ error: 'Not Found', method, path })
    };
    
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: CORS_HEADERS,
      body: JSON.stringify({ 
        error: 'Internal Server Error',
        message: error.message 
      })
    };
  }
};

async function getUserMatches(userId) {
  console.log('Getting matches for user:', userId);
  
  try {
    // GSI로 user1Id 기준 매칭 조회
    const user1Params = {
      TableName: MATCHES_TABLE,
      IndexName: 'user1Id-createdAt-index',
      KeyConditionExpression: 'user1Id = :userId',
      ExpressionAttributeValues: {
        ':userId': userId
      },
      ScanIndexForward: false // 최신순 정렬
    };
    
    // GSI로 user2Id 기준 매칭 조회
    const user2Params = {
      TableName: MATCHES_TABLE,
      IndexName: 'user2Id-createdAt-index',
      KeyConditionExpression: 'user2Id = :userId',
      ExpressionAttributeValues: {
        ':userId': userId
      },
      ScanIndexForward: false // 최신순 정렬
    };
    
    const [user1Response, user2Response] = await Promise.all([
      dynamoDb.send(new QueryCommand(user1Params)),
      dynamoDb.send(new QueryCommand(user2Params))
    ]);
    
    console.log('User1 matches response:', user1Response);
    console.log('User2 matches response:', user2Response);
    
    // 두 결과 합치기
    const allMatches = [
      ...(user1Response.Items || []),
      ...(user2Response.Items || [])
    ];
    
    // 중복 제거 및 최신순 정렬
    const uniqueMatches = {};
    allMatches.forEach(match => {
      uniqueMatches[match.id] = match;
    });
    
    const matches = Object.values(uniqueMatches)
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    
    console.log(`Found ${matches.length} matches for user ${userId}`);
    
    // 각 매칭에 마지막 메시지 정보 추가
    const matchesWithMessages = await Promise.all(
      matches.map(async (match) => {
        try {
          const lastMessage = await getLastMessageForMatch(match.id);
          return {
            ...match,
            lastMessage: lastMessage?.content || null,
            lastMessageTime: lastMessage?.createdAt || match.createdAt,
            lastMessageSenderId: lastMessage?.senderId || null
          };
        } catch (error) {
          console.error(`Error getting last message for match ${match.id}:`, error);
          return match;
        }
      })
    );
    
    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: true,
        data: matchesWithMessages
      })
    };
  } catch (error) {
    console.error('Error getting user matches:', error);
    throw error;
  }
}

async function getMatch(matchId) {
  console.log('Getting match details for:', matchId);
  
  try {
    const params = {
      TableName: MATCHES_TABLE,
      Key: {
        id: matchId
      }
    };
    
    const response = await dynamoDb.send(new GetCommand(params));
    console.log('Match details response:', response);
    
    if (!response.Item) {
      return {
        statusCode: 404,
        headers: CORS_HEADERS,
        body: JSON.stringify({
          success: false,
          error: 'Match not found'
        })
      };
    }
    
    // 마지막 메시지 정보 추가
    const lastMessage = await getLastMessageForMatch(matchId);
    const match = {
      ...response.Item,
      lastMessage: lastMessage?.content || null,
      lastMessageTime: lastMessage?.createdAt || response.Item.createdAt,
      lastMessageSenderId: lastMessage?.senderId || null
    };
    
    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: true,
        data: match
      })
    };
  } catch (error) {
    console.error('Error getting match details:', error);
    throw error;
  }
}

async function getLastMessageForMatch(matchId) {
  try {
    const params = {
      TableName: MESSAGES_TABLE,
      IndexName: 'chatRoomId-createdAt-index',
      KeyConditionExpression: 'chatRoomId = :chatRoomId',
      ExpressionAttributeValues: {
        ':chatRoomId': matchId
      },
      ScanIndexForward: false, // 최신순
      Limit: 1
    };
    
    const response = await dynamoDb.send(new QueryCommand(params));
    return response.Items?.[0] || null;
  } catch (error) {
    console.error('Error getting last message:', error);
    return null;
  }
}