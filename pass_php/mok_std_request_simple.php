<?php
// 마이닷홈 PHP 버전 호환성 테스트
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

try {
    // PHP 버전 확인
    if (version_compare(PHP_VERSION, '5.6.0', '<')) {
        throw new Exception('PHP 버전이 너무 낮습니다: ' . PHP_VERSION);
    }

    // 기본 PASS 시뮬레이션 응답 (실제 키 파일 없이도 작동)
    $client_tx_id = "61624356-3699-4e48-aa27-41f1652eb928" . time();
    
    $send_data = array(
        'usageCode' => '01001',
        'serviceId' => 'a902a24c-5a7f-40c1-a5ba-92521fa8d731',
        'encryptReqClientInfo' => base64_encode($client_tx_id . "|" . date("YmdHis")),
        'serviceType' => 'telcoAuth',
        'retTransferType' => 'MOKToken',
        'returnUrl' => 'https://sagilrae.com/mok_std_result_simple.php'
    );

    echo json_encode($send_data, JSON_UNESCAPED_SLASHES);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        'error' => true,
        'message' => $e->getMessage(),
        'php_version' => PHP_VERSION
    ));
}
?>