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
  static commonApiCall({ @required HTTP_METHOD method, @required String url, Map data}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(data == null) {
        data = {};
    }
    var token = prefs.getString('token').toString();
    var headers = {
      'Content-Type':'application/json',
      'X-Authorization':'Bearer ' + token
    };

    try {
      var response = setHttpCallType(method.toString(), headers, url, data);
      print("#Request Url : " + url.toString());
      print("#Method : " + method.toString());
      print("#Headers : " + headers.toString());
      print("#Data : " + data.toString());

      return response;
//      var statusCode = response.statusCode.toString();
//      if(statusCode.indexOf("20") > -1) {
//        responseBody = json.encode(response.body);
//        if(responseBody != null) {
//          return response;
//        } else {
//          print("#No response" + json.decode(response.body));
//          return false;
//        }
//      }
    } catch (e) {
      expect(e, isUnsupportedError);
    }
  }

  static setHttpCallType(method, headers, url, data) async {
    switch(method) {
      case "HTTP_METHOD.post": return await http.post(Constant.API_SERVER_HTTP + url, headers: headers, body: jsonEncode(data));
      break;

      case "HTTP_METHOD.get": return await http.get(Constant.API_SERVER_HTTP + url, headers: headers,);
      break;

      case "HTTP_METHOD.put": return await http.put(Constant.API_SERVER_HTTP + url, headers: headers, body: data);
      break;

      case "HTTP_METHOD.patch": return await http.patch(Constant.API_SERVER_HTTP + url, headers: headers, body: data);
      break;

      case "HTTP_METHOD.delete": return await http.delete(Constant.API_SERVER_HTTP + url, headers: headers,);
      break;

      default: { print("Invalid choice http call method"); }
      break;
    }
  }
}
