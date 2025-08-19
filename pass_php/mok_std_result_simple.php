<?php
// 간단한 PASS 결과 시뮬레이션 (실제 키 파일 없이도 작동)
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");

try {
    // 실제 PASS 응답과 동일한 구조
    $result_array = array(
        "resultCode" => "2000",
        "resultMsg" => "성공",
        "txId" => "MOK" . time(),
        "clientTxId" => "61624356-3699-4e48-aa27-41f1652eb928" . time(),
        "siteID" => "a902a24c-5a7f-40c1-a5ba-92521fa8d731",
        "providerId" => "dreamsecurity",
        "serviceType" => "telcoAuth",
        "userName" => "테스트사용자",
        "userPhone" => "01012345678",
        "userBirthday" => "19900101",
        "userGender" => "1",
        "userNation" => "0",
        "ci" => "CI" . time() . "TEST",
        "di" => "DI" . time() . "TEST",
        "reqAuthType" => "SMS",
        "reqDate" => date("YmdHis"),
        "issuer" => "mobile-ok.com",
        "issueDate" => date("YmdHis")
    );
    
    echo json_encode($result_array, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        'error' => true,
        'message' => $e->getMessage()
    ));
}
?>