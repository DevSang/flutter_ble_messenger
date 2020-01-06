import 'package:Hwa/data/models/friend_info.dart';
import 'package:Hwa/data/models/friend_request_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
	static bool isUserLogin = false;

    static int USER_IDX;
    static List<FriendInfo> FRIEND_LIST;
    static List<FriendRequestInfo> FRIEND_REQUEST_LIST;
    static Map<String, String> HEADER;

    static String PROFILE_IMG_URI;

    // 프로필 이미지 및 App bar 상태 관련, TODO 리팩터링 예정
    static bool IS_PROFILE_IMG = false;
    static bool IS_CHANGE_PROFILE_IMG = false;
    static bool APP_BAR_LOADING_COMPLETE = false;
    static bool APP_BAR_LOADING_ERROR = false;

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
	 * @date : 2020-01-05
	 * @description : 사용자 로그인 여부 판별 및 기본정보 메모리로 올리기
	 */
    static Future<void> initUserInfo() async {
    	spf = await getSPF();
	    USER_IDX = spf.getInt("userIdx");
	    String token = spf.getString('token').toString();

	    if(USER_IDX != null && token != null) isUserLogin = true;

	    if(isUserLogin){
		    PROFILE_IMG_URI = API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + USER_IDX.toString() + "&type=SMALL";

		    // Http API 호출시 붙는 기본 Header, JWT 토큰 포함
		    HEADER = {
			    'Content-Type': 'application/json',
			    'X-Authorization': 'Bearer ' + token
		    };
	    }

	    return;
    }
}