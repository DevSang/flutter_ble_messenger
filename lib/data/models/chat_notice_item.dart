class ChatNoticeItem {
    final String content;
    final String userImg;
    final int regTime;
    final int replyCount;

    ChatNoticeItem({this.content, this.userImg, this.regTime, this.replyCount});
}
//
//class ChatNoticeItem {
//    final int noticeIdx;
//    final int writerIdx;
//    final int userImg;
//    final String content;
//    final int regTime;
//    final int replyCount;
//    final bool isDelete;
//
//    ChatNoticeItem({this.noticeIdx, this.writerIdx, this.userImg, this.content, this.regTime, this.replyCount, this.isDelete});
//
//    factory ChatNoticeItem.fromJSON (Map json) {
//        return ChatNoticeItem (
//            noticeIdx : json['idx'],
//            writerIdx : json['jb_user_data']['user_idx'],
//            userImg : json['jb_user_data']['profile_picture_idx'],
//            content : json['contents'],
//            regTime : json['reg_ts'],
//            replyCount : json['phone_number'],
//            isDelete : json['phone_number'],
//        );
//    }
//}