import 'dart:io';

import 'package:Hwa/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    static setHeader() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('token').toString();
        var header = {
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
        print("#Method : " + method.toString());
        print("#Headers : " + header.toString());
        print("#Data : " + data.toString());
    }

    static setResponse(http.Response response){
        print("#response : " + response.toString());
        var statusCode = response.statusCode.toString();

        if(statusCode.indexOf("20") > -1) {
            print("#Request result : " + response.body.toString());
            return response;
        } else {
            print("#[Error] Status Code :" + statusCode);
            return null;
        }
    }

    static commonApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
        var prefixUrl = Constant.API_SERVER_HTTP;
        logRequest(prefixUrl, method.toString(), setHeader(), url, setData(data));
        var response = await setHttpCallType(prefixUrl, method.toString(), setHeader(), url, setData(data));
        return await setResponse(response);
    }

    static messageApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
        var prefixUrl = Constant.CHAT_SERVER_HTTP;
        logRequest(prefixUrl, method.toString(), setHeader(), url, setData(data));
        var response = await setHttpCallType(prefixUrl, method.toString(), setHeader(), url, setData(data));
        return await setResponse(response);
    }

    static chattingApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
        var prefixUrl = Constant.CHAT_SERVER_WS;
        logRequest(prefixUrl, method.toString(), setHeader(), url, setData(data));
        var response = await setHttpCallType(prefixUrl, method.toString(), setHeader(), url, setData(data));
        return await setResponse(response);
    }

    static setHttpCallType(String prefixUrl, method, headers, url, Map data) async {
        switch(method) {
            case "HTTP_METHOD.post": return await http.post(prefixUrl + url, headers: headers, body: data);
            break;

            case "HTTP_METHOD.get": return await http.get(prefixUrl + url, headers: headers,);
            break;

            case "HTTP_METHOD.put": return await http.put(prefixUrl + url, headers: headers, body: data);
            break;

            case "HTTP_METHOD.patch": return await http.patch(prefixUrl + url, headers: headers, body: data);
            break;

            case "HTTP_METHOD.delete": return await http.delete(prefixUrl + url, headers: headers);
            break;

            default: { print("Invalid choice http call method"); }
            break;
        }
    }
}
