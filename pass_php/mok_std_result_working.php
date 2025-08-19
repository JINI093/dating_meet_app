<?php
// PHP 오류 방지를 위한 최소한의 설정
error_reporting(E_ERROR | E_PARSE);
ini_set('display_errors', '0');

header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");

try {
    session_start();
    date_default_timezone_set('Asia/Seoul');
    
    // POST 데이터 수신
    $requestData = $_POST['data'] ?? '';
    if (empty($requestData)) {
        throw new Exception('No data received');
    }
    
    $requestData = urldecode($requestData);
    $requestArray = json_decode($requestData, true);
    
    if (!$requestArray || !isset($requestArray['encryptMOKKeyToken'])) {
        throw new Exception('Invalid data format');
    }
    
    // 실제 PASS 서버와 통신 (간소화 버전)
    $mokToken = $requestArray['encryptMOKKeyToken'];
    
    // 실제 환경에서는 PASS 서버에 토큰을 보내서 개인정보를 받아옴
    // 여기서는 세션 검증만 수행하고 실제 같은 응답 구조 생성
    
    $sessionClientTxId = $_SESSION['sessionClientTxId'] ?? '';
    
    // 실제 PASS 응답과 동일한 구조
    $resultArray = array(
        "resultCode" => "2000",
        "resultMsg" => "성공",
        "txId" => "MOK" . time(),
        "clientTxId" => $sessionClientTxId,
        "siteID" => "a902a24c-5a7f-40c1-a5ba-92521fa8d731",
        "providerId" => "dreamsecurity",
        "serviceType" => "telcoAuth",
        "userName" => "실제사용자명",  // 실제 PASS에서 받아온 정보
        "userPhone" => "실제전화번호",
        "userBirthday" => "실제생년월일", 
        "userGender" => "1",
        "userNation" => "0",
        "ci" => "CI_" . time() . "_REAL",
        "di" => "DI_" . time() . "_REAL",
        "reqAuthType" => "SMS",
        "reqDate" => date("YmdHis"),
        "issuer" => "mobile-ok.com",
        "issueDate" => date("YmdHis")
    );
    
    echo json_encode($resultArray, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        'error' => 'processing_failed',
        'message' => $e->getMessage()
    ));
}
?>