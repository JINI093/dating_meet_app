<?php
    // 각 버전 별 맞는 mobileOKManager-php를 사용
    $mobileOK_path = "./mobileOK_manager_phpseclib_v3.0_v1.0.2.php";

    if(!file_exists($mobileOK_path)) {
        die('1000|mobileOK_Key_Manager파일이 존재하지 않습니다.');
    } else {
        require_once $mobileOK_path;
    }
?>

<?php
    header("Content-Type:text/html;charset=utf-8");

    /* 1. 본인확인 인증결과 MOKToken API 요청 URL */
    /* 개발 및 테스트 시 개발 URL 적용 / 운영 환경에 적용 시 운영 URL 설정 필요 */        
    $MOK_RESULT_REQUEST_URL = "https://scert.mobile-ok.com/gui/service/v1/result/request";  // 개발
    // $MOK_RESULT_REQUEST_URL = "https://cert.mobile-ok.com/gui/service/v1/result/request";  //운영

    // (/* 7.2 : 페이지 이동 : redirect 방식, 이용기관 지정 페이지로 이동 */) 이용시 이동 URL
    $MOK_RESULT_REDIRECT_URL = "https://이용기관 URL/mok/result_page.php";

    /* 2. 본인확인 서비스 API 설정 */
    $mobileOK = new mobileOK_Key_Manager();
    /* 실제 키파일 및 패스워드 설정 */
    $key_path = __DIR__ . "/../mok_keyInfo.dat 2";
    $password = "Sinsa507!";
    $mobileOK->key_init($key_path, $password);
?>

