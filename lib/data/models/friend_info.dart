import 'dart:io';

class FriendInfo {
    int userIdx;
    String nickname;
    String phone_number;
    int profile_picture_idx;
    int business_card_idx;
    String user_status;

    FriendInfo({
        this.userIdx
        , this.nickname
        , this.phone_number
        , this.profile_picture_idx
        , this.business_card_idx
        , this.user_status
    });

    factory FriendInfo.fromJSON (Map json) {
        return FriendInfo (
            userIdx : json['user_idx'],
            nickname : json['nickname'],
            phone_number : json['phone_number'],
            profile_picture_idx : json['profile_picture_idx'],
            business_card_idx : json['business_card_idx'],
            user_status : json['user_status'],
        );
    }
}