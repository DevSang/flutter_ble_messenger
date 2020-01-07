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

class UserInfo with ChangeNotifier{
    int userIdx;
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


    UserInfo({
        this.userIdx
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
    });

    factory UserInfo.fromJSON (Map<String, dynamic> json) {
        return UserInfo (
            userIdx : json['userIdx'] ?? "",
            phoneNumber : json['phoneNumber'] ?? "",
            authNumber : json['authNumber'] ?? "",
            socialCd : json['socialCd'] ?? "",
            socialId : json['socialId'] ?? "",
            loginFailCnt : json['loginFailCnt'] ?? "",
            isLock : json['isLock'] ?? "",
            lastLoginTs : json['lastLoginTs'] ?? "",
            userStatus : json['userStatus'] ?? "",
            regTs : json['regTs'] ?? "",
            updateTs : json['updateTs'] ?? "",
            profileURL : json['profileURL'] ?? "",
        );
    }

    Map<String, dynamic> toJson() =>
    {
        "userIdx" : userIdx,
        "phoneNumber" : phoneNumber,
        "authNumber" : authNumber,
        "socialCd" : socialCd,
        "socialId" : socialId,
        "loginFailCnt" : loginFailCnt,
        "isLock" : isLock,
        "lastLoginTs" : lastLoginTs,
        "userStatus" : userStatus,
        "regTs" : regTs,
        "updateTs" : updateTs,
        "profileURL" : profileURL,
    };

    /*
	 * @author : sh
	 * @date : 2020-01-07
	 * @description : 사용자 로그인 여부 판별 및 기본정보 메모리로 올리기
	 */
    Future<void> setStateAndSaveUserInfoAtSPF(Map info, String profileUrl) async {
        SharedPreferences spf = await Constant.getSPF();

        UserInfo userInfo = UserInfo(
            userIdx:info['idx'],
            phoneNumber: info['phone_number'],
            userStatus: info['user_status'],
            socialCd : info['social_cd'],
            socialId : info['social_id'],
            loginFailCnt : info['login_fail_cnt'],
            isLock : info['is_lock'],
            lastLoginTs : info['last_login_ts'],
            regTs : info['reg_ts'],
            updateTs : info['update_ts'],
            profileURL: profileUrl
        );
        var userInfoEncode = jsonEncode(userInfo.toJson());
        spf.setString("userInfo", userInfoEncode);
        developer.log("# userInfo is saved in SPF.");
        developer.log("# userInfo" + userInfo.toJson().toString());

        notifyListeners();

        //Usage
//        SharedPreferences SPF2 = await SharedPreferences.getInstance();
//        Map<String, dynamic> userMap = jsonDecode(SPF2.getString('userInfo'));
//        developer.log(userMap['userIdx']);

    }
}
