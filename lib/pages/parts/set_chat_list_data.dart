import 'package:Hwa/data/models/chat_list_item.dart';

class SetChaListData {

    List<ChatListItem> main() {
        List<ChatListItem> chatListItem = <ChatListItem>[];


        chatListItem = [
            ChatListItem(
                chatImg: "assets/images/icon/appIcon.jpg",
                title: "코엑스 별마당 도서관",
                isPopular: true,
                count: 176,
                time: 1578156846845,
            ),
            ChatListItem(
                chatImg: "assets/images/icon/appIcon.jpg",
                title: "스타벅스 강남R점",
                isPopular: true,
                count: 56,
                time: 1577898465444,
            ),
            ChatListItem(
                chatImg: "assets/images/icon/appIcon.jpg",
                title: "교보문고 강남점",
                isPopular: false,
                count: 31,
                time: 1577564685654,
            ),
            ChatListItem(
                chatImg: "assets/images/icon/appIcon.jpg",
                title: "서초대로78길 180",
                isPopular: false,
                count: 28,
                time: 1577103803377,
            )
        ];

        return chatListItem;
    }
}