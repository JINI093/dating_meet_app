package com.datingapp.pass;

import com.dreamsecurity.mobileOK.mobileOKKeyManager;
import com.dreamsecurity.mobileOK.MobileOKException;
import com.dreamsecurity.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;

import javax.servlet.http.HttpSession;
import java.util.UUID;
import java.util.Calendar;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/pass")
public class MobileOKController {

    @Value("${mobileok.keyfile.path}")
    private String keyFilePath;

    @Value("${mobileok.keyfile.password}")
    private String keyFilePassword;

    @Value("${mobileok.client.prefix}")
    private String clientPrefix;

    @Value("${mobileok.return.url}")
    private String returnUrl;

    @Value("${mobileok.service.id}")
    private String serviceId;

    private mobileOKKeyManager mobileOK;

    @PostMapping("/request")
    public ResponseEntity<Map<String, Object>> mobileOKRequest(HttpSession session) {
        try {
            // MobileOK 초기화
            if (mobileOK == null) {
                mobileOK = new mobileOKKeyManager();
                mobileOK.keyInit(keyFilePath, keyFilePassword);
            }

            // 거래 ID 생성
            String clientTxId = clientPrefix + UUID.randomUUID().toString().replaceAll("-", "");
            
            // 세션에 거래 ID 저장
            session.setAttribute("sessionClientTxId", clientTxId);

            // 인증 시간 생성
            Calendar cal = Calendar.getInstance();
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            String reqClientInfo = clientTxId + "|" + formatter.format(cal.getTime());

            // 거래 정보 암호화
            String encryptReqClientInfo = mobileOK.RSAEncrypt(reqClientInfo);

            // 요청 JSON 생성
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("usageCode", "01001"); // 회원가입
            jsonObject.put("serviceId", serviceId);
            jsonObject.put("encryptReqClientInfo", encryptReqClientInfo);
            jsonObject.put("serviceType", "telcoAuth");
            jsonObject.put("retTransferType", "MOKToken");
            jsonObject.put("returnUrl", returnUrl);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("requestData", jsonObject.toString());
            response.put("clientTxId", clientTxId);

            return ResponseEntity.ok(response);

        } catch (MobileOKException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("errorCode", e.getErrorCode());
            response.put("errorMessage", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("errorMessage", "서버 오류: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    @PostMapping("/result")
    public ResponseEntity<Map<String, Object>> mobileOKResult(
            @RequestBody Map<String, String> request,
            HttpSession session) {
        
        try {
            String data = request.get("data");
            if (data == null) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "errorMessage", "데이터가 없습니다."
                ));
            }

            // MobileOK 초기화
            if (mobileOK == null) {
                mobileOK = new mobileOKKeyManager();
                mobileOK.keyInit(keyFilePath, keyFilePassword);
            }

            // 결과 처리
            String result = mobileOK_std_result(data, mobileOK, session);
            
            // 결과 파싱
            JSONObject resultJson = new JSONObject(result);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("result", resultJson.toMap());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("errorMessage", "결과 처리 중 오류: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    private String mobileOK_std_result(String result, mobileOKKeyManager mobileOK, HttpSession session) {
        try {
            // 본인확인 인증결과 MOKToken API 요청 URL
            String targetUrl = "https://scert.mobile-ok.com/gui/service/v1/result/request"; // 개발

            // 본인확인 결과 타입별 결과 처리
            JSONObject resultJSON = new JSONObject(result);
            String encryptMOKKeyToken = resultJSON.optString("encryptMOKKeyToken", null);
            String encryptMOKResult = resultJSON.optString("encryptMOKResult", null);
            
            // 본인확인 결과 타입 : MOKToken
            if (encryptMOKKeyToken != null) {
                JSONObject requestData = new JSONObject();
                requestData.put("encryptMOKKeyToken", encryptMOKKeyToken);
                String responseData = sendPost(targetUrl, requestData.toString());
                if (responseData == null) {
                    return "-1|본인확인 MOKToken 인증결과 응답이 없습니다.";
                }
                JSONObject responseJSON = new JSONObject(responseData);
                encryptMOKResult = responseJSON.getString("encryptMOKResult");
            } else {
                return "-2|본인확인 MOKToken 값이 없습니다.";
            }

            // 본인확인 결과 JSON 정보 파싱
            JSONObject decrpytResultJson = null;
            try {
                decrpytResultJson = new JSONObject(mobileOK.getResultJSON(encryptMOKResult));
            } catch (MobileOKException e) {
                return e.getErrorCode() + "|" + e.getMessage();
            }

            // 세션 검증
            String sessionClientTxId = (String) session.getAttribute("sessionClientTxId");
            String clientTxId = decrpytResultJson.optString("clientTxId", null);
            
            if (!sessionClientTxId.equals(clientTxId)) {
                return "-4|세션값에 저장된 거래ID 비교 실패";
            }

            // 사용자 정보 추출
            String userName = decrpytResultJson.optString("userName", null);
            String userPhone = decrpytResultJson.optString("userPhone", null);
            String userBirthday = decrpytResultJson.optString("userBirthday", null);
            String userGender = decrpytResultJson.optString("userGender", null);
            String ci = decrpytResultJson.optString("ci", null);
            String di = decrpytResultJson.optString("di", null);
            String txId = decrpytResultJson.optString("txId", null);

            // 결과 JSON 생성
            JSONObject outputJson = new JSONObject();
            outputJson.put("resultCode", resultJSON.optString("resultCode", null));
            outputJson.put("resultMsg", resultJSON.optString("resultMsg", null));
            outputJson.put("userName", userName);
            outputJson.put("userPhone", userPhone);
            outputJson.put("userBirthday", userBirthday);
            outputJson.put("userGender", userGender);
            outputJson.put("ci", ci);
            outputJson.put("di", di);
            outputJson.put("txId", txId);
            outputJson.put("clientTxId", clientTxId);

            return outputJson.toString();

        } catch (Exception e) {
            e.printStackTrace();
            return "-999|서버 오류";
        }
    }

    private String sendPost(String dest, String jsonData) {
        java.net.HttpURLConnection connection = null;
        java.io.DataOutputStream dataOutputStream = null;
        java.io.BufferedReader bufferedReader = null;
        
        try {
            java.net.URL url = new java.net.URL(dest);
            connection = (java.net.HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
            connection.setDoOutput(true);

            dataOutputStream = new java.io.DataOutputStream(connection.getOutputStream());
            dataOutputStream.write(jsonData.getBytes("UTF-8"));

            bufferedReader = new java.io.BufferedReader(
                new java.io.InputStreamReader(connection.getInputStream())
            );
            StringBuffer responseData = new StringBuffer();
            String info;
            while ((info = bufferedReader.readLine()) != null) {
                responseData.append(info);
            }
            return responseData.toString();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (bufferedReader != null) bufferedReader.close();
                if (dataOutputStream != null) dataOutputStream.close();
                if (connection != null) connection.disconnect();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return null;
    }
}
