/**
 * AWS Lambda Function: SMS 전송
 * 
 * 이 함수는 다음과 같은 기능을 제공합니다:
 * 1. AWS SNS를 통한 SMS 전송
 * 2. 국내 통신사 API 연동
 * 3. Twilio API 연동
 * 4. 전송 결과 로깅 및 모니터링
 */

const AWS = require('aws-sdk');
const axios = require('axios');

// AWS 서비스 초기화
const sns = new AWS.SNS({ region: process.env.AWS_REGION || 'ap-northeast-2' });
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
    console.log('SMS 전송 Lambda 함수 시작:', JSON.stringify(event));
    
    try {
        // CORS 헤더 설정
        const corsHeaders = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
            'Content-Type': 'application/json'
        };

        // OPTIONS 요청 처리 (CORS Preflight)
        if (event.httpMethod === 'OPTIONS') {
            return {
                statusCode: 200,
                headers: corsHeaders,
                body: JSON.stringify({ message: 'CORS preflight successful' })
            };
        }

        // 요청 파라미터 추출
        let requestBody;
        if (event.body) {
            requestBody = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
        } else {
            requestBody = event;
        }

        const { phoneNumber, message, provider = 'sns' } = requestBody;

        // 필수 파라미터 검증
        if (!phoneNumber || !message) {
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({
                    success: false,
                    error: '휴대폰 번호와 메시지는 필수입니다.'
                })
            };
        }

        // 전화번호 정규화
        const normalizedPhoneNumber = normalizePhoneNumber(phoneNumber);
        console.log(`전화번호 정규화: ${phoneNumber} -> ${normalizedPhoneNumber}`);

        let result;
        
        // 제공업체별 SMS 전송
        switch (provider.toLowerCase()) {
            case 'sns':
            case 'aws_sns':
                result = await sendViaSNS(normalizedPhoneNumber, message);
                break;
            
            case 'twilio':
                result = await sendViaTwilio(normalizedPhoneNumber, message);
                break;
            
            case 'kt':
                result = await sendViaKT(normalizedPhoneNumber, message);
                break;
            
            case 'skt':
                result = await sendViaSKT(normalizedPhoneNumber, message);
                break;
            
            case 'lgu':
                result = await sendViaLGU(normalizedPhoneNumber, message);
                break;
            
            default:
                result = await sendViaSNS(normalizedPhoneNumber, message); // 기본값: SNS
        }

        // 전송 로그 저장
        await saveSMSLog({
            phoneNumber: normalizedPhoneNumber,
            message: message,
            provider: provider,
            success: result.success,
            messageId: result.messageId,
            error: result.error,
            timestamp: new Date().toISOString()
        });

        return {
            statusCode: result.success ? 200 : 500,
            headers: corsHeaders,
            body: JSON.stringify({
                success: result.success,
                messageId: result.messageId,
                provider: provider,
                error: result.error
            })
        };

    } catch (error) {
        console.error('SMS 전송 Lambda 함수 오류:', error);
        
        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                success: false,
                error: `SMS 전송 실패: ${error.message}`
            })
        };
    }
};

/**
 * AWS SNS를 통한 SMS 전송
 */
async function sendViaSNS(phoneNumber, message) {
    try {
        console.log('AWS SNS를 통한 SMS 전송 시작');
        
        const params = {
            Message: message,
            PhoneNumber: phoneNumber,
            MessageAttributes: {
                'AWS.SNS.SMS.SMSType': {
                    DataType: 'String',
                    StringValue: 'Transactional'
                },
                'AWS.SNS.SMS.SenderID': {
                    DataType: 'String',
                    StringValue: '사귈래'
                }
            }
        };

        const result = await sns.publish(params).promise();
        console.log('AWS SNS 전송 성공:', result.MessageId);
        
        return {
            success: true,
            messageId: result.MessageId,
            provider: 'aws_sns'
        };
        
    } catch (error) {
        console.error('AWS SNS 전송 실패:', error);
        return {
            success: false,
            error: `SNS 전송 실패: ${error.message}`,
            provider: 'aws_sns'
        };
    }
}

/**
 * Twilio를 통한 SMS 전송
 */
