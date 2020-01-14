import 'dart:developer' as developer;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:Hwa/constant.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';


/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-24
 * @description : Call api utility
 *              - return : response(No Json encode) || Error
 */
enum HTTP_METHOD {
  post,
  get,
  put,
  patch,
  delete
}

class CallApi {
    static int retryCount = 0;

    static setData(Map data) {
        if (data == null) {
            return {};
        } else {
            return data;
        }
    }

    static logRequest(String prefixUrl, method, url, data){
	    developer.log("#Request Url : " + url.toString());
	    developer.log("#Data : " + data.toString());
    }

    static setResponse(http.Response response, HTTP_METHOD method, String url, Map data, String prefixUrl) async {
        var statusCode = response.statusCode.toString();

        if(statusCode.indexOf("20") > -1) {
            return response;
        } else {
	        int errorCode = jsonDecode(response.body)['errorCode'];
            ///Expired token 처리
            if(errorCode == 12){
                developer.log("# Token expired");

                bool isUpdateSuccess = await updateExpiredToken();

                if(isUpdateSuccess){
                    await reTryCallApi(method, url, data, prefixUrl);
                } else {
                    developer.log("# [Error] Refresh token failed.");
                    //TODO logout처리?????
                }
            } else {
                developer.log("# [Error] Status Code :" + statusCode);
                return null;
            }
        }
    }

    /*
     * @author : sh
     * @date : 2020-01-12
     * @description : accessToken 만료 되었을때 업데이트 해주기
     */
    static updateExpiredToken () async {
        SharedPreferences spf = await Constant.getSPF();
        Map userInfo = jsonDecode(spf.getString('userInfo'));
        String refreshToken = userInfo['refreshToken'];

        String url = Constant.API_SERVER_HTTP+"/api/v2/auth/A07-RefreshToken";

        final response = await http.get(url,
            headers: {
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'X-Authorization': "Bearer " +refreshToken,
            }
        );

        if (response.statusCode == 200) {
            String token = jsonDecode(response.body)['data']['token'];
            refreshToken = jsonDecode(response.body)['data']['refreshToken'];

            ///SPF token, refreshToken 저장
            userInfo['token'] = token;
            userInfo['refreshToken'] = refreshToken;
            spf.setString("userInfo", jsonEncode(userInfo));

            ///Constant Header 설정
            Constant.HEADER = {
                'Content-Type': 'application/json',
                'X-Authorization': 'Bearer ' + token
            };

            developer.log("# Refreshed token and setting Constant.header, SPF.");
            return true;
        }

        ///실패했을때 다시 시도 (5번까지)
        if(retryCount < 5){
            retryCount ++;
            Future.delayed(Duration(milliseconds: 1000));

            developer.log("# Retry refresh the accessToken.");
            developer.log("# Retry count : " + retryCount.toString());

            await updateExpiredToken();
        }

        return false;
    }

    /*
     * @author : sh
     * @date : 2020-01-12
     * @description : 실패한 api 다시 요청
     */
    static reTryCallApi (HTTP_METHOD method, String url, Map data, String prefixUrl) async {
        developer.log("# Retry call api :" + url);

        switch(prefixUrl) {
            case "https://api.hwaya.net": commonApiCall(method: method, url: url, data: data);
            break;

            case "wss://msg.hwaya.net/danhwa": messageApiCall(method: method, url: url, data: data);
            break;

            case "https://msg.hwaya.net": chattingApiCall(method: method, url: url, data: data);
            break;

            default: { developer.log("# Invalid API"); }
            break;
        }
    }

    /*
     * @author : hk
     * @date : 2020-01-11
     * @description : JWT 셋팅된 Dio 얻기
     */
    static Future<Dio> getDio() async {
	    SharedPreferences prefs = await Constant.getSPF();
	    var token = jsonDecode(prefs.getString('userInfo'))['token'].toString();

	    Dio dio = Dio();
	    dio.options.headers['X-Authorization'] = 'Bearer ' + token;
	    return dio;
    }

