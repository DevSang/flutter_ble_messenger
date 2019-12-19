import 'package:Hwa/data/models/chat_count_user.dart';

class ChatMessage {
    final String chatType;
    final int roomIdx;
    final int senderIdx;
    final String message;
    final ChatCountUser userCount;
    final double chatTime;
    ChatMessage({this.chatType ,this.roomIdx, this.senderIdx, this.message, this.userCount, this.chatTime});
}