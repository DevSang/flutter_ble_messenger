import 'dart:convert';

/*
 * @project : HWA - Mobile
 * @author : hk
 * @date : 2020-01-09
 * @description : 단화방 참여 사용자 정보
 */
class ChatJoinInfo {
    String joinType;				// User Join Type : BLE_JOIN / BLE_OUT / ONLINE
    int userIdx;			        // User Idx
	int profilePictureIdx;		    // profile_picture_idx
    String userNick;			    // User Nick
    String description;			    // description
    bool isFriendRequestAllowed;    // is_friend_request_allowed
    bool isPushAllowed;             // is_push_allowed

    ChatJoinInfo({
        this.joinType
        , this.userIdx
        , this.userNick
        , this.profilePictureIdx
        , this.isFriendRequestAllowed
        , this.isPushAllowed
        , this.description
    });

    factory ChatJoinInfo.fromJSON (Map<String, dynamic> jsonData) {
        Map<String, dynamic> userVal = json.decode(jsonData['jb_user_data']);

        return ChatJoinInfo (
            joinType : jsonData['join_type'],
            userIdx : jsonData['user_idx'],
            userNick : userVal['nickname'],
	        profilePictureIdx : userVal['profile_picture_idx'],
	        isFriendRequestAllowed : userVal['is_friend_request_allowed'],
	        isPushAllowed : userVal['is_push_allowed'],
	        description : userVal['description'],
        );
    }
}