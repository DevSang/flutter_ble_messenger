import 'dart:convert';

import 'package:Hwa/data/models/chat_count_user.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/data/models/chat_user_info.dart';

class ChatInfo {
    /// 추후 교체
    int chatIdx;				// 단화룸 idx
    int createUserIdx;			// 단화룸 생성 userIdx
    int masterUserIdx;			// 단화룸 현재 방장 userIdx
    String title;				// 단화룸 타이틀
    String intro;               // 단화룸 소개글
    String chatImg;				// 단화룸 이미지
    double lat;					// 위도
    double lon;					// 경도
    double score;				// 랭킹 점수
    int createTs;				// 생성 시간
    ChatMessage lastMsg;		// 마지막 메시지
    ChatCountUser userCount;	// 참여 사용자 수
    String mode;			    // 단화룸 타입
    ChatUserInfo createUser;    // 생성자 정보
    bool isPublic;              // 온라인 공개 여부
    int inviteRange;            // 초대 범위

    ChatInfo({
        this.chatIdx
        ,this.createUserIdx
        , this.masterUserIdx
        , this.title
        , this.intro
        , this.chatImg
        , this.lat
        , this.lon
        , this.score
        , this.createTs
        , this.lastMsg
        , this.userCount
        , this.mode
        , this.createUser
        , this.isPublic
        , this.inviteRange
    });


    factory ChatInfo.fromJSON (Map<String, dynamic> jsonData) {
        return ChatInfo (
            chatIdx : jsonData['roomIdx'],
            createUserIdx : jsonData['createUserIdx'],
            masterUserIdx : jsonData['masterUserIdx'] ?? jsonData['createUserIdx'],
            title : jsonData['title'] ?? "단화방 제목입니다.",
            intro: jsonData['intro'] ?? "단화방 소개글",
            chatImg : jsonData['roomImg'] ?? "assets/images/icon/appIcon.jpg",
            lat : jsonData['lat'],
            lon : jsonData['lon'],
            score : jsonData['score'] ?? 0,
            createTs : jsonData['createTs'],
            lastMsg : new ChatMessage.fromJSON(jsonData['lastMsg'] ?? {"type":"TALK","roomIdx":1,"msgIdx":18,"senderIdx":100,"nickname":null,"message":"ㅇㅇ","userCountObj":null,"createTs":1577515882850}),
            userCount : new ChatCountUser.fromJSON(jsonData['userCount']),
            mode : jsonData['chatMode'],
            createUser : new ChatUserInfo.fromJSON(jsonData['createUser'] ?? {"user_idx": 32, "nickname": "마이런"}),
            isPublic : jsonData['isPublic'] ?? true,
            inviteRange : jsonData['inviteRange'] ?? 2
        );
    }
}