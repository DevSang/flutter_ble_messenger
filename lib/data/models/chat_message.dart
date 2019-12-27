import 'package:Hwa/data/models/chat_count_user.dart';
import 'dart:collection';

class ChatMessage {
    final String chatType; 			    // 메시지 타입
    final int roomIdx; 				    // 방번호
    final int msgIdx; 				    // 메시지 idx
    final int senderIdx; 			    // 메시지 보낸사람
    final String nickname; 				// 보낸사람 닉네임
    final String message; 				// 메시지
    final ChatCountUser userCountObj; 	// 채팅방 인원수, 채팅방 내에서 메시지가 전달될때 인원수 갱신시 사용
    final int chatTime;					// 생성 시간

    ChatMessage({this.chatType ,this.roomIdx, this.msgIdx, this.senderIdx, this.nickname, this.message, this.userCountObj, this.chatTime});

    factory ChatMessage.fromJSON (Map json) {
        return ChatMessage (
            chatType : json['type'],
            roomIdx : json['roomIdx'],
            msgIdx : json['msgIdx'],
            senderIdx : json['senderIdx'],
            nickname : json['nickname'],
            message : json['message'],
            userCountObj : json['userCountObj'],
            chatTime : json['createTs']
        );
    }
}