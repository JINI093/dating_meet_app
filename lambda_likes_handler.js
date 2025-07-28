const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, QueryCommand, ScanCommand, PutCommand } = require('@aws-sdk/lib-dynamodb');

const dynamoClient = new DynamoDBClient({ region: 'ap-northeast-2' });
const dynamoDb = DynamoDBDocumentClient.from(dynamoClient);

const LIKES_TABLE = 'Likes';
const MATCHES_TABLE = 'Matches';
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('=== LAMBDA START ===');
  console.log('Event:', JSON.stringify(event, null, 2));
  console.log('Event path:', event.path);
  console.log('Event httpMethod:', event.httpMethod);
  console.log('Event pathParameters:', event.pathParameters);
  
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
    
    // 보낸 좋아요 조회 - API Gateway 경로에 맞춤
    if (method === 'GET' && path.match(/^\/likes\/[^\/]+$/) && !path.includes('/received')) {
      const userId = path.split('/')[2];
      console.log('Getting sent likes for userId:', userId);
      return await getSentLikes(userId);
    }
    
    // 받은 좋아요 조회 - API Gateway 경로에 맞춤  
    if (method === 'GET' && path.match(/^\/likes\/[^\/]+\/received$/)) {
      const userId = path.split('/')[2];
      console.log('Getting received likes for userId:', userId);
      return await getReceivedLikes(userId);
    }
    
    // 전체 좋아요 조회 (디버깅용)
    if (method === 'GET' && path === '/likes/all') {
      return await getAllLikes();
    }
    
    // 좋아요 생성
    if (method === 'POST' && path === '/likes') {
      const body = JSON.parse(event.body);
      return await createLike(body);
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

async function getSentLikes(userId) {
  console.log('Getting sent likes for user:', userId);
  
  try {
    // fromUserId로 조회
    const params = {
      TableName: LIKES_TABLE,
      FilterExpression: 'fromUserId = :userId',
      ExpressionAttributeValues: {
        ':userId': userId
      }
    };
    
    const response = await dynamoDb.send(new ScanCommand(params));
    console.log('Sent likes response:', response);
    
    const items = response.Items || [];
    console.log(`Found ${items.length} sent likes for user ${userId}`);
    
    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: true,
        data: items
      })
    };
  } catch (error) {
    console.error('Error getting sent likes:', error);
    throw error;
  }
}

async function getReceivedLikes(userId) {
  console.log('Getting received likes for user:', userId);
  
  try {
    // toProfileId로 조회
    const params = {
      TableName: LIKES_TABLE,
      FilterExpression: 'toProfileId = :userId',
      ExpressionAttributeValues: {
        ':userId': userId
      }
    };
    
    const response = await dynamoDb.send(new ScanCommand(params));
    console.log('Received likes response:', response);
    
    const items = response.Items || [];
    console.log(`Found ${items.length} received likes for user ${userId}`);
    
    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: true,
        data: items
      })
    };
  } catch (error) {
    console.error('Error getting received likes:', error);
    throw error;
  }
}

async function getAllLikes() {
  console.log('Getting all likes');
  
  try {
    const params = {
      TableName: LIKES_TABLE,
      Limit: 100
    };
    
    const response = await dynamoDb.send(new ScanCommand(params));
    console.log('All likes response:', response);
    
    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: true,
        data: response.Items || [],
        count: response.Count
      })
    };
  } catch (error) {
    console.error('Error getting all likes:', error);
    throw error;
  }
}

async function createLike(data) {
  console.log('Creating like:', data);
  
  try {
    const now = new Date().toISOString();
    const likeId = `${data.fromUserId}_${data.toProfileId}_${Date.now()}`;
    
    const item = {
      id: likeId,
      fromUserId: data.fromUserId,
      toProfileId: data.toProfileId,
      actionType: data.likeType || 'LIKE',
      message: data.message || null,
      createdAt: now,
      updatedAt: now
    };
    
    const params = {
      TableName: LIKES_TABLE,
      Item: item
    };
    
    await dynamoDb.send(new PutCommand(params));
    
    // Check for mutual like (simple implementation)
    let isMatch = false;
    let matchId = null;
    try {
      const mutualLikeParams = {
        TableName: LIKES_TABLE,
        FilterExpression: 'fromUserId = :toUserId AND toProfileId = :fromUserId AND actionType = :actionType',
        ExpressionAttributeValues: {
          ':toUserId': data.toProfileId,
          ':fromUserId': data.fromUserId,
          ':actionType': 'LIKE'
        }
      };
      
      const mutualResponse = await dynamoDb.send(new ScanCommand(mutualLikeParams));
      isMatch = mutualResponse.Items && mutualResponse.Items.length > 0;
      console.log('Mutual like check:', isMatch);
      
      // If mutual like detected, create match record
      if (isMatch) {
        try {
          matchId = `match_${data.fromUserId}_${data.toProfileId}_${Date.now()}`;
          const matchItem = {
            id: matchId,
            user1Id: data.fromUserId,
            user2Id: data.toProfileId,
            createdAt: now,
            status: 'ACTIVE',
            lastMessageAt: now,
            unreadCount1: 0,
            unreadCount2: 0
          };
          
          const matchParams = {
            TableName: MATCHES_TABLE,
            Item: matchItem
          };
          
          await dynamoDb.send(new PutCommand(matchParams));
          console.log('Match record created:', matchId);
        } catch (matchError) {
          console.error('Error creating match record:', matchError);
          // Continue even if match creation fails
        }
      }
    } catch (mutualError) {
      console.error('Error checking mutual like:', mutualError);
      // Continue without failing the like creation
    }
    
    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: true,
        data: {
          like: item,
          isMatch: isMatch,
          matchId: matchId,
          remaining: 19 // Placeholder - would need proper daily limit tracking
        }
      })
    };
  } catch (error) {
    console.error('Error creating like:', error);
    throw error;
  }
}