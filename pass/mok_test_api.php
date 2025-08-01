<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// OPTIONS 요청 처리 (CORS preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 테스트용 간단한 API
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // 테스트 응답
    $response = [
        'success' => true,
        'message' => 'MobileOK 테스트 API 연결 성공',
        'timestamp' => date('Y-m-d H:i:s'),
        'received_data' => $input
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>