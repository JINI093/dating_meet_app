<?php
    $phpseclib_rsa = "./phpseclib-1.0.20/phpseclib/Crypt/RSA.php";
    $phpseclib_aes = "./phpseclib-1.0.20/phpseclib/Crypt/AES.php";
    $phpseclib_big_integer = "./phpseclib-1.0.20/phpseclib/Math/BigInteger.php";
?>      
<?php
    if(!file_exists($phpseclib_rsa)
      || !file_exists($phpseclib_aes)
      || !file_exists($phpseclib_big_integer)) {
        if (!file_exists($phpseclib_rsa)) {
            die("1000|phpseclib 1.0.x의 RSA.php 경로가 일치하지 않습니다. 확인해 주세요.");
        } 

        if (!file_exists($phpseclib_aes)) {
            die("1000|phpseclib 1.0.x의 AES.php 경로가 일치하지 않습니다. 확인해 주세요.");
        }
        
        if (!file_exists($phpseclib_big_integer)) {
            die("1000|phpseclib 1.0.x의 BigInteger.php 경로가 일치하지 않습니다. 확인해 주세요.");
        } 
    } else {
        require_once $phpseclib_rsa;
        require_once $phpseclib_aes;
        require_once $phpseclib_big_integer;
    }
?>