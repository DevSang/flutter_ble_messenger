import 'dart:io';

class ChatUserInfo {
    int userIdx;
    String nick;
    File profileImg;
    String partType;
    bool existContact;
    String businessCard;
    String userIntro;
    bool addFriend;
    int profilePictureIdx;

    ChatUserInfo({
        this.userIdx
        , this.nick
        , this.profileImg
        , this.partType
        , this.existContact
        , this.businessCard
        , this.userIntro
        , this.addFriend
        , this.profilePictureIdx
    });

    factory ChatUserInfo.fromJSON (Map json) {
        return ChatUserInfo (
            userIdx : json['user_idx'],
            nick : json['nickname'],
            profileImg : json['masterUserIdx'],
	        profilePictureIdx : json['profile_picture_idx'],
//            existContact : json['roomImg'],
//            businessCard : json['lat'],
//            userIntro : json['lon'],
//            addFriend : json['score']
        );
    }
}