import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, ScanCommand, DeleteCommand } from "@aws-sdk/lib-dynamodb";

// 중복 프로필 정리 및 userId 매핑 수정 스크립트
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
            // 프로필 정보 출력
            for (const profile of scanResult.Items) {
                console.log('---');
                console.log(`프로필 ID: ${profile.id}`);
                console.log(`이름: ${profile.name}`);
                console.log(`성별: ${profile.gender}`);
                console.log(`userId: ${profile.userId || '없음'}`);
                console.log(`생성일: ${profile.createdAt}`);
                
                // 테스트를 위해 생성된 중복 프로필 삭제 (선택사항)
                // 주의: 실제 운영 환경에서는 신중하게 사용하세요
                if (event.action === 'cleanup') {
                    // "지은" 프로필 삭제 (새로 생성된 테스트 프로필)
                    if (profile.name === "지은" && profile.id === "d4785d3c-6001-7085-26a1-d42dc0e8ed4e") {
                        console.log(`⚠️ 테스트 프로필 "${profile.name}" 삭제 중...`);
                        await dynamoDb.send(new DeleteCommand({
                            TableName: 'Profiles',
                            Key: { id: profile.id }
                        }));
                        console.log(`✅ 프로필 삭제됨: ${profile.name}`);
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
                message: "프로필 스캔 완료",
                profileCount: scanResult.Items?.length || 0,
                profiles: scanResult.Items?.map(p => ({
                    id: p.id,
                    name: p.name,
                    gender: p.gender,
                    userId: p.userId
                }))
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