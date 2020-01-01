import 'package:Hwa/data/models/friend_info.dart';
import 'package:Hwa/data/models/friend_request_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constant {
    //App 관련 변수
    static int USER_IDX;
    static List<FriendInfo> FRIEND_LIST;
    static List<FriendRequestInfo> FRIEND_REQUEST_LIST;
    static Map<String, String> HEADER;

    static String PROFILE_IMG_URI;

    static bool IS_CHANGE_PROFILE_IMG = false;
    static bool APP_BAR_LOADING_COMPLETE = false;
    static bool APP_BAR_LOADING_ERROR = false;

    static setUserIdx () async {
        var spf = await SharedPreferences.getInstance();
        USER_IDX = int.parse(spf.getString("userIdx"));
        PROFILE_IMG_URI = API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + USER_IDX.toString() + "&type=SMALL";
    }

    static setHeader () async {
	    var spf = await SharedPreferences.getInstance();
	    var token = spf.getString('token').toString();
	    HEADER = {
		    'Content-Type': 'application/json',
		    'X-Authorization': 'Bearer ' + token
	    };
    }

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
    static final String NICK = "HWA";
    static final String PROFILE_IMG = "assets/images/icon/profile.png";
    static final String PHONE_NUM = "010-1234-5678";
}