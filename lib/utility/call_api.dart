import 'dart:developer' as developer;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:Hwa/constant.dart';


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
    static Future<Map<String, String>> setHeader() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('token').toString();
        Map<String, String> header = {
            'Content-Type': 'application/json',
            'X-Authorization': 'Bearer ' + token
        };
        return header;
    }

    static setData(Map data) {
        if (data == null) {
            return {};
        } else {
            return data;
        }
    }

    static logRequest(String prefixUrl, method, header, url, data){
        print("#Request Url : " + url.toString());
//        print("#Method : " + method.toString());
//        print("#Headers : " + header.toString());
//        print("#Data : " + data.toString());
    }

    static setResponse(http.Response response){
        developer.log("# Response : " + response.toString());
        var statusCode = response.statusCode.toString();

        if(statusCode.indexOf("20") > -1) {
            developer.log("# Request result : " + response.body.toString());
            return response;
        } else {
            developer.log("# [Error] Status Code :" + statusCode);
            return null;
        }
    }

    /*
     * @author : hk
     * @date : 2019-12-31
     * @description : 파일업로드 API, TODO 아직 채팅방 이미지만 테스트 되어있음
     */
    static Future<Response> fileUploadCall({@required String url, @required String filePath, Map<String, dynamic> paramMap, String fileParameterName, Function onSendProgress}) async {
	    String fileName = filePath.substring(filePath.lastIndexOf("/") + 1, filePath.length);

	    SharedPreferences prefs = await SharedPreferences.getInstance();
	    var token = prefs.getString('token').toString();

	    Response response;
	    Dio dio = new Dio();
	    dio.options.headers['X-Authorization'] = 'Bearer ' + token;
	    dio.options.headers['Content-Type'] = "multipart/form-data";

	    paramMap = paramMap ?? Map<String, dynamic>();
	    fileParameterName = fileParameterName ?? "file";
	    paramMap[fileParameterName] = await MultipartFile.fromFile(filePath, filename: fileName);

	    var formData = FormData.fromMap(paramMap);

	    response = await dio.post(Constant.API_SERVER_HTTP + url, data: formData, onSendProgress: onSendProgress ?? (){});

	    return response;
    }

    static commonApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
        var prefixUrl = Constant.API_SERVER_HTTP;
        logRequest(prefixUrl, method.toString(),await setHeader(), url, setData(data));
        var response = await setHttpCallType(prefixUrl, method.toString(),await setHeader(), url, setData(data));
        return await setResponse(response);
    }

    static messageApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
        var prefixUrl = Constant.CHAT_SERVER_HTTP;
        logRequest(prefixUrl, method.toString(),await setHeader(), url, setData(data));
        var response = await setHttpCallType(prefixUrl, method.toString(),await setHeader(), url, setData(data));
        return await setResponse(response);
    }

    static chattingApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
        var prefixUrl = Constant.CHAT_SERVER_WS;
        logRequest(prefixUrl, method.toString(),await setHeader(), url, setData(data));
        var response = await setHttpCallType(prefixUrl, method.toString(),await setHeader(), url, setData(data));
        return await setResponse(response);
    }

    static setHttpCallType(prefixUrl, method, headers, url, data) async {
        switch(method) {
            case "HTTP_METHOD.post": return await http.post(prefixUrl + url, headers: headers, body: jsonEncode(data));
            break;

            case "HTTP_METHOD.get": return await http.get(prefixUrl + url, headers: headers);
            break;

            case "HTTP_METHOD.put": return await http.put(prefixUrl + url, headers: headers, body: jsonEncode(data));
            break;

            case "HTTP_METHOD.patch": return await http.patch(prefixUrl + url, headers: headers, body: jsonEncode(data));
            break;

            case "HTTP_METHOD.delete": return await http.delete(prefixUrl + url, headers: headers);
            break;

            default: { developer.log("# Invalid choice http call method"); }
            break;
        }
    }
}
