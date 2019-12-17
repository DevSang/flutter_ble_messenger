import 'dart:async';

import 'package:http/http.dart' as http;

ApiConfig apiConfig = new ApiConfig();

class ApiConfig{
  static const baseUrl = "http://api.hwaya.net";
  static final ApiConfig _instance = new ApiConfig._internal();

  factory ApiConfig() {
    return _instance;
  }

  ApiConfig._internal();
}

