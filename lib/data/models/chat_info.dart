import 'package:Hwa/data/models/chat_count_user.dart';
import 'package:Hwa/data/models/chat_message.dart';

class ChatInfo {
    String chatImg;
    String title;
    String intro;
    bool isPublic;
    int inviteRange;
    int mode;

//    final int chatIdx;				    // 단화룸 idx
//    final int createUserIdx;			// 단화룸 생성 userIdx
//    final int masterUserIdx;			// 단화룸 현재 방장 userIdx
//    final String title;				    // 단화룸 타이틀
//    final String chatImg;				// 단화룸 이미지
//    final double lat;					// 위도
//    final double lon;					// 경도
//    final double score;				    // 랭킹 점수
//    final int createTs;				    // 생성 시간
//    final ChatMessage lastMsg;		    // 마지막 메시지
//    final ChatCountUser userCount;	    // 참여 사용자 수
//    final HwaUser createUser;			// 생성자 정보
//    final ChatMode mode;			// 단화룸 타입


    ChatInfo({this.chatImg ,this.title, this.intro, this.isPublic, this.inviteRange, this.mode});
}