    /*
     * @author : hk
     * @date : 2019-12-31
     * @description : 파일업로드 API 연동 util
     */
    static Future<Response> fileUploadCall({
		    @required String url
		    , @required String filePath
		    , Map<String, dynamic> paramMap
		    , String fileParameterName
		    , String contentsType
		    , Function onSendProgress
		    , Function onError}) async {

        String fileName = filePath.substring(filePath.lastIndexOf("/") + 1, filePath.length);

	    Response response;
	    Dio dio = await getDio();

	    contentsType = contentsType ?? lookupMimeType(filePath) ?? "multipart/form-data";
        dio.options.headers['Content-Type'] = contentsType;
        dio.options.contentType = contentsType;

	    paramMap = paramMap ?? Map<String, dynamic>();
	    fileParameterName = fileParameterName ?? "file";

        MediaType mediaType;
        MultipartFile uploadFile;

        try{mediaType = MediaType.parse(contentsType);}catch(e){}

        if(mediaType != null) uploadFile= await MultipartFile.fromFile(filePath, filename: fileName, contentType: mediaType);
        else uploadFile= await MultipartFile.fromFile(filePath, filename: fileName);

	    if(uploadFile != null){
		    // 파일 너무 크면 리턴
			if(uploadFile.length > Constant.MAX_FILE_SIZE){
				if(onError != null) onError("oversize");
				return null;
			}

			paramMap[fileParameterName] = uploadFile;

			if(onError != null){
				dio.interceptors.add(InterceptorsWrapper(
						onRequest:(RequestOptions options) async {
							// Do something before request is sent
							return options; //continue
						},
						onResponse:(Response response) async {
							// Do something with response data
							return response; // continue
						},
						onError: (DioError e) async {
							// Do something with response error
							onError(e);
							return  e;//continue
						}
				));
			}

			var formData = FormData.fromMap(paramMap);

			response = await dio.post(Constant.API_SERVER_HTTP + url, data: formData, onSendProgress: onSendProgress ?? (){});

			return response;
	    } else {
		    onError("emptyFile");
		    return null;
	    }
    }

    static commonApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
        var prefixUrl = Constant.API_SERVER_HTTP;
        logRequest(prefixUrl, method.toString(), url, setData(data));
        var response = await setHttpCallType(prefixUrl, method.toString(), url, setData(data));
        return await setResponse(response, method, url, data, prefixUrl);
    }

    static messageApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
        var prefixUrl = Constant.CHAT_SERVER_HTTP;
        logRequest(prefixUrl, method.toString(), url, setData(data));
        var response = await setHttpCallType(prefixUrl, method.toString(), url, setData(data));
        return await setResponse(response, method, url, data, prefixUrl);
    }

    static chattingApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
        var prefixUrl = Constant.CHAT_SERVER_WS;
        logRequest(prefixUrl, method.toString(), url, setData(data));
        var response = await setHttpCallType(prefixUrl, method.toString(), url, setData(data));
        return await setResponse(response, method, url, data, prefixUrl);
    }

    static setHttpCallType(prefixUrl, method, url, data) async {
        switch(method) {
            case "HTTP_METHOD.post": return await http.post(prefixUrl + url, headers: Constant.HEADER, body: jsonEncode(data));
            break;

            case "HTTP_METHOD.get": return await http.get(prefixUrl + url, headers: Constant.HEADER);
            break;

            case "HTTP_METHOD.put": return await http.put(prefixUrl + url, headers: Constant.HEADER, body: jsonEncode(data));
            break;

            case "HTTP_METHOD.patch": return await http.patch(prefixUrl + url, headers: Constant.HEADER, body: jsonEncode(data));
            break;

            case "HTTP_METHOD.delete": return await http.delete(prefixUrl + url, headers: Constant.HEADER);
            break;

            default: { developer.log("# Invalid choice http call method"); }
            break;
        }
    }
}
