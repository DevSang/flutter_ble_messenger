import 'package:Hwa/data/models/chat_count_user.dart';
import 'package:Hwa/data/models/chat_message.dart';

class ChatListItem {
    final int chatIdx;
    final String chatImg;
    final String title;
    double lat;					// 위도
    double lon;					// 경도
    double score;               // 랭킹 점수
    ChatMessage lastMsg;		// 마지막 메시지
    ChatCountUser userCount;	// 참여 사용자 수

    ChatListItem({
        this.chatIdx,
        this.chatImg,
        this.title,
        this.lat,
        this.lon,
        this.score,
        this.lastMsg,
        this.userCount
    });

    factory ChatListItem.fromJSON (Map<String, dynamic> jsonData) {
        return ChatListItem (
            chatIdx : jsonData['roomIdx'],
            chatImg : jsonData['title'] ?? "단화방 제목입니다.",
            title : jsonData['roomImg'] ?? "assets/images/icon/appIcon.jpg",
            lat : jsonData['lat'],
            lon : jsonData['lon'],
            score : jsonData['score'] ?? 0,
            lastMsg : new ChatMessage.fromJSON(jsonData['lastMsg'] ?? {"type":"TALK","roomIdx":1,"msgIdx":18,"senderIdx":100,"nickname":null,"message":"ㅇㅇ","userCountObj":null,"createTs":1577515882850}),
            userCount : new ChatCountUser.fromJSON(jsonData['userCount'])
        );
    }
}