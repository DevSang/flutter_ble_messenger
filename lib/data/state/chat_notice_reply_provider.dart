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
                developer.log("# get notice reply");

                List resList = json.decode(response.body)['data'];
                print(resList.toString());
                for(var i = 0; i < resList.length; i++){
                    noticeReplyList.add(ChatNoticeReply.fromJSON(resList[i]));
                }

            } else {
                developer.log("# No notice reply");
                noticeReplyList = <ChatNoticeReply>[];
            }
        } else {
            developer.log("# Server request failed.");
            noticeReplyList = <ChatNoticeReply>[];
        }
        sortNoticeReply();
        notifyListeners();
    }

    /*
    * @author : sh
    * @date : 2020-01-11
    * @description : 공지사항 댓글 새로 작성
    */
    writeNoticeReply(String contents, int chatIdx, noticeIdx, UserInfoProvider userInfo) async {
        try {
            String uri = "/api/v2/chat/announce/reply";
            final response = await CallApi.commonApiCall(
                method: HTTP_METHOD.post,
                url: uri,
                data: {
                    "chat_idx" : chatIdx,
                    "chat_announce_idx": noticeIdx,
                    "contents" : contents
                }
            );

            int chatAnnounceIdx = jsonDecode(jsonDecode(response.body)['data'])['chat_announce_idx'];

            noticeReplyList.add(
                ChatNoticeReply(
                    idx : noticeIdx,
                    chat_idx : chatIdx,
                    chat_announce_idx : chatAnnounceIdx,
                    user_idx : userInfo.idx,
                    country_code : userInfo.countryCode.toString(),
                    phone_number : userInfo.phoneNumber,
                    nickname : userInfo.nickname,
                    user_status : userInfo.userStatus,
                    contents : contents,
                    is_delete : false,
                    reg_ts : new DateTime.now().toString(),
                )
            );
            sortNoticeReply();
            RedToast.toast("댓글이 등록되었습니다.", ToastGravity.TOP);

        } catch (e) {
            RedToast.toast("서버요청을 실패하였습니다. 잠시 후 다시 시도해주세요.", ToastGravity.TOP);
            developer.log("#### Error :: "+ e.toString());
        }

        notifyListeners();
    }

    /*
    * @author : sh
    * @date : 2020-01-12
    * @description : 공지사항 댓글 삭제
    */
    deleteNoticeReply(int noticeReplyIdx) async {
        try {
            String uri = "/api/v2/chat/announce/reply?chat_announce_reply_idx=" + noticeReplyIdx.toString();
            await CallApi.commonApiCall(
                method: HTTP_METHOD.delete,
                url: uri,
            );

            noticeReplyList.removeWhere((item) =>
                item.idx == noticeReplyIdx
            );

            sortNoticeReply();
            RedToast.toast("댓글이 삭제되었습니다.", ToastGravity.TOP);

        } catch (e) {
            RedToast.toast("서버요청을 실패하였습니다. 잠시 후 다시 시도해주세요.", ToastGravity.TOP);
            developer.log("#### Error :: "+ e.toString());
        }

        notifyListeners();
    }

    /*
    * @author : sh
    * @date : 2020-01-11
    * @description : 공지사항 sorting
    */
    sortNoticeReply() async {
        noticeReplyList.sort((a, b) => b.idx.compareTo(a.idx));
        notifyListeners();
    }
}
