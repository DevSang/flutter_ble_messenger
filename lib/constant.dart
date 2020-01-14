import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Hwa/data/state/user_info_provider.dart';


/*
 * @project : HWA - Mobile
 * @author : hk
 * @date : 2020-01-05
 * @description : 프로젝트 상수, 전역변수 정의
 */
class Constant {

	/*
	 * 상수 영역
	 */

	// 사용자 로그인 여부
    static int USER_IDX;
	static bool isUserLogin = false;

    static Map<String, String> HEADER;

    // file upload max size (byte)
	static int MAX_FILE_SIZE = 31457280;

    // SPF
    static SharedPreferences spf;

    /// API 관련 변수
    static final String API_SERVER_HTTP = "https://api.hwaya.net";

    /// Stomp 관련 변수
    static final String CHAT_SERVER_WS = "wss://msg.hwaya.net/danhwa";
    static final String CHAT_SERVER_HTTP = "https://msg.hwaya.net";

    // 단화방 생성
    static final String CHAT_CREATE_URI = "/room";

    // 메세지 구독 (Subscribe)
    static final String CHAT_SUB_URI = "/sub/danhwa";

    // 메세지 전송 (Publish)
    static final String CHAT_PUB_URI = "/pub/danhwa";

    /// 유저 정보 관련 변수 (추후 변경)
    static final String PROFILE_DEFAULT_IMG = "assets/images/icon/profile.png";


    /*
     * 함수 영역
     */

	/*
     * @author : hk
     * @date : 2020-01-05
     * @description : get SharedPreferences
     */
	static Future<SharedPreferences> getSPF() async {
		if(spf == null) spf = await SharedPreferences.getInstance();
		return spf;
	}
	
	/*
	 * @author : hk
	 * @date : 2020-01-10
	 * @description : 사용자 프로필 이미지 경로 얻기
	 */
	static String getUserProfileImgUriSmall(int userIdx) {
		if(userIdx != null) return API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + userIdx.toString() + "&type=SMALL";
		else return null;
	}

    /*
	 * @author : hs
	 * @date : 2020-01-10
	 * @description : 사용자 프로필 이미지 경로 얻기
	 */
    static String getUserProfileImgUriOrigin(int userIdx) {
        if(userIdx != null) return API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + userIdx.toString() + "&type=BIG";
        else return null;
    }

}