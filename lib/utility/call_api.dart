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
  static commonApiCall({ @required HTTP_METHOD method, @required String uri, Map data}) async {
    var responseBody = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var headers = {
      'Content-Type':'application/json',
      'x-Authorization':'Bearer ' + token
    };

    try {
      var response = setHttpCallType(method, headers, uri, data);

      if(response.statusCode == 200) {
        responseBody = json.encode(response.body);
        if(responseBody != null) {
          return response;
        } else {
          print("#No response" + json.decode(response.body));
          return false;
        }
      }
    } catch (e) {
      expect(e, isUnsupportedError);
    }
  }

  static setHttpCallType(method, headers, uri, data) async {
    switch(method) {
      case "post": return await http.post(Constant.API_SERVER_HTTP + uri, headers: headers, body: data);
      break;

      case "get": return await http.get(Constant.API_SERVER_HTTP + uri, headers: headers,);
      break;

      case "put": return await http.put(Constant.API_SERVER_HTTP + uri, headers: headers, body: data);
      break;

      case "patch": return await http.patch(Constant.API_SERVER_HTTP + uri, headers: headers, body: data);
      break;

      case "delete": return await http.delete(Constant.API_SERVER_HTTP + uri, headers: headers,);
      break;

      default: { print("Invalid choice http call method"); }
      break;
    }
  }
}
