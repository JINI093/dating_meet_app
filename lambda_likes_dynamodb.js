const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand, PutCommand } = require('@aws-sdk/lib-dynamodb');

const dynamoClient = new DynamoDBClient({ region: 'ap-northeast-2' });
const dynamoDb = DynamoDBDocumentClient.from(dynamoClient);

const LIKES_TABLE = 'Likes';
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('=== SIMPLE LAMBDA START ===');
  console.log('Event:', JSON.stringify(event, null, 2));
  
  // CORS preflight 처리
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: ''
    };
  }
  
  try {
    const path = event.path || '';
    const method = event.httpMethod || '';
    
    console.log('Processing:', method, path);
    
    // POST /likes - 좋아요 생성
    if (method === 'POST' && path === '/likes') {
      const body = JSON.parse(event.body);
      return await createLike(body);
    }
    
    // GET /likes/{userId} - 보낸 좋아요 조회
    if (method === 'GET' && path.startsWith('/likes/') && !path.includes('/received')) {
      const userId = path.split('/')[2];
      console.log('Getting sent likes for:', userId);
      return await getSentLikes(userId);
    }
    
    // GET /likes/{userId}/received - 받은 좋아요 조회
    if (method === 'GET' && path.includes('/received')) {
      const pathParts = path.split('/');
      const userId = pathParts[2];
      console.log('Getting received likes for:', userId);
      return await getReceivedLikes(userId);
    }
    
    console.log('No matching route');
    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: true,
        message: 'No matching route',
        method: method,
        path: path,
        data: []
      })
    };
    
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      })
    };
  }
};

async function getSentLikes(userId) {
  try {
    const params = {
      TableName: LIKES_TABLE,
      FilterExpression: 'fromUserId = :userId',
      ExpressionAttributeValues: {
        ':userId': userId
      }
    };
    
    const response = await dynamoDb.send(new ScanCommand(params));
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
    return {
      statusCode: 500,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: false,
        error: error.message
      })
    };
  }
}

async function getReceivedLikes(userId) {
  try {
    const params = {
      TableName: LIKES_TABLE,
      FilterExpression: 'toProfileId = :userId',
      ExpressionAttributeValues: {
        ':userId': userId
      }
    };
    
    const response = await dynamoDb.send(new ScanCommand(params));
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
    return {
      statusCode: 500,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: false,
        error: error.message
      })
    };
  }
}

async function createLike(data) {
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
    
    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: true,
        data: {
          like: item
        }
      })
    };
  } catch (error) {
    console.error('Error creating like:', error);
    return {
      statusCode: 500,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: false,
        error: error.message
      })
    };
  }
}