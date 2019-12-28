import 'package:Hwa/data/models/chat_list_item.dart';

class SetChaListData {

    List<ChatListItem> main() {
        List<ChatListItem> chatListItem = <ChatListItem>[];


        chatListItem = [
            ChatListItem(
                chatImg: "assets/images/icon/appIcon.jpg",
                title: "코엑스 별마당 도서관",
            ),
            ChatListItem(
                chatImg: "assets/images/icon/appIcon.jpg",
                title: "스타벅스 강남R점",
            ),
            ChatListItem(
                chatImg: "assets/images/icon/appIcon.jpg",
                title: "교보문고 강남점",
            ),
            ChatListItem(
                chatImg: "assets/images/icon/appIcon.jpg",
                title: "서초대로78길 180",
            )
        ];

        return chatListItem;
    }
}