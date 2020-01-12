import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/data/models/chat_notice_reply.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/data/state/user_info_provider.dart';


/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2020-01-11
 * @description : 채팅 공지 목록 provider
 */

class ChatRoomNoticeReplyProvider with ChangeNotifier{
    List<ChatNoticeReply> noticeReplyList = <ChatNoticeReply>[];

    ChatRoomNoticeReplyProvider({
        this.noticeReplyList
    });

    /*
    * @author : sh
    * @date : 2020-01-11
    * @description : 공지사항 댓글 목록 가져오기
    */
    Future<void> getNoticeReplyList (int chatIdx, noticeIdx) async {
        String uri = "/api/v2/chat/announce/reply/all?chat_idx=" +  chatIdx.toString() + "&" + "chat_announce_idx=" + noticeIdx.toString();
        final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);

        if(response != null){
            if(jsonDecode(response.body)['data'].toString() != '[]'){
                developer.log("# Set friend list");

                List resList = json.decode(response.body)['data'];
                print(resList.toString());
//                for(var i = 0; i < resList.length; i++){
//                    noticeReplyList.add(ChatNoticeItem.fromJSON(resList[i]));
//                }

            } else {
                developer.log("# No notice reply");
                noticeReplyList = <ChatNoticeReply>[];
            }
        } else {
            developer.log("# Server request failed.");
            noticeReplyList = <ChatNoticeReply>[];
        }
//        sortNotice();
        notifyListeners();
    }

    /*
    * @author : sh
    * @date : 2020-01-11
    * @description : 공지사항 댓글 새로 작성
    */
//    writeNoticeReply(String contents, int chatIdx, UserInfoProvider userInfo) async {
//        try {
//            /// 참여 타입 수정
//            String uri = "/api/v2/chat/announce";
//            final response = await CallApi.commonApiCall(
//                method: HTTP_METHOD.post,
//                url: uri,
//                data: {
//                    "chat_idx" : chatIdx,
//                    "contents" : contents
//                }
//            );
//
//            int noticeIdx = jsonDecode(jsonDecode(response.body)['data'])['announce_idx'];
//            chatNoticeList.add(
//                ChatNoticeItem(
//                    idx : noticeIdx,
//                    chat_idx : chatIdx,
//                    user_idx : userInfo.idx,
//                    country_code : userInfo.countryCode.toString(),
//                    phone_number : userInfo.phoneNumber,
//                    nickname : userInfo.nickname,
//                    user_status : userInfo.userStatus,
//                    contents : contents,
//                    is_delete : false,
//                    reply_cnt : 0,
//                    reg_ts : new DateTime.now().toString(),
//                )
//            );
//            sortNotice();
//            RedToast.toast("공지사항이 등록되었습니다.", ToastGravity.TOP);
//
//        } catch (e) {
//            developer.log("#### Error :: "+ e.toString());
//            RedToast.toast("공지사항이 등록되었습니다.", ToastGravity.TOP);
//        }
//
//        notifyListeners();
//    }

///*
//    * @author : sh
//    * @date : 2020-01-11
//    * @description : 공지사항 sorting
//    */
//    sortNotice() async {
//        chatNoticeList.sort((a, b) => b.idx.compareTo(a.idx));
//        notifyListeners();
//    }
}
