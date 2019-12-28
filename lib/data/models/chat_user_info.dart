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

    factory ChatUserInfo.fromJSON (Map json) {
        return ChatUserInfo (
            userIdx : json['user_idx'],
            nick : json['nickname'],
            profileImg : json['masterUserIdx'],
            partType : json['profile_picture_idx'],
//            existContact : json['roomImg'],
//            businessCard : json['lat'],
//            userIntro : json['lon'],
//            addFriend : json['score']
        );
    }
}