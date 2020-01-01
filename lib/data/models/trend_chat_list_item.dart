import 'package:Hwa/data/models/chat_count_user.dart';
import 'package:Hwa/data/models/chat_message.dart';

class TrendChatListItem {
    final int chatIdx;
    final String chatImg;
    final String title;
    double lat;					// 위도
    double lon;					// 경도
    double score;               // 랭킹 점수
    ChatMessage lastMsg;		// 마지막 메시지
    ChatCountUser userCount;	// 참여 사용자 수
    int likeCount;	            // 좋아요 수
    int adReceiveTs;	        // AD 받아서 chatList에 넣은 시간
    bool isLiked;	            // 좋아요 여부

    TrendChatListItem({
        this.chatIdx,
        this.chatImg,
        this.title,
        this.lat,
        this.lon,
        this.score,
        this.lastMsg,
        this.userCount,
        this.likeCount,
        this.isLiked
    });

    factory TrendChatListItem.fromJSON (Map<String, dynamic> jsonData) {
        return TrendChatListItem (
            chatIdx : jsonData['roomIdx'],
            chatImg : jsonData['roomImg'],
            title : jsonData['title'] ?? "단화방 제목입니다.",
            lat : jsonData['lat'],
            lon : jsonData['lon'],
            score : jsonData['score'],
            lastMsg : new ChatMessage.fromJSON(jsonData['lastMsg']
                ?? {"type":null, "roomIdx":null, "msgIdx":null, "senderIdx":null, "nickname":null, "message":null, "userCountObj":null, "createTs": null}),
            userCount : new ChatCountUser.fromJSON(jsonData['userCount']
                ?? {"roomIdx":0, "bleJoin":0, "bleOut":0, "online":0, "totalCount":0}),
            likeCount : jsonData['likeCount'] ?? 0,
            isLiked : jsonData['isLiked']
        );
    }
    /*
     * @author : hk
     * @date : 2019-12-30
     * @description : ChatListItem 의 같음 여부 체크 위해 재정의
     */
    @override
    bool operator ==(Object other) => other is TrendChatListItem && other.chatIdx == chatIdx;

    @override
    int get hashCode => chatIdx.hashCode;
}