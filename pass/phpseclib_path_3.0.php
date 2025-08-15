<?php 
    // 개발 환경에서는 phpseclib을 사용하지 않고 시뮬레이션 모드로 동작
    $phpseclib_autoload = "./vendor/autoload.php";
    
    // phpseclib이 없으면 기본 클래스 정의
    if(!file_exists($phpseclib_autoload)) {
        // 시뮬레이션을 위한 더미 클래스들
        if (!class_exists('phpseclib3\Crypt\RSA')) {
            // RSA 더미 클래스
            class RSA {
                public function loadKey($key) { return true; }
                public function encrypt($data) { return base64_encode($data); }
                public function decrypt($data) { return base64_decode($data); }
            }
        }
        
        if (!class_exists('phpseclib3\Crypt\AES')) {
            // AES 더미 클래스
            class AES {
                public function setKey($key) { return true; }
                public function setIV($iv) { return true; }
                public function encrypt($data) { return base64_encode($data); }
                public function decrypt($data) { return base64_decode($data); }
            }
        }
    } else {
        require_once $phpseclib_autoload;
    }
?>