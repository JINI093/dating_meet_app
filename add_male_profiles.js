import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";

// 남성 프로필 몇 개 추가하는 스크립트
export const handler = async (event) => {
    const client = new DynamoDBClient({ region: "ap-northeast-2" });
    const dynamoDb = DynamoDBDocumentClient.from(client);
    
    const maleProfiles = [
        {
            id: "male-1-" + Date.now(),
            userId: "male-1-" + Date.now(),
            name: "민수",
            age: 32,
            gender: "남성",
            location: "서울 강남구",
            bio: "안녕하세요! 진지한 만남을 찾고 있습니다.",
            occupation: "개발자",
            education: "대학교 졸업",
            height: 175,
            bodyType: "보통",
            smoking: "비흡연",
            drinking: "가끔",
            religion: "무교",
            mbti: "ENFP",
            hobbies: ["운동", "영화감상", "여행"],
            badges: [],
            isVip: false,
            isPremium: false,
            isVerified: true,
            isOnline: true,
            lastSeen: null,
            likeCount: 12,
            superChatCount: 3,
            profileImages: [
                "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400"
            ],
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            meetingType: "",
            incomeCode: ""
        },
        {
            id: "male-2-" + Date.now(),
            userId: "male-2-" + Date.now(),
            name: "준호",
            age: 29,
            gender: "남성",
            location: "서울 서초구",
            bio: "커피 좋아하는 디자이너입니다.",
            occupation: "디자이너",
            education: "대학교 졸업",
            height: 180,
            bodyType: "슬림",
            smoking: "비흡연",
            drinking: "사교적",
            religion: "기독교",
            mbti: "INFJ",
            hobbies: ["카페", "독서", "음악"],
            badges: ["인기"],
            isVip: true,
            isPremium: false,
            isVerified: true,
            isOnline: false,
            lastSeen: new Date(Date.now() - 30 * 60 * 1000).toISOString(), // 30분 전
            likeCount: 25,
            superChatCount: 8,
            profileImages: [
                "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400"
            ],
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            meetingType: "",
            incomeCode: ""
        },
        {
            id: "male-3-" + Date.now(),
            userId: "male-3-" + Date.now(),
            name: "현우",
            age: 35,
            gender: "남성",
            location: "경기도 분당구",
            bio: "성실하고 유머있는 사람입니다.",
            occupation: "의사",
            education: "대학원 졸업",
            height: 178,
            bodyType: "보통",
            smoking: "비흡연",
            drinking: "가끔",
            religion: "가톨릭",
            mbti: "ISTJ",
            hobbies: ["골프", "독서", "요리"],
            badges: ["VIP", "인증"],
            isVip: true,
            isPremium: true,
            isVerified: true,
            isOnline: true,
            lastSeen: null,
            likeCount: 38,
            superChatCount: 15,
            profileImages: [
                "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400"
            ],
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            meetingType: "",
            incomeCode: ""
        }
    ];
    
    try {
        for (const profile of maleProfiles) {
            await dynamoDb.send(new PutCommand({
                TableName: 'Profiles',
                Item: profile
            }));
            console.log(`✅ 남성 프로필 추가됨: ${profile.name}`);
        }
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: true,
                message: `${maleProfiles.length}개 남성 프로필 추가 완료`,
                profiles: maleProfiles.map(p => ({
                    id: p.id,
                    name: p.name,
                    age: p.age,
                    gender: p.gender
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