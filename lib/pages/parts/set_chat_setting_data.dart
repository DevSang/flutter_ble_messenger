
import 'package:Hwa/data/models/chat_setting.dart';
import 'package:Hwa/utility/cached_image_utility.dart';

class SetChatSettingData {

    ChatSetting main() {
        ChatSetting chatSetting;

        chatSetting = ChatSetting(
            chatImg: "assets/images/visualImageLogin.png",
            title: "코엑스 별마당 도서관",
            intro: "단화방을 소개해 보세요",
            isPublic: true,
            inviteRange: 2,
            mode: 1,
        );

        return chatSetting;
    }
}