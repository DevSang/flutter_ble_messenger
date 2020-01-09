import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:Hwa/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';


/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-30
 * @description : UserInfo model
 */

class UserInfoProvider with ChangeNotifier{
    int idx;
    String phoneNumber;
    String authNumber;
    String socialCd;
    String socialId;
    int loginFailCnt;
    bool isLock;
    String lastLoginTs;
    String userStatus;
    String regTs;
    String updateTs;
    //Todo : file upload해서 사용할것
    String profileURL;
    String nickname;
    String token;

    setUserInfo(dynamic value) {
        notifyListeners();
    }

    UserInfoProvider({
        this.idx
        ,this.phoneNumber
        ,this.authNumber
        ,this.socialCd
        ,this.socialId
        ,this.loginFailCnt
        ,this.isLock
        ,this.lastLoginTs
        ,this.userStatus
        ,this.regTs
        ,this.updateTs
        ,this.profileURL
        ,this.nickname
        ,this.token
    });

    /*
	 * @author : sh
	 * @date : 2020-01-07
	 * @description : 사용자 정보 받아 SPF에 저장
	 */
    Future<void> setStateAndSaveUserInfoAtSPF(Map info) async {
        SharedPreferences spf = await Constant.getSPF();

        setValue(info);
        spf.setString("userInfo", jsonEncode(info));
        notifyListeners();

        developer.log("# userInfo is saved in SPF.");
        developer.log("# userInfo" + jsonEncode(info).toString());
    }

    /*
	 * @author : sh
	 * @date : 2020-01-07
	 * @description : 사용자 정보 받아 SPF에서 받아와 셋팅
	 */
    Future<void> getUserInfoFromSPF() async {
        SharedPreferences spf = await Constant.getSPF();

        if(spf.getString('userInfo') != null) {
            Map userInfo = jsonDecode(spf.getString('userInfo'));

            setValue(userInfo);

            ///Constant 설정
            Constant.USER_IDX= idx;
            if(idx != null && token != null) Constant.isUserLogin = true;
            Constant.HEADER = {
                'Content-Type': 'application/json',
                'X-Authorization': 'Bearer ' + token
            };

            bool IS_UPLOAD_PROFILE_IMG = spf.getBool("IS_UPLOAD_PROFILE_IMG");
            if(IS_UPLOAD_PROFILE_IMG){
                profileURL = Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + Constant.USER_IDX.toString() + "&type=SMALL";
            }

            notifyListeners();

            developer.log("# userInfo is loaded from SPF.");
            developer.log("# userInfo : " + jsonDecode(spf.getString('userInfo')).toString());
            developer.log("# userIdx : " + idx.toString());
            developer.log("# token : " + token);
        }
    }

    setValue(Map info) {
        this.idx = info['idx'];
        this.phoneNumber = info['phone_number'];
        this.userStatus = info['user_status'];
        this.socialCd  = info['social_cd'];
        this.socialId  = info['social_id'];
        this.loginFailCnt  = info['login_fail_cnt'];
        this.isLock  = info['is_lock'];
        this.lastLoginTs  = info['last_login_ts'];
        this.regTs  = info['reg_ts'];
        this.updateTs  = info['update_ts'];
        this.profileURL =  info['profileURL'] ?? "";
        this.nickname =  info['nickname'];
        this.token =  info['token'];
    }

}
