import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand, GetCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({ region: "ap-northeast-2" });
const dynamoDb = DynamoDBDocumentClient.from(client);

// 사용자 포인트 초기화 (테스트용)
const initializeUserPoints = async (userId, initialPoints = 1000) => {
  try {
    // 기존 포인트 확인
    const existingPoints = await dynamoDb.send(new GetCommand({
      TableName: 'UserPoints',
      Key: { userId: userId }
    }));

    if (existingPoints.Item) {
      console.log(`✅ 사용자 ${userId}의 포인트가 이미 존재합니다: ${existingPoints.Item.points}점`);
      return existingPoints.Item;
    }

    // 새 포인트 레코드 생성
    const now = new Date().toISOString();
    const pointsData = {
      userId: userId,
      points: initialPoints,
      createdAt: now,
      updatedAt: now
    };

    await dynamoDb.send(new PutCommand({
      TableName: 'UserPoints',
      Item: pointsData
    }));

    console.log(`✅ 사용자 ${userId}에게 ${initialPoints}점 지급 완료`);
    return pointsData;

  } catch (error) {
    console.error(`❌ 사용자 ${userId} 포인트 초기화 실패:`, error);
    throw error;
  }
};

// 테스트 사용자들에게 포인트 지급
export const initializeTestUserPoints = async () => {
  console.log('=== 테스트 사용자 포인트 초기화 시작 ===');
  
  const testUsers = [
    { userId: 'd4785d3c-6001-7085-26a1-d42dc0e8ed4e', points: 2000 }, // 지은
    { userId: '44c85ddc-30d1-70b6-c4d9-5bb9ec26ca20', points: 1500 }, // 승우
  ];

  for (const user of testUsers) {
    await initializeUserPoints(user.userId, user.points);
  }
  
  console.log('=== 테스트 사용자 포인트 초기화 완료 ===');
};

// 직접 실행 시
if (import.meta.url === `file://${process.argv[1]}`) {
  initializeTestUserPoints().catch(console.error);
}

export default { initializeUserPoints, initializeTestUserPoints };