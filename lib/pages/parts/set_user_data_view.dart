
import 'package:Hwa/data/models/chat_user_info.dart';

class SetUserDataView {

    List<ChatUserInfo> main() {
        List<ChatUserInfo> userInfoList = <ChatUserInfo>[];


        userInfoList = [
            ChatUserInfo(
                nick: "노희진",
                profileImg: null,
                partType: "View",
                existContact: true,
                businessCard: "assets/images/businesscard.png",
                userIntro: "안녕하세요. 강희근입니다.",
                addFriend: true,
                isHost: false,
                isMe: false
            ),
            ChatUserInfo(
                nick: "안영후",
                profileImg: null,
                partType: "View",
                existContact: false,
                businessCard: "assets/images/businesscard.png",
                userIntro: "안녕하세요. 강희근입니다2.",
                addFriend: true,
                isHost: false,
                isMe: false
            )
        ];



        return userInfoList;
    }
}