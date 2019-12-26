import 'dart:io';

class ChatUserInfo {
    final String nick;
    Future<File> profileImg;
    final String partType;
    final bool existContact;
    final String businessCard;
    final String userIntro;
    final bool addFriend;
    final bool isHost;
    final bool isMe;

    ChatUserInfo({this.nick ,this.profileImg, this.partType, this.existContact, this.businessCard, this.userIntro, this.addFriend, this.isHost, this.isMe});
}