import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:core';
import 'package:Hwa/pages/signin_page.dart';
import 'package:Hwa/pages/bottom_navigation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kvsql/kvsql.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/utility/call_api.dart';
import 'dart:convert';

final store = KvStore();
class MainPage extends StatefulWidget {
    @override
    _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
    SharedPreferences sharedPreferences;
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    @override
    void initState() {
        //Constant init
        Constant.setUserIdx();
        //Check local store and call init api
        checkLocalStore();
        //get Firebase push token
        firebaseCloudMessaging_Listeners();

        new Future.delayed(
            const Duration(seconds: 3),
                () => checkLoginStatus()
        );

        super.initState();
    }

    /*
    * @author : sh
    * @date : 2019-12-28
    * @description : Test를 위해 store, sharedpreference를 비움
    */
    clearLocalStorageForTest () async {
        await store.onReady;
        sharedPreferences.remove('token');
        store.delete("friendList");
        store.delete("test");
    }

    /*
    * @author : sh
    * @date : 2019-12-28
    * @description : Api를 call해서 store에 저장할지 안할지 구분
    */
    checkLocalStore () async {
        await store.onReady;
        bool isNeedCallApi = await store.count() == 0 ? true : false;
        if( isNeedCallApi ){
            getFriendList();
        }
    }

    /*
    * @author : sh
    * @date : 2019-12-28
    * @description : 친구목록이 Store에 없을 경우 api call 하여 저장
    */
    getFriendList () async {
        String uri = "/api/v2/relation/relationship?user_idx=" + Constant.USER_IDX.toString();
        final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);
        if(response.body != null){
            await store.put<List<dynamic>>("friendList",jsonDecode(response.body)['data']);
        } else {
            await store.put<List<dynamic>>("friendList",[]);
        }

        var myValue = await store.select<List<dynamic>>("friendList");
        print("#Friend List"+ myValue.toString());
    }

    /*
    * @author : sh
    * @date : 2019-12-28
    * @description : 유저가 JWT토큰을 갖고있으면 main으로, 없으면, Signin으로 navigate
    */
    checkLoginStatus() async {
        sharedPreferences = await SharedPreferences.getInstance();

        var token = sharedPreferences.getString("token");
        var userIdx = sharedPreferences.getString("userIdx");
        print("Token : " + token.toString());
        print("userIdx : " + userIdx.toString());

        if(sharedPreferences.getString("token") == null) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => SignInPage()), (Route<dynamic> route) => false);
        }
        else {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => BottomNavigation()), (Route<dynamic> route) => false);
        }
    }

    /*
    * @author : hk
    * @date : 2019-12-21
    * @description : FCM 수신 테스트 코드 삽입, TODO 소스코드 적용, MSG 혹은 API서버 - token 저장 api 연동
    */
    void firebaseCloudMessaging_Listeners() async {
        sharedPreferences = await SharedPreferences.getInstance();

        if (Platform.isIOS) iOS_Permission();
            _firebaseMessaging.getToken().then((token) {
                print('# FCM : token:' + token);
                sharedPreferences.setString('pushToken', token);
        });

        _firebaseMessaging.configure(
            onMessage: (Map<String, dynamic> message) async {
                print('on message $message');
            },
            onResume: (Map<String, dynamic> message) async {
                print('on resume $message');
            },
            onLaunch: (Map<String, dynamic> message) async {
                print('on launch $message');
            },
        );
    }

    /*
    * @author : hk
    * @date : 2019-12-21
    * @description : FCM 수신 테스트 코드 삽입, TODO 소스코드 적용
    */
    void iOS_Permission() {
        _firebaseMessaging.requestNotificationPermissions(
            IosNotificationSettings(sound: true, badge: true, alert: true));
        _firebaseMessaging.onIosSettingsRegistered
            .listen((IosNotificationSettings settings) {
                print("Settings registered: $settings");
        });
    }


    @override
    Widget build(BuildContext context) {
        SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.white,
            )
        );

        ScreenUtil.instance = ScreenUtil(width: 375, height: 667, allowFontScaling: true)..init(context);

        return Scaffold(
            body: Container(
                width: ScreenUtil().setWidth(375),
                height: ScreenUtil().setHeight(667),
                color: Colors.black,
                child:Image.asset(
                    "assets/images/splash.png",
                    fit: BoxFit.cover,
                ),
            ),
        );
    }
}
