import 'dart:io';

import 'package:Hwa/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_kakao_login/flutter_kakao_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-24
 * @description : Social login
 */
enum SocialType {
    kakao,
    facebook,
    google
}

class SocialSign {
//    FlutterKakaoLogin kakaoSignIn = new FlutterKakaoLogin();
    /*
    * @author : sh
    * @date : 2019-12-29
    * @description : Social signin, signup about KaKao
    */
    kakaoSign () async {
//        final KakaoLoginResult result = await kakaoSignIn.logIn();
//
//        switch (result.status) {
//            case KakaoLoginStatus.loggedIn:
//                print('LoggedIn by the user.\n'
//                    '- UserID is ${result.account.userID}\n'
//                    '- UserEmail is ${result.account.userEmail} ');
//                    final KakaoAccessToken accessToken = await (kakaoSignIn.currentAccessToken);
//                    if (accessToken != null) {
//                        final token = accessToken.token;
//                        return token;
//                    }
//                break;
//
//            case KakaoLoginStatus.loggedOut:
//                print('LoggedOut by the user.');
//                break;
//
//            case KakaoLoginStatus.error:
//                print('This is Kakao error message : ${result.errorMessage}');
//                return result.errorMessage;
//                break;
//        }
    }


    /*
    * @author : sh
    * @date : 2019-12-29
    * @description : Social signin, signup about Google
    */

}
