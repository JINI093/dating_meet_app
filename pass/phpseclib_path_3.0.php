<?php 
    $phpseclib_autoload = "./vendor/autoload.php";
?>
<?php
    if(!file_exists($phpseclib_autoload)) {
        die('1000|phpseclib 3.0.x의 autoload.php 경로가 일치하지 않습니다. 확인해 주세요.');
    } else {
        require_once $phpseclib_autoload;
    }
?>