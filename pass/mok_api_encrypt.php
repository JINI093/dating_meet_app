<?php
    // 각 버전 별 맞는 mobileOKManager-php를 사용
    $mobileOK_path = "./mobileOK_manager_phpseclib_v3.0_v1.0.2.php";

    if(!file_exists($mobileOK_path)) {
        die(json_encode(['success' => false, 'error' => 'mobileOK_Key_Manager파일이 존재하지 않습니다.']));
    } else {
        require_once $mobileOK_path;
    }

    // CORS 헤더 추가
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");
    header("Content-Type: application/json; charset=utf-8");

    // OPTIONS 요청 처리
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit();
    }

    /* 1. 본인확인 서비스 API 설정 */    
    $mobileOK = new mobileOK_Key_Manager();
    /* 실제 키파일 및 패스워드 설정 */
    $key_path = __DIR__ . "/../mok_keyInfo.dat";
    $password = "Sinsa507!";
    $mobileOK->key_init($key_path, $password);

    // POST 데이터 읽기
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        echo json_encode([
            'success' => false,
            'error' => '입력 데이터가 없습니다.'
        ]);
        exit;
    }

    $action = $input['action'] ?? '';

    switch ($action) {
        case 'encrypt':
            // 암호화 요청
            $plainText = $input['plainText'] ?? '';
            if (empty($plainText)) {
                echo json_encode([
                    'success' => false,
                    'error' => '암호화할 텍스트가 없습니다.'
                ]);
                exit;
            }

            try {
                $encrypted = $mobileOK->rsa_encrypt($plainText);
                echo json_encode([
                    'success' => true,
                    'encrypted' => $encrypted,
                    'serviceId' => $mobileOK->get_service_id()
                ]);
            } catch (Exception $e) {
                echo json_encode([
                    'success' => false,
                    'error' => '암호화 실패: ' . $e->getMessage()
                ]);
            }
            break;

        case 'decrypt':
            // 복호화 요청
            $encryptedText = $input['encryptedText'] ?? '';
            if (empty($encryptedText)) {
                echo json_encode([
                    'success' => false,
                    'error' => '복호화할 텍스트가 없습니다.'
                ]);
                exit;
            }

            try {
                $decrypted = $mobileOK->rsa_decrypt($encryptedText);
                echo json_encode([
                    'success' => true,
                    'decrypted' => $decrypted
                ]);
            } catch (Exception $e) {
                echo json_encode([
                    'success' => false,
                    'error' => '복호화 실패: ' . $e->getMessage()
                ]);
            }
            break;

        case 'getServiceInfo':
            // 서비스 정보 요청
            echo json_encode([
                'success' => true,
                'serviceId' => $mobileOK->get_service_id(),
                'clientPrefix' => '61624356-3699-4e48-aa27-41f1652eb928',
                'environment' => 'development'
            ]);
            break;

        default:
            echo json_encode([
                'success' => false,
                'error' => '알 수 없는 액션입니다.'
            ]);
            break;
    }
?>