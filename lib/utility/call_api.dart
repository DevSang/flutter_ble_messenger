import 'package:Hwa/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-24
 * @description : Call api utility
 *              - return : response(No Json encode) || Error
 */
class CallApi {
  static commonApiCall(Map data, uri, method) async {
    var responseBody = null;
    try {
      var response = setHttpCallType(method, uri, data);

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

  static setHttpCallType(method, uri, data) async {
    switch(method) {
      case "post": return await http.post(Constant.API_SERVER_HTTP + uri, body: data);
      break;

      case "get": return await http.get(Constant.API_SERVER_HTTP + uri);
      break;

      case "put": return await http.put(Constant.API_SERVER_HTTP + uri, body: data);
      break;

      case "patch": return await http.patch(Constant.API_SERVER_HTTP + uri, body: data);
      break;

      case "delete": return await http.delete(Constant.API_SERVER_HTTP + uri);
      break;

      default: { print("Invalid choice http call method"); }
      break;
    }
  }
}
