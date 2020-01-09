import 'dart:io';

class FriendRequestInfo {
    int user_idx;
    int req_idx;
    String nickname;
    String phone_number;
    int profile_picture_idx;
    int business_card_idx;
    String user_status;
    String description;

    FriendRequestInfo({
        this.user_idx
        , this.req_idx
        , this.nickname
        , this.phone_number
        , this.profile_picture_idx
        , this.business_card_idx
        , this.user_status
        , this.description
    });

    factory FriendRequestInfo.fromJSON (Map json) {
        return FriendRequestInfo (
            user_idx : json['user_idx'],
            req_idx : json['req_idx'],
            nickname : json['nickname'] ?? "닉네임 정보가 없습니다.",
            phone_number : json['phone_number'],
            profile_picture_idx : json['profile_picture_idx'],
            business_card_idx : json['business_card_idx'],
            user_status : json['user_status'],
            description : json['description'] ?? "",
        );
    }
}