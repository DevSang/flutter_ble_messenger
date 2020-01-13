class ChatNoticeItem {
    final int idx;
    final int chat_idx;
    final int user_idx;
    final String country_code;
    final String phone_number;
    String nickname;
    String user_status;
    int profile_picture_idx;
    String contents;
    bool is_delete;
    int reply_cnt;
    String reg_ts;
    String update_ts;

    ChatNoticeItem({
        this.idx
        , this.chat_idx
        , this.user_idx
        , this.country_code
        , this.phone_number
        , this.nickname
        , this.user_status
        , this.profile_picture_idx
        , this.contents
        , this.is_delete
        , this.reply_cnt
        , this.reg_ts
        , this.update_ts
    });

    factory ChatNoticeItem.fromJSON (Map json) {
        Map jbUserData = json['jb_user_data'];
        int profilePictureIdx = jbUserData.containsKey("profile_picture_idx") ? jbUserData["profile_picture_idx"] : 0;
        try{
            return ChatNoticeItem (
                idx : json['idx'],
                chat_idx : json['chat_idx'],
                user_idx : json['jb_user_data']['user_idx'],
                country_code : json['jb_user_data']['country_code'],
                phone_number : json['jb_user_data']['phone_number'],
                nickname : json['jb_user_data']['nickname'],
                user_status : json['jb_user_data']['user_status'],
                profile_picture_idx : profilePictureIdx ,
                contents : json['contents'],
                is_delete : json['is_delete'],
                reply_cnt : json['reply_cnt'],
                reg_ts : json['reg_ts'],
                update_ts : json['update_ts'],
            );
        } catch(e){
            print("###" + e.toString());
            return null;
        }
    }
}