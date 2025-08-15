<?php
header("Content-Type: application/json; charset=utf-8");

// 현재 환경 정보 출력
$debug_info = [
    "server_info" => [
        "http_host" => $_SERVER['HTTP_HOST'] ?? 'not set',
        "server_name" => $_SERVER['SERVER_NAME'] ?? 'not set',
        "server_port" => $_SERVER['SERVER_PORT'] ?? 'not set',
        "request_uri" => $_SERVER['REQUEST_URI'] ?? 'not set',
        "script_name" => $_SERVER['SCRIPT_NAME'] ?? 'not set',
    ],
    "files" => [
        "mok_keyInfo.dat" => file_exists("./mok_keyInfo.dat") ? "EXISTS" : "NOT FOUND",
        "mobileOK_manager" => file_exists("./mobileOK_manager_phpseclib_v3.0_v1.0.2.php") ? "EXISTS" : "NOT FOUND",
        "phpseclib_path" => file_exists("./phpseclib_path_3.0.php") ? "EXISTS" : "NOT FOUND",
    ],
    "php_info" => [
        "version" => PHP_VERSION,
        "openssl" => extension_loaded('openssl') ? "ENABLED" : "DISABLED",
        "mbstring" => extension_loaded('mbstring') ? "ENABLED" : "DISABLED",
        "json" => extension_loaded('json') ? "ENABLED" : "DISABLED",
        "curl" => extension_loaded('curl') ? "ENABLED" : "DISABLED",
    ],
    "pass_test" => []
];

// PASS 모듈 테스트
try {
    require_once "./mobileOK_manager_phpseclib_v3.0_v1.0.2.php";
    $debug_info["pass_test"]["module_load"] = "SUCCESS";
    
    $mobileOK = new mobileOK_Key_Manager();
    $debug_info["pass_test"]["class_init"] = "SUCCESS";
    
    $key_path = "./mok_keyInfo.dat";
    $password = "Sinsa507!";
    $mobileOK->key_init($key_path, $password);
    $debug_info["pass_test"]["key_init"] = "SUCCESS";
    
    $service_id = $mobileOK->get_service_id();
    $debug_info["pass_test"]["service_id"] = $service_id;
    
} catch (Exception $e) {
    $debug_info["pass_test"]["error"] = $e->getMessage();
}

echo json_encode($debug_info, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
?>