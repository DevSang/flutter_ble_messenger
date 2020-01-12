class ChatNoticeReply {
    final int idx;
    final int chat_idx;
    final int chat_announce_idx;
    final int user_idx;
    final String country_code;
    final String phone_number;
    final String nickname;
    final String user_status;
    final int profile_picture_idx;
    final String contents;
    final bool is_delete;
    final String reg_ts;

    ChatNoticeReply({
        this.idx
        , this.chat_idx
        , this.chat_announce_idx
        , this.user_idx
        , this.country_code
        , this.phone_number
        , this.nickname
        , this.user_status
        , this.profile_picture_idx
        , this.contents
        , this.is_delete
        , this.reg_ts
    });

    factory ChatNoticeReply.fromJSON (Map json) {
        Map jbUserData = json['jb_user_data'];
        int profilePictureIdx = jbUserData.containsKey("profile_picture_idx") ? jbUserData["profile_picture_idx"] : 0;
        try{
            return ChatNoticeReply (
                idx : json['idx'],
                chat_idx : json['chat_idx'],
                chat_announce_idx : json['chat_announce_idx'],
                user_idx : json['jb_user_data']['user_idx'],
                country_code : json['jb_user_data']['country_code'],
                phone_number : json['jb_user_data']['phone_number'],
                nickname : json['jb_user_data']['nickname'],
                user_status : json['jb_user_data']['user_status'],
                profile_picture_idx : profilePictureIdx ,
                contents : json['contents'],
                is_delete : json['is_delete'],
                reg_ts : json['reg_ts'],
            );
        } catch(e){
            print("###" + e.toString());
            return null;
        }
    }
}
