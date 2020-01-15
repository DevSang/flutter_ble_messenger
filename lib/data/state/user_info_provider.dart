import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:Hwa/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';


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
    String profileURL;
    int profilePictureIdx;
    String nickname;
    String description;
    String countryCode;
    CachedNetworkImage cacheProfileImg;

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
        ,this.countryCode
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
            String token = userInfo['token'];
            setValue(userInfo);

            ///Constant 설정
            Constant.USER_IDX = idx;
            if(idx != null && token != null) Constant.isUserLogin = true;
            Constant.HEADER = {
                'Content-Type': 'application/json',
                'X-Authorization': 'Bearer ' + token
            };

            if(profileURL == null && profilePictureIdx != null){
	            profileURL = Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + Constant.USER_IDX.toString() + "&type=SMALL";
            }

            // 사용자 Cache 프로필 이미지 생성
            createProfileCacheImg();

            developer.log("# userInfo is loaded from SPF.");
            developer.log("# userInfo : " + jsonDecode(spf.getString('userInfo')).toString());
            developer.log("# userIdx : " + idx.toString());
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
        this.profilePictureIdx =  info['jb_user_info']['profile_picture_idx'];
        this.profileURL =  info['profileURL'];
        this.nickname =  info['jb_user_info']['nickname'];
        this.description =  info['jb_user_info']['description'];
        this.countryCode =  info['country_code'];
    }

    /*
     * @author : hs
     * @date : 2020-01-14
     * @description : 사용자 프로필 정보 변경
    */
    setProfile(Map profileInfo) {
        this.updateTs  = profileInfo['updateTs'];
        this.nickname =  profileInfo['nickname'];
        this.description =  profileInfo['description'];

        notifyListeners();
    }

    /*
     * @author : hk
     * @date : 2020-01-10
     * @description : 사용자 프로필 이미지 return, 없으면 기본 이미지
     */
    Widget getUserProfileImg() {
    	return cacheProfileImg ?? Image.asset('assets/images/icon/profile.png', fit: BoxFit.cover);
    }

    /*
     * @author : hs
     * @date : 2020-01-14
     * @description : 사용자 프로필 이미지 Url return, 없어도 기본 이미지 반환 X
    */
    Widget getUserProfileImgNotDefault() {
        return cacheProfileImg;
    }

    /*
     * @author : hk
     * @date : 2020-01-10
     * @description : 사용자 Cache 프로필 이미지 생성
     */
    void createProfileCacheImg() {
        if(profileURL != null){
		    cacheProfileImg = CachedNetworkImage(
                imageUrl: profileURL,
                errorWidget: (context, url, error) => Image.asset('assets/images/icon/profile.png', fit: BoxFit.cover),
                httpHeaders: Constant.HEADER,
                fit: BoxFit.cover,
		    );
		    notifyListeners();
	    }
    }

    /*
     * @author : hs
     * @date : 2020-01-14
     * @description : 사용자 이미지 업로드 및 Cache 생성
     */
    void uploadAndCreateProfileCacheImg() {
        profileURL = Constant.getUserProfileImgUriOrigin(idx);

        if(profileURL != null){
            cacheProfileImg = CachedNetworkImage(
                imageUrl: profileURL,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Image.asset('assets/images/icon/profile.png', fit: BoxFit.cover),
                httpHeaders: Constant.HEADER,
                fit: BoxFit.cover,
            );
            notifyListeners();
        }
    }

    /*
     * @author : hk
     * @date : 2020-01-10
     * @description : 사용자 프로필 이미지 변경되어 cache expire 시키기
     */
    Future<void> changedProfileImg() async {
	    await DefaultCacheManager().removeFile(profileURL);
	    notifyListeners();
    }
}
