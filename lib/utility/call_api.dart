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

    static setResponse(http.Response response){
        var statusCode = response.statusCode.toString();

        if(statusCode.indexOf("20") > -1) {
            return response;
        } else {
            developer.log("# [Error] Status Code :" + statusCode);
            return null;
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
        return await setResponse(response);
    }

    static messageApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
        var prefixUrl = Constant.CHAT_SERVER_HTTP;
        logRequest(prefixUrl, method.toString(), url, setData(data));
        var response = await setHttpCallType(prefixUrl, method.toString(), url, setData(data));
        return await setResponse(response);
    }

    static chattingApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
        var prefixUrl = Constant.CHAT_SERVER_WS;
        logRequest(prefixUrl, method.toString(), url, setData(data));
        var response = await setHttpCallType(prefixUrl, method.toString(), url, setData(data));
        return await setResponse(response);
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
