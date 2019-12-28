import 'dart:io';

class ChatUserInfo {
    int userIdx;
    String nick;
    Future<File> profileImg;
    String partType;
    bool existContact;
    String businessCard;
    String userIntro;
    bool addFriend;

    ChatUserInfo({
        this.userIdx
        , this.nick
        , this.profileImg
        , this.partType
        , this.existContact
        , this.businessCard
        , this.userIntro
        , this.addFriend
    });
}