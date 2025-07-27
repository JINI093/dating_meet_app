import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { CreateTableCommand, DescribeTableCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "ap-northeast-2" });

// DynamoDB 테이블 스키마 정의
const tableDefinitions = [
  {
    TableName: 'Likes',
    KeySchema: [
      { AttributeName: 'id', KeyType: 'HASH' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'id', AttributeType: 'S' },
      { AttributeName: 'fromUserId', AttributeType: 'S' },
      { AttributeName: 'toProfileId', AttributeType: 'S' }
    ],
    GlobalSecondaryIndexes: [
      {
        IndexName: 'likesByFromUserId',
        KeySchema: [
          { AttributeName: 'fromUserId', KeyType: 'HASH' }
        ],
        Projection: { ProjectionType: 'ALL' },
        BillingMode: 'PAY_PER_REQUEST'
      },
      {
        IndexName: 'likesByToProfileId',
        KeySchema: [
          { AttributeName: 'toProfileId', KeyType: 'HASH' }
        ],
        Projection: { ProjectionType: 'ALL' },
        BillingMode: 'PAY_PER_REQUEST'
      },
      {
        IndexName: 'likesByFromUserIdAndToProfileId',
        KeySchema: [
          { AttributeName: 'fromUserId', KeyType: 'HASH' },
          { AttributeName: 'toProfileId', KeyType: 'RANGE' }
        ],
        Projection: { ProjectionType: 'ALL' },
        BillingMode: 'PAY_PER_REQUEST'
      }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  },
  
  {
    TableName: 'Superchats',
    KeySchema: [
      { AttributeName: 'id', KeyType: 'HASH' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'id', AttributeType: 'S' },
      { AttributeName: 'fromUserId', AttributeType: 'S' },
      { AttributeName: 'toProfileId', AttributeType: 'S' }
    ],
    GlobalSecondaryIndexes: [
      {
        IndexName: 'superchatsByFromUserId',
        KeySchema: [
          { AttributeName: 'fromUserId', KeyType: 'HASH' }
        ],
        Projection: { ProjectionType: 'ALL' },
        BillingMode: 'PAY_PER_REQUEST'
      },
      {
        IndexName: 'superchatsByToProfileId',
        KeySchema: [
          { AttributeName: 'toProfileId', KeyType: 'HASH' }
        ],
        Projection: { ProjectionType: 'ALL' },
        BillingMode: 'PAY_PER_REQUEST'
      },
      {
        IndexName: 'superchatsByFromUserIdAndToProfileId',
        KeySchema: [
          { AttributeName: 'fromUserId', KeyType: 'HASH' },
          { AttributeName: 'toProfileId', KeyType: 'RANGE' }
        ],
        Projection: { ProjectionType: 'ALL' },
        BillingMode: 'PAY_PER_REQUEST'
      }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  },

  {
    TableName: 'Matches',
    KeySchema: [
      { AttributeName: 'id', KeyType: 'HASH' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'id', AttributeType: 'S' },
      { AttributeName: 'user1Id', AttributeType: 'S' },
      { AttributeName: 'user2Id', AttributeType: 'S' }
    ],
    GlobalSecondaryIndexes: [
      {
        IndexName: 'matchesByUser1Id',
        KeySchema: [
          { AttributeName: 'user1Id', KeyType: 'HASH' }
        ],
        Projection: { ProjectionType: 'ALL' },
        BillingMode: 'PAY_PER_REQUEST'
      },
      {
        IndexName: 'matchesByUser2Id',
        KeySchema: [
          { AttributeName: 'user2Id', KeyType: 'HASH' }
        ],
        Projection: { ProjectionType: 'ALL' },
        BillingMode: 'PAY_PER_REQUEST'
      }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  },

  {
    TableName: 'UserPoints',
    KeySchema: [
      { AttributeName: 'userId', KeyType: 'HASH' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'userId', AttributeType: 'S' }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  },

  {
    TableName: 'PointsHistory',
    KeySchema: [
      { AttributeName: 'id', KeyType: 'HASH' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'id', AttributeType: 'S' },
      { AttributeName: 'userId', AttributeType: 'S' }
    ],
    GlobalSecondaryIndexes: [
      {
        IndexName: 'pointsHistoryByUserId',
        KeySchema: [
          { AttributeName: 'userId', KeyType: 'HASH' }
        ],
        Projection: { ProjectionType: 'ALL' },
        BillingMode: 'PAY_PER_REQUEST'
      }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  },

  {
    TableName: 'Notifications',
    KeySchema: [
      { AttributeName: 'id', KeyType: 'HASH' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'id', AttributeType: 'S' },
      { AttributeName: 'userId', AttributeType: 'S' }
    ],
    GlobalSecondaryIndexes: [
      {
        IndexName: 'notificationsByUserId',
        KeySchema: [
          { AttributeName: 'userId', KeyType: 'HASH' }
        ],
        Projection: { ProjectionType: 'ALL' },
        BillingMode: 'PAY_PER_REQUEST'
      }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  }
];

// 테이블 존재 여부 확인
async function tableExists(tableName) {
  try {
    await client.send(new DescribeTableCommand({ TableName: tableName }));
    return true;
  } catch (error) {
    if (error.name === 'ResourceNotFoundException') {
      return false;
    }
    throw error;
  }
}

// 테이블 생성
async function createTable(tableDefinition) {
  try {
    const exists = await tableExists(tableDefinition.TableName);
    
    if (exists) {
      console.log(`✅ 테이블 '${tableDefinition.TableName}'이 이미 존재합니다.`);
      return;
    }

    console.log(`🚀 테이블 '${tableDefinition.TableName}' 생성 중...`);
    
    await client.send(new CreateTableCommand(tableDefinition));
    
    console.log(`✅ 테이블 '${tableDefinition.TableName}' 생성 완료`);
  } catch (error) {
    console.error(`❌ 테이블 '${tableDefinition.TableName}' 생성 실패:`, error.message);
  }
}

// 모든 테이블 설정
export const setupAllTables = async () => {
  console.log('=== DynamoDB 테이블 설정 시작 ===');
  
  for (const tableDefinition of tableDefinitions) {
    await createTable(tableDefinition);
  }
  
  console.log('=== DynamoDB 테이블 설정 완료 ===');
};

// 직접 실행 시
if (import.meta.url === `file://${process.argv[1]}`) {
  setupAllTables().catch(console.error);
}

export default { setupAllTables };