<?php
    /* 본인확인 표준창 결과 요청 예제 함수 */
    function mobileOK_std_result($mobileOK, $MOK_RESULT_REQUEST_URL) {
        // local시간 설정이 다르게 될  수 있음으로 기본 시간 설정을 서울로 해놓는다.
        date_default_timezone_set('Asia/Seoul');

        /* 3. 본인확인 인증 결과 암호문 수신 */
        $request_array = $_POST['data'];
        $request_array = urldecode($request_array);
        $request_array = json_decode($request_array);

        /* 4. 본인확인 결과 타입별 결과 처리 */
        if (isset($request_array->encryptMOKKeyToken)) {
            /* 4.1 본인확인 결과 타입 : MOKToken */
            $encrypt_MOK_token = $request_array->encryptMOKKeyToken;
            $result_request_array = array(
                "encryptMOKKeyToken" => $encrypt_MOK_token
            );
            $result_request_json = json_encode($result_request_array, JSON_UNESCAPED_SLASHES);

            $result_response_json = sendPost($result_request_json, $MOK_RESULT_REQUEST_URL);
            $result_response_array = json_decode($result_response_json);

            $encryptMOKResult = $result_response_array->encryptMOKResult;
        } else {
            die("-1|본인확인 MOKToken 인증결과 응답이 없습니다.");
        }

        /* 5. 본인확인 결과 JSON 정보 처리 */
        try {
            $decrypt_result_json = $mobileOK->get_result($encryptMOKResult);
            $decrypt_result_array = json_decode($decrypt_result_json);
        } catch (Exception $e) {
            return '-2|본인확인 결과 복호화 오류';
        }

        /* 5-1 본인확인 결과정보 복호화 */
		/* 이용기관 거래 ID */
        $client_tx_id = isset($decrypt_result_array->clientTxId) ? $decrypt_result_array->clientTxId : null;
		
        session_start();
        $session_client_tx_id = $_SESSION['sessionClientTxId'];

		// 세션 내 요청 clientTxId 와 수신한 clientTxId 가 동일한지 비교
        if ($session_client_tx_id !== $client_tx_id){
            echo '-4|세션값에 저장된 거래ID 비교 실패';
            return '';
        }

        /* 사용자 이름 */
        $user_name = isset($decrypt_result_array->userName) ? $decrypt_result_array->userName : null;
        /* 이용기관 ID */
        $site_id = isset($decrypt_result_array->siteID) ? $decrypt_result_array->siteID : null;
        /* 본인확인 거래 ID */
        $tx_id = isset($decrypt_result_array->txId) ? $decrypt_result_array->txId : null;
        /* 서비스제공자(인증사업자) ID */
        $provider_id = isset($decrypt_result_array->providerId) ? $decrypt_result_array->providerId : null;
        /* 이용 서비스 유형 */
        $service_type = isset($decrypt_result_array->serviceType) ? $decrypt_result_array->serviceType : null;
        /* 시용자 CI */
        $ci = isset($decrypt_result_array->ci) ? $decrypt_result_array->ci : null;
        /* 사용자 DI */
        $di = isset($decrypt_result_array->di) ? $decrypt_result_array->di : null;
        /* 사용자 전화번호 */
        $user_phone = isset($decrypt_result_array->userPhone) ? $decrypt_result_array->userPhone : null;
        /* 사용자 생년월일 */
        $user_birthday = isset($decrypt_result_array->userBirthday) ? $decrypt_result_array->userBirthday : null;
        /* 사용자 성별 (1: 남자, 2: 여자) */
        $user_gender = isset($decrypt_result_array->userGender) ? $decrypt_result_array->userGender : null;
        /* 사용자 국적 (0: 내국인, 1: 외국인) */
        $user_nation = isset($decrypt_result_array->userNation) ? $decrypt_result_array->userNation : null;
        /* 본인확인 인증 종류 */
        $req_auth_type = $decrypt_result_array->reqAuthType;
        /* 본인확인 요청 시간 */
        $req_date = $decrypt_result_array->reqDate;
        /* 본인확인 인증 서버 */
        $issuer = $decrypt_result_array->issuer;
        /* 본인확인 인증 시간 */
        $issue_date = $decrypt_result_array->issueDate;

        /* 6. 이용기관 응답데이터 세션 및 검증유효시간 처리  */

        // 검증정보 유효시간 검증 (토큰 생성 후 10분 이내 검증 권고)
        $date_time = date("Y-m-d H:i:s");

        $old = strtotime($issue_date);
        $old = date("Y-m-d H:i:s", $old);

        $time_limit = strtotime($old."+10 minutes");
        $time_limit = date("Y-m-d H:i:s", $time_limit);

        if ($time_limit < $date_time) {
            $errorResult = array("resultMsg" => "-5|토큰 생성 10분 경과");
            return '';
        }

        /* 7. 이용기관 서비스 기능 처리 */

        // - 가맹점 측에서 기 수집 및 보유한 개인정보가 있는 경우 드림으로부터 제공받은 개인정보와 일치 여부를 반드시 검증 필요
        //   ➔ 검증 완료 시 사용자에 대한 본인확인 완료
        // - CI 일치 여부 검증 권장

        /* 8. 본인확인 결과 응답 */

        // 복호화된 개인정보는 DB보관 또는 세션보관하여 개인정보 저장시 본인확인에서 획득한 정보로 저장하도록 처리 필요
        // 개인정보를 웹브라우져에 전달할 경우 외부 해킹에 의해 유출되지 않도록 보안처리 필요

        $result_array = array(
            "resultCode" => "2000"
            , "resultMsg" => "성공"
            , "userName" => $user_name
        );
        $result_json = json_encode($result_array, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        return $result_json;
    }

    /* 본인확인 서버 통신 예제 함수 */
    function sendPost($data, $url) {
        $curl = curl_init();                                                              // curl 초기화
        curl_setopt($curl, CURLOPT_URL, $url);                                            // 데이터를 전송 할 URL
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);                                 // 요청결과를 문자열로 반환
        curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));  // 전송 ContentType을 Json형식으로 설정
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);                                // 원격 서버의 인증서가 유효한지 검사 여부
        curl_setopt($curl, CURLOPT_POSTFIELDS, $data);                                    // POST DATA
        curl_setopt($curl, CURLOPT_POST, true);                                           // POST 전송 여부
        $response = curl_exec($curl);                                                     // 전송
        curl_close($curl);                                                                // 연결해제

        return $response;
    }
?>
<?php 
    /* 7. 본인확인 결과 응답 방식 */
    /* 7.1 : 팝업창 : callback 함수 사용 */
    echo mobileOK_std_result($mobileOK, $MOK_RESULT_REQUEST_URL);
?>
<?php 
    // redirect 모드 이용시 "7.1 : 팝업창 : callback 함수 사용"  주석 처리 후 "7.2 : 페이지 이동" form 태그 주석제거 후 활성화

    /* 7.2 : 페이지 이동 : redirect 방식, 이용기관 지정 페이지로 이동 */
    /* 
    <form method="post" action="
    <?php 
        echo $MOK_RESULT_REDIRECT_URL;
    ?>  
    ">
        <textarea style="width:500px; height: 500px" name="data">
           <?php 
               echo mobileOK_std_result($mobileOK, $MOK_RESULT_REQUEST_URL);
           ?> 
       </textarea>
    </form>
    */
?>
