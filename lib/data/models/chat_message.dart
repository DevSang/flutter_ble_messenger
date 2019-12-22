import 'package:Hwa/data/models/chat_count_user.dart';
import 'dart:collection';

class ChatMessage {
    final String chatType;
    final int roomIdx;
    final int senderIdx;
    final String message;
//    final ChatCountUser userCount;
    final int chatTime;
    ChatMessage({this.chatType ,this.roomIdx, this.senderIdx, this.message, this.chatTime});

    factory ChatMessage.fromJSON (Map json) {
        return ChatMessage (
            chatType : json['type'],
            roomIdx : json['roomIdx'],
            senderIdx : json['senderIdx'],
            message : json['message'],
            chatTime : json['createTs']
        );
    }
}