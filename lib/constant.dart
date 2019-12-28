import 'package:Hwa/data/models/friend_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constant {
    //App 관련 변수
    static int USER_IDX;
    static List<FriendInfo> FRIEND_LIST;

    static setUserIdx () async {
        var spf = await SharedPreferences.getInstance();
        USER_IDX = int.parse(spf.getString("userIdx"));
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
    static final String PROFILE_IMG = "assets/images/icon/photoProfileDefault.png";
    static final String PHONE_NUM = "010-1234-5678";
}