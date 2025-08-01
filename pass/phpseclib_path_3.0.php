<?php 
    // vendor 디렉토리가 없는 경우를 위한 임시 설정
    $phpseclib_autoload = __DIR__ . "/vendor/autoload.php";
    
    // vendor가 없으면 상위 디렉토리 확인
    if (!file_exists($phpseclib_autoload)) {
        $phpseclib_autoload = __DIR__ . "/../vendor/autoload.php";
    }
?>
<?php
    if(!file_exists($phpseclib_autoload)) {
        die('1000|phpseclib 3.0.x의 autoload.php 경로가 일치하지 않습니다. 확인해 주세요.');
    } else {
        require_once $phpseclib_autoload;
    }
?>