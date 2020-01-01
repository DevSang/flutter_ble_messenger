import 'package:Hwa/data/models/chat_notice_reply.dart';

class SetChatNoticeReplyData {

    List<ChatNoticeReply> main() {
        List<ChatNoticeReply> chatNoticeReply = <ChatNoticeReply>[];


        chatNoticeReply = [
            ChatNoticeReply(
                userNick: "유한석",
                content: "공감합니다.",
                userImg: "assets/images/icon/profile.png",
                regTime: 1577103803377
            ),
            ChatNoticeReply(
                userNick: "김유진",
                content: "좋은 취지네요. 꼭 필요했던 규칙 입니다!! 꼭 필요하다 생각합니다.",
                userImg: "assets/images/icon/profile.png",
                regTime: 1557008503218
            )
        ];

        return chatNoticeReply;
    }
}