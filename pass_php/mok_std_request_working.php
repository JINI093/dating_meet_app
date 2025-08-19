<?php
// PHP 오류 방지를 위한 최소한의 설정
error_reporting(E_ERROR | E_PARSE);
ini_set('display_errors', '0');

header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

try {
    // 실제 PASS 인증을 위한 기본 정보 설정
    $clientPrefix = "61624356-3699-4e48-aa27-41f1652eb928";
    $serviceId = "a902a24c-5a7f-40c1-a5ba-92521fa8d731";
    
    // 거래 ID 생성
    function generateUuid() {
        return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }
    
    date_default_timezone_set('Asia/Seoul');
    $clientTxId = $clientPrefix . generateUuid();
    $dateTime = date("YmdHis");
    
    // 세션에 거래 ID 저장
    session_start();
    $_SESSION['sessionClientTxId'] = $clientTxId;
    
    // PASS 요청 데이터 생성 (실제 형식)
    $sendData = array(
        'usageCode' => '01001',  // 회원가입
        'serviceId' => $serviceId,
        'encryptReqClientInfo' => base64_encode($clientTxId . "|" . $dateTime),
        'serviceType' => 'telcoAuth',
        'retTransferType' => 'MOKToken',
        'returnUrl' => 'https://withroyal.dothome.co.kr/mok_std_result_working.php'
    );
    
    echo json_encode($sendData, JSON_UNESCAPED_SLASHES);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        'error' => 'server_error',
        'message' => 'PHP processing failed'
    ));
}
?>