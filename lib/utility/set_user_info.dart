import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:Hwa/data/models/UserInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-24
 * @description : Set user info when signin, signup
 */

class SetUserInfo {

    /*
    * @author : sh
    * @date : 2019-12-29
    * @description : Set user info when signin, signup
    */
    static set(Map info, String profileUrl) async{
        SharedPreferences SPF = await SharedPreferences.getInstance();
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
        SPF.setString("userInfo", userInfoEncode);
        developer.log("# userInfo is saved in SPF.");
        developer.log("# userInfo" + userInfo.toJson().toString());


        //Usage
//        SharedPreferences SPF2 = await SharedPreferences.getInstance();
//        Map<String, dynamic> userMap = jsonDecode(SPF2.getString('userInfo'));
//        print(userMap['userIdx']);

    }
}
