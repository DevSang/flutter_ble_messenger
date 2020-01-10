import 'dart:io';
import 'package:Hwa/data/models/chat_count_user.dart';
import 'package:Hwa/package/gauge/gauge_driver.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class ChatMessage {
    final String chatType; 			    // 메시지 타입
    final int roomIdx; 				    // 방번호
    final int msgIdx; 				    // 메시지 idx
    final int senderIdx; 			    // 메시지 보낸사람
    final String nickName; 				// 보낸사람 닉네임
    final String message; 				// 메시지
    final ChatCountUser userCountObj; 	// 채팅방 인원수, 채팅방 내에서 메시지가 전달될때 인원수 갱신시 사용
    final int chatTime;					// 생성 시간
    // Thumbnail Message 관련 변수
    final GaugeDriver gaugeDriver;		// 업로드 Percentage 표현
    bool uploaded;		                // 업로드 완료 여부
    final dynamic thumbnailFile;           // Placeholder Image Source (Thumbnail)
    YoutubePlayer youtubePlayer;        // youtube video

    ChatMessage({this.chatType ,this.roomIdx, this.msgIdx, this.senderIdx, this.nickName, this.message, this.userCountObj, this.chatTime, this.gaugeDriver, this.uploaded, this.thumbnailFile});

    factory ChatMessage.fromJSON (Map<String, dynamic> json) {
        try {
	        return ChatMessage (
	                    chatType : json['type'],
	                    roomIdx : json['roomIdx'],
	                    msgIdx : json['msgIdx'],
	                    senderIdx : json['senderIdx'],
	                    nickName : json['nickname'] ?? "닉네임 없음",
	                    message : json['message'],
	                    userCountObj : json['userCountObj'] != null ? new ChatCountUser.fromJSON(json['userCountObj']) : null,
	                    chatTime : json['createTs']
	                );
        } catch (e) {
	        return null;
        }
    }
}