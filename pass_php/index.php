<?php
// 마이닷홈 PHP 테스트 페이지
header("Content-Type: text/html; charset=UTF-8");
?>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PASS 인증 서비스</title>
</head>
<body>
    <h1>PASS 인증 서비스</h1>
    <p>PHP 작동 테스트: <?php echo "정상 작동"; ?></p>
    <p>현재 시간: <?php echo date('Y-m-d H:i:s'); ?></p>
    <p><a href="./mok.html">PASS 인증 페이지로 이동</a></p>
    
    <h2>파일 체크:</h2>
    <ul>
        <li>mok.html: <?php echo file_exists('mok.html') ? '존재' : '없음'; ?></li>
        <li>mok_std_request.php: <?php echo file_exists('mok_std_request.php') ? '존재' : '없음'; ?></li>
        <li>mok_keyInfo.dat: <?php echo file_exists('mok_keyInfo.dat') ? '존재' : '없음'; ?></li>
    </ul>
</body>
</html>