async function sendViaTwilio(phoneNumber, message) {
    try {
        console.log('Twilio를 통한 SMS 전송 시작');
        
        const accountSid = process.env.TWILIO_ACCOUNT_SID;
        const authToken = process.env.TWILIO_AUTH_TOKEN;
        const fromNumber = process.env.TWILIO_FROM_NUMBER;

        if (!accountSid || !authToken || !fromNumber) {
            throw new Error('Twilio 설정이 완료되지 않았습니다.');
        }

        const auth = Buffer.from(`${accountSid}:${authToken}`).toString('base64');
        
        const response = await axios.post(
            `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`,
            new URLSearchParams({
                From: fromNumber,
                To: phoneNumber,
                Body: message
            }),
            {
                headers: {
                    'Authorization': `Basic ${auth}`,
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            }
        );

        console.log('Twilio 전송 성공:', response.data.sid);
        
        return {
            success: true,
            messageId: response.data.sid,
            provider: 'twilio'
        };
        
    } catch (error) {
        console.error('Twilio 전송 실패:', error.response?.data || error.message);
        return {
            success: false,
            error: `Twilio 전송 실패: ${error.response?.data?.message || error.message}`,
            provider: 'twilio'
        };
    }
}

/**
 * KT를 통한 SMS 전송
 */
async function sendViaKT(phoneNumber, message) {
    try {
        console.log('KT를 통한 SMS 전송 시작');
        
        const apiUrl = process.env.KT_SMS_API_URL || 'https://api.kt.com/sms';
        const apiKey = process.env.KT_API_KEY;
        const secretKey = process.env.KT_SECRET_KEY;
        const senderNumber = process.env.KT_SENDER_NUMBER;

        if (!apiKey || !secretKey || !senderNumber) {
            throw new Error('KT SMS 설정이 완료되지 않았습니다.');
        }

        // KT API 인증 헤더 생성
        const timestamp = Date.now().toString();
        const signature = generateKTSignature(apiKey, secretKey, timestamp);

        const response = await axios.post(
            `${apiUrl}/v1/send`,
            {
                sender: senderNumber,
                receiver: phoneNumber,
                message: message,
                type: 'SMS'
            },
            {
                headers: {
                    'X-API-KEY': apiKey,
                    'X-API-SIGNATURE': signature,
                    'X-API-TIMESTAMP': timestamp,
                    'Content-Type': 'application/json'
                }
            }
        );

        if (response.data.success) {
            console.log('KT 전송 성공:', response.data.messageId);
            return {
                success: true,
                messageId: response.data.messageId,
                provider: 'kt'
            };
        } else {
            throw new Error(response.data.message || 'KT SMS 전송 실패');
        }
        
    } catch (error) {
        console.error('KT 전송 실패:', error.response?.data || error.message);
        return {
            success: false,
            error: `KT 전송 실패: ${error.response?.data?.message || error.message}`,
            provider: 'kt'
        };
    }
}

/**
 * SKT를 통한 SMS 전송
 */
async function sendViaSKT(phoneNumber, message) {
    try {
        console.log('SKT를 통한 SMS 전송 시작');
        
        // 구현 필요: SKT API 연동
        console.log('⚠️ SKT SMS API는 아직 구현되지 않았습니다.');
        
        return {
            success: false,
            error: 'SKT SMS API는 아직 구현되지 않았습니다.',
            provider: 'skt'
        };
        
    } catch (error) {
        console.error('SKT 전송 실패:', error);
        return {
            success: false,
            error: `SKT 전송 실패: ${error.message}`,
            provider: 'skt'
        };
    }
}

/**
 * LG U+를 통한 SMS 전송
 */
async function sendViaLGU(phoneNumber, message) {
    try {
        console.log('LG U+를 통한 SMS 전송 시작');
        
        // 구현 필요: LG U+ API 연동
        console.log('⚠️ LG U+ SMS API는 아직 구현되지 않았습니다.');
        
        return {
            success: false,
            error: 'LG U+ SMS API는 아직 구현되지 않았습니다.',
            provider: 'lgu'
        };
        
    } catch (error) {
        console.error('LG U+ 전송 실패:', error);
        return {
            success: false,
            error: `LG U+ 전송 실패: ${error.message}`,
            provider: 'lgu'
        };
    }
}

/**
 * 전화번호 정규화 (한국 형식)
 */
function normalizePhoneNumber(phoneNumber) {
    // 숫자만 추출
    const digits = phoneNumber.replace(/[^\d]/g, '');
    
    // 한국 번호 형식 처리
    if (digits.startsWith('010') || digits.startsWith('011') || 
        digits.startsWith('016') || digits.startsWith('017') || 
        digits.startsWith('018') || digits.startsWith('019')) {
        return `+82${digits.substring(1)}`;
    } else if (digits.startsWith('82')) {
        return `+${digits}`;
    } else {
        return `+82${digits}`;
    }
}

/**
 * KT API 서명 생성
 */
function generateKTSignature(apiKey, secretKey, timestamp) {
    const crypto = require('crypto');
    const data = apiKey + timestamp;
    return crypto.createHmac('sha256', secretKey).update(data).digest('base64');
}

/**
 * SMS 전송 로그 저장
 */
async function saveSMSLog(logData) {
    try {
        const tableName = process.env.SMS_LOG_TABLE || 'sms_logs';
        
        const params = {
            TableName: tableName,
            Item: {
                id: generateUUID(),
                ...logData,
                createdAt: new Date().toISOString()
            }
        };

        await dynamodb.put(params).promise();
        console.log('SMS 로그 저장 완료');
        
    } catch (error) {
        console.error('SMS 로그 저장 실패:', error);
        // 로그 저장 실패는 전체 프로세스를 중단하지 않음
    }
}

/**
 * UUID 생성
 */
function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        const r = Math.random() * 16 | 0;
        const v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}