import 'package:Hwa/data/models/chat_user_info.dart';

class SetUserDataOnline {

    List<ChatUserInfo> main() {
        List<ChatUserInfo> userInfoList = <ChatUserInfo>[];


        userInfoList = [
            ChatUserInfo(
                nick: "나영희",
                profileImg: null,
                partType: "Online",
                existContact: true,
                businessCard: "assets/images/businesscard.png",
                userIntro: "안녕하세요. 강희근입니다.",
                addFriend: true,
                isHost: false,
                isMe: false
            ),
            ChatUserInfo(
                nick: "김영서",
                profileImg: null,
                partType: "Online",
                existContact: false,
                businessCard: "",
                userIntro: ".",
                addFriend: false,
                isHost: false,
                isMe: false
            ),
            ChatUserInfo(
                nick: "뱍지원",
                profileImg: null,
                partType: "Online",
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