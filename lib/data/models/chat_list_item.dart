import 'package:Hwa/data/models/chat_count_user.dart';
import 'package:Hwa/data/models/chat_message.dart';

class ChatListItem {
    final int chatIdx;		    // 단화방 Idx
    final String title; 		// 이름
    double lat;					// 위도
    double lon;					// 경도
    double score;               // 랭킹 점수
    ChatMessage lastMsg;		// 마지막 메시지
    ChatCountUser userCount;	// 참여 사용자 수
    int adReceiveTs;	        // AD 받아서 chatList에 넣은 시간
    int roomImgIdx;             // 대표 이미지 Idx
    final bool isAlreadyJoin;   // 기존 참여 여부
    final int unreadMsgCnt;     // 안읽은 메세지 수

    ChatListItem({
        this.chatIdx,
        this.roomImgIdx,
        this.title,
        this.lat,
        this.lon,
        this.score,
        this.lastMsg,
        this.userCount,
        this.isAlreadyJoin,
        this.unreadMsgCnt
    });

    factory ChatListItem.fromJSON (Map<String, dynamic> jsonData) {
        return ChatListItem (
            chatIdx : jsonData['roomIdx'],
	        roomImgIdx: jsonData['roomImgIdx'],
            title : jsonData['title'] ?? "단화방 제목입니다.",
            lat : jsonData['lat'],
            lon : jsonData['lon'],
            score : jsonData['score'],
            lastMsg : new ChatMessage.fromJSON(jsonData['lastMsg']
                ?? {"type":null, "roomIdx":null, "msgIdx":null, "senderIdx":null, "nickname":null, "message":null, "userCountObj":null, "createTs": null}),
            userCount : new ChatCountUser.fromJSON(jsonData['userCount']
                ?? {"roomIdx":null, "bleJoin":null, "bleOut":null, "online":null, "totalCount":null}),
            isAlreadyJoin: jsonData['isAlreadyJoin'],
            unreadMsgCnt: jsonData['unreadMsgCnt']
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