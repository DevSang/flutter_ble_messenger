import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kvsql/kvsql.dart';

import 'package:Hwa/data/models/friend_info.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/pages/signin/signin_page.dart';
import 'package:Hwa/pages/parts/common/bottom_navigation.dart';
import 'package:Hwa/data/state/user_info_provider.dart';

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

        initApp();
        super.initState();
    }

    /*
     * @author : hk
     * @date : 2020-01-05
     * @description : initialize App
     */
    void initApp() async {

        // spf, kvStore init 후 로직 진행, 뒤에서 spf, kvStore 다시 얻기 불필요
	    _sharedPreferences = await Constant.getSPF();
	    await kvStore.onReady;

	    // 사용자 로그인 여부 판별 및 사용자 정보 셋팅
        await userInfoProvider.getUserInfoFromSPF();

	    // 로그인된 사용자 처리
	    if(Constant.isUserLogin){
		    await initApiCall(); // TODO 부하증가에 따라 API 호출 시간이 너무 길어질 경우 어떻게 할것인가?
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
    static Future<void> initApiCall () async {
        await getFriendList();
        return;
    }

    /*
    * @author : sh
    * @date : 2019-12-28
    * @description : 친구목록이 Store에 없을 경우 api call 하여 저장
    */
    static Future<void> getFriendList () async {
        List<FriendInfo> friendInfoList = <FriendInfo>[];

        String uri = "/api/v2/relation/relationship/all";
        final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);

        if(response != null ? true : false){
            List<dynamic> friendList = jsonDecode(response.body)['data'];

            for(var i = 0; i < friendList.length; i++){
                var friendInfo = friendList[i]['related_user_data'];

                friendInfoList.add(
                    FriendInfo(
                        user_idx: friendInfo['user_idx'],
                        nickname: friendInfo['nickname'],
                        phone_number: friendInfo['phone_number'],
                        profile_picture_idx: friendInfo['profile_picture_idx'],
                        business_card_idx: friendInfo['business_card_idx'],
                        user_status: friendInfo['user_status'],
                        description: friendInfo['description']
                    )
                );
            }
            Constant.FRIEND_LIST = friendInfoList;
        } else {
            Constant.FRIEND_LIST = [];
        }

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