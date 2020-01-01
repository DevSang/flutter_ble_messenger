import 'package:Hwa/data/models/chat_notice_item.dart';

class SetChatNoticeData {

    List<ChatNoticeItem> main() {
        List<ChatNoticeItem> chatNoticeItem = <ChatNoticeItem>[];


        chatNoticeItem = [
            ChatNoticeItem(
                content: "타인을 향한 비방시 강퇴 조치를 취합니다.",
                userImg: "assets/images/icon/profile.png",
                regTime: 1577103803377,
                replyCount: 2,
            ),
            ChatNoticeItem(
                content: "10대/20대 수다방입니다. \n30대 이상은 참여할 수 없습니다 :(",
                userImg: "assets/images/icon/profile.png",
                regTime: 1557008503218,
                replyCount: 5,
            ),
            ChatNoticeItem(
                content: "타인을 향한 비방시 강퇴 조치를 취합니다.",
                userImg: "assets/images/icon/profile.png",
                regTime: 1518113312415,
                replyCount: 2,
            )
        ];

        return chatNoticeItem;
    }
}