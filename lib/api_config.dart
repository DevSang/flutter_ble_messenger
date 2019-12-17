import 'dart:async';

import 'package:http/http.dart' as http;

ApiConfig apiConfig = new ApiConfig();

class ApiConfig{
  static const baseUrl = "https://127.0.0.1:3000";
  static final ApiConfig _instance = new ApiConfig._internal();

  factory ApiConfig() {
    return _instance;
  }

  ApiConfig._internal();
}

