import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kvsql/kvsql.dart';
import 'package:contacts_service/contacts_service.dart';

import 'package:Hwa/constant.dart';
import 'package:Hwa/pages/signin/signin_page.dart';
import 'package:Hwa/pages/parts/common/bottom_navigation.dart';
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:Hwa/data/state/friend_list_info_provider.dart';
import 'package:Hwa/data/state/friend_request_list_info_provider.dart';

// KV Store 전역 선언
final kvStore = KvStore();

/*
 * @project : HWA - Mobile
 * @author : hk
 * @date : 2020-01-05
 * @description : 메인 페이지, main.dart 에서 Home 으로 지정
 */
class HomePage extends StatefulWidget {
    @override
    HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
    UserInfoProvider userInfoProvider;

    SharedPreferences _sharedPreferences;
    final int startTs = new DateTime.now().millisecondsSinceEpoch;
    // Splash screen Time (ms)
    final int splashTime = 1500;

    @override
    void initState() {
        userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);

        initApp(context);
        super.initState();
    }

    /*
     * @author : hk
     * @date : 2020-01-05
     * @description : initialize App
     */
    void initApp(BuildContext context) async {
        //TODO 연락처 연동 예제
//        Iterable<Contact> johns = await ContactsService.getContacts(query : "상혁");
//        developer.log("####" + johns.toList()[0].displayName.toString());
//        developer.log("####" + johns.toList()[0].phones.toList()[0].value.toString());


        // spf, kvStore init 후 로직 진행, 뒤에서 spf, kvStore 다시 얻기 불필요
	    _sharedPreferences = await Constant.getSPF();
	    await kvStore.onReady;

	    // 사용자 로그인 여부 판별 및 사용자 정보 셋팅
        await userInfoProvider.getUserInfoFromSPF();

	    // 로그인된 사용자 처리
	    if(Constant.isUserLogin){
		    await initApiCall(context); // TODO 부하증가에 따라 API 호출 시간이 너무 길어질 경우 어떻게 할것인가?
	    }

	    // App 초기화 및 사용자 정보 셋팅 시간 측정, 1.5초 미만이면 1.5초를 채운 후 화면 이동
	    int now = new DateTime.now().millisecondsSinceEpoch;
	    int delayedTime = now - startTs;
	    int requiredDelayTime = now - startTs > splashTime ? 0 : splashTime - delayedTime;

	    new Future.delayed(
		    Duration(milliseconds: requiredDelayTime),
			    // 사용자 상태에 따른 페이지 이동
			    () => startPageMove()
	    );
    }

    /*
    * @author : sh
    * @date : 2019-12-28
    * @description : 사용자에게 필요한 정보 및 필수 API 미리 호출, TODO JWT 토큰 - 서버와 통신해서 만료되었는지, 유효한지, 만료면 Refresh 로직
    */
    static Future<void> initApiCall (BuildContext context) async {

        FriendListInfoProvider friendListProvider = Provider.of<FriendListInfoProvider>(context, listen: false);
        FriendRequestListInfoProvider friendRequestListInfoProvider = Provider.of<FriendRequestListInfoProvider>(context, listen: false);

        await friendListProvider.getFriendList();
        await friendRequestListInfoProvider.getFriendRequestList();
        return;
    }


    /*
    * @author : sh
    * @date : 2019-12-28
    * @description : 사용자 로그인 상태 -> main, 아니면 Signin으로 navigate
    */
    void startPageMove() {
        if(Constant.isUserLogin) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => BottomNavigation()), (Route<dynamic> route) => false);
        else Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => SignInPage()), (Route<dynamic> route) => false);
    }

    /*
     * UI Widget - Splash
     */
    @override
    Widget build(BuildContext context) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark
        ));

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