
import 'package:Hwa/data/models/chat_user_info.dart';
import 'package:Hwa/utility/cached_image_utility.dart';

class SetUserData {

    List<ChatUserInfo> main() {
        List<ChatUserInfo> userInfoList = <ChatUserInfo>[];


        userInfoList = [
            ChatUserInfo(
                nick: "강희근",
                profileImg: null,
                partType: "BLE",
                existContact: true,
                businessCard: "assets/images/businesscard.png",
                userIntro: "안녕하세요. 강희근입니다.",
                addFriend: true,
            ),
            ChatUserInfo(
                nick: "노민정",
                profileImg: null,
                partType: "BLE",
                existContact: false,
                businessCard: "",
                userIntro: ".",
                addFriend: false,
            ),
            ChatUserInfo(
                nick: "김은선",
                profileImg: null,
                partType: "BLE",
                existContact: false,
                businessCard: "assets/images/businesscard.png",
                userIntro: "안녕하세요. 강희근입니다2.",
                addFriend: true,
            ),
            ChatUserInfo(
                nick: "김재희",
                profileImg: null,
                partType: "BLE",
                existContact: true,
                businessCard: "",
                userIntro: "안녕하세요. 강희근입니다3.",
                addFriend: false,
            )
        ];



        return userInfoList;
    }
}