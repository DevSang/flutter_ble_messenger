import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

// sharedpreference 데이터 저장

SharedPrefsHelper prefsHelper = new SharedPrefsHelper();

class SharedPrefsHelper {
  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();

  SharedPreferences _prefs;
  
  final String PREFS_TOKEN = "TOKEN";
  final String PREFS_IS_LOGIN = "ISLOGIN";


  set token(value) => _prefs.setString(PREFS_TOKEN, value);

  get token => _prefs.getString(PREFS_TOKEN);

  set isLogin(value) => _prefs.setBool(PREFS_IS_LOGIN, value);

  get isLogin => _prefs.getBool(PREFS_IS_LOGIN) ?? false;

  factory SharedPrefsHelper() {
    return _instance;
  }

  SharedPrefsHelper._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    return 0;
  }

  void checkIsInitialize() {
    assert(_prefs != null, "Shared Prefs를 사용하기 전에 prefsHelper.initialize를 먼저 호출하세요");
  }

  void clear() {
    _prefs.clear();
  }
}
