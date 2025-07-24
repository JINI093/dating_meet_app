import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, UpdateCommand } from "@aws-sdk/lib-dynamodb";

// 기존 "지은" 프로필에 userId 필드를 추가하는 스크립트
export const handler = async (event) => {
    const client = new DynamoDBClient({ region: "ap-northeast-2" });
    const dynamoDb = DynamoDBDocumentClient.from(client);
    
    try {
        // "지은" 프로필 (id: d4785d3c-6001-7085-26a1-d42dc0e8ed4e)에 userId 추가
        const profileId = "d4785d3c-6001-7085-26a1-d42dc0e8ed4e";
        const userId = "d4785d3c-6001-7085-26a1-d42dc0e8ed4e"; // Cognito userId
        
        console.log(`프로필 업데이트 중: ${profileId}`);
        
        await dynamoDb.send(new UpdateCommand({
            TableName: 'Profiles',
            Key: { id: profileId },
            UpdateExpression: 'SET userId = :userId',
            ExpressionAttributeValues: {
                ':userId': userId
            }
        }));
        
        console.log(`✅ 프로필에 userId 추가됨: ${userId}`);
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: true,
                message: "프로필 userId 업데이트 완료",
                profileId: profileId,
                userId: userId
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