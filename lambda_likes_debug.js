const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand } = require('@aws-sdk/lib-dynamodb');

const dynamoClient = new DynamoDBClient({ region: 'ap-northeast-2' });
const dynamoDb = DynamoDBDocumentClient.from(dynamoClient);

const LIKES_TABLE = 'Likes';
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('=== DEBUG LAMBDA START ===');
  console.log('Event:', JSON.stringify(event, null, 2));
  
  try {
    const path = event.path || '';
    const method = event.httpMethod || '';
    
    console.log('Processing:', method, path);
    
    // GET /likes/{userId} - 보낸 좋아요 조회 (간단 버전)
    if (method === 'GET' && path.startsWith('/likes/') && !path.includes('/received')) {
      const userId = path.split('/')[2];
      console.log('Getting sent likes for:', userId);
      
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
    }
    
    // GET /likes/{userId}/received - 받은 좋아요 조회 (간단 버전)
    if (method === 'GET' && path.includes('/received')) {
      const pathParts = path.split('/');
      const userId = pathParts[2];
      console.log('Getting received likes for:', userId);
      
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
    }
    
    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        success: true,
        message: 'Debug version - no matching route',
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