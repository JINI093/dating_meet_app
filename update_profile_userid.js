import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, ScanCommand, UpdateCommand } from "@aws-sdk/lib-dynamodb";

// 기존 프로필에 userId 필드를 추가하는 스크립트
export const handler = async (event) => {
    const client = new DynamoDBClient({ region: "ap-northeast-2" });
    const dynamoDb = DynamoDBDocumentClient.from(client);
    
    try {
        // 1. 모든 프로필 스캔
        const scanResult = await dynamoDb.send(new ScanCommand({
            TableName: 'Profiles'
        }));
        
        console.log(`총 ${scanResult.Items?.length || 0}개 프로필 발견`);
        
        if (scanResult.Items && scanResult.Items.length > 0) {
            for (const profile of scanResult.Items) {
                // userId가 없는 프로필만 업데이트
                if (!profile.userId) {
                    console.log(`프로필 업데이트 중: ${profile.name} (id: ${profile.id})`);
                    
                    // 특정 프로필에 대해 하드코딩된 userId 매핑
                    let userId = null;
                    
                    // "시아" 프로필에 대해 특정 userId 할당
                    if (profile.name === "시아" && profile.gender === "여성") {
                        userId = "4448cd9c-70a1-70db-db85-c011b0b2ce8b"; // 로그에서 확인한 실제 userId
                    }
                    
                    if (userId) {
                        await dynamoDb.send(new UpdateCommand({
                            TableName: 'Profiles',
                            Key: { id: profile.id },
                            UpdateExpression: 'SET userId = :userId',
                            ExpressionAttributeValues: {
                                ':userId': userId
                            }
                        }));
                        
                        console.log(`✅ ${profile.name} 프로필에 userId 추가됨: ${userId}`);
                    }
                }
            }
        }
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: true,
                message: "프로필 userId 업데이트 완료"
            })
        };
        
    } catch (error) {
        console.error('오류:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                message: error.message
            })
        };
    }
};