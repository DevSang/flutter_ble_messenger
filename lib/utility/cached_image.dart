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
class CachedImage {
  static commonApiCall(Map data, uri) async {
    var responseBody = null;
    try {
      var response = await http.post(Constant.API_SERVER_HTTP + uri, body: data);

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
}
