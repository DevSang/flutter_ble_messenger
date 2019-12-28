import 'dart:convert';

import 'package:Hwa/data/models/chat_count_user.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/models/chat_user_info.dart';

class ChatInfo {
    /// 추후 교체
    int chatIdx;				// 단화룸 idx
    int createUserIdx;			// 단화룸 생성 userIdx
    int masterUserIdx;			// 단화룸 현재 방장 userIdx
    String title;				// 단화룸 타이틀
    String chatImg;				// 단화룸 이미지
    double lat;					// 위도
    double lon;					// 경도
    double score;				// 랭킹 점수
    int createTs;				// 생성 시간
    ChatMessage lastMsg;		// 마지막 메시지
    int userCount;	            // 참여 사용자 수
    String mode;			    // 단화룸 타입
    ChatUserInfo createUser;    // 생성자 정보
//    String intro;               // 단화룸 소개글
//    bool isPublic;              // 온라인 공개 여부
//    int inviteRange;            // 초대 범위

    ChatInfo({
        this.chatIdx
        ,this.createUserIdx
        , this.masterUserIdx
        , this.title
        , this.chatImg
        , this.lat
        , this.lon
        , this.score
        , this.createTs
        , this.lastMsg
        , this.userCount
        , this.mode
        , this.createUser
    });


    factory ChatInfo.fromJSON (Map<String, dynamic> jsonData) {
        return ChatInfo (
            chatIdx : jsonData['roomIdx'],
            createUserIdx : jsonData['createUserIdx'],
            masterUserIdx : jsonData['masterUserIdx'],
            title : jsonData['title'],
            chatImg : jsonData['roomImg'],
            lat : jsonData['lat'],
            lon : jsonData['lon'],
            score : jsonData['score'],
            createTs : jsonData['createTs'],
            lastMsg : jsonData['lastMsg'],
            userCount : jsonData['userCount'],
            mode : jsonData['chatMode'],
            createUser : new ChatUserInfo.fromJSON(json.decode(jsonData['createUser']))
        );
    }
}