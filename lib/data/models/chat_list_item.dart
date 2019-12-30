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
    int adReceiveTs;	        // AD 받아서 chatList에 넣은 시간

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
            chatImg : jsonData['roomImg'] ?? "assets/images/icon/appIcon.jpg",
            title : jsonData['title'] ?? "단화방 제목입니다.",
            lat : jsonData['lat'],
            lon : jsonData['lon'],
            score : jsonData['score'] ?? 0,
            lastMsg : new ChatMessage.fromJSON(jsonData['lastMsg']
                ?? {"type":"ENTER", "roomIdx":jsonData['roomIdx'], "msgIdx":null, "senderIdx":jsonData['createUserIdx'], "nickname":null, "message":"", "userCountObj":null, "createTs": jsonData['createTs']}),
            userCount : new ChatCountUser.fromJSON(jsonData['userCount'])
        );
    }

    /*
     * @author : hk
     * @date : 2019-12-30
     * @description : ChatListItem 의 같음 여부 체크 위해 재정의
     */
    @override
    bool operator ==(Object other) => other is ChatListItem && other.chatIdx == chatIdx;

    @override
    int get hashCode => chatIdx.hashCode;
}