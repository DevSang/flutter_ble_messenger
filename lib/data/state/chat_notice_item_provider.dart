import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/data/models/chat_notice_item.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/data/state/user_info_provider.dart';


/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2020-01-11
 * @description : 채팅 공지 목록 provider
 */

class ChatRoomNoticeInfoProvider with ChangeNotifier{
    List<ChatNoticeItem> chatNoticeList = <ChatNoticeItem>[];

    ChatRoomNoticeInfoProvider({
        this.chatNoticeList
    });

    /*
    * @author : sh
    * @date : 2020-01-11
    * @description : 공지사항 목록 api call 하여 Provider에 저장
    */
    Future<void> getNoticeList (int chatIdx) async {
        String uri = "/api/v2/chat/announce/all?chat_idx=" +  chatIdx.toString();
        final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);

        if(response != null){
            if(jsonDecode(response.body)['data'].toString() != '[]'){
                developer.log("# Set notice list");
                print(response.body);
                List resList = json.decode(response.body)['data'];
                for(var i = 0; i < resList.length; i++){
                    chatNoticeList.add(ChatNoticeItem.fromJSON(resList[i]));
                }

            } else {
                developer.log("# No notice");
                chatNoticeList = <ChatNoticeItem>[];
            }
        } else {
            developer.log("# Server request failed.");
            chatNoticeList = <ChatNoticeItem>[];
        }
        sortNotice();
        notifyListeners();
    }

    /*
    * @author : sh
    * @date : 2020-01-11
    * @description : 공지사항 새로 작성
    */
    writeNotice(String contents, int chatIdx, UserInfoProvider userInfo) async {
        try {
            /// 참여 타입 수정
            String uri = "/api/v2/chat/announce";
            final response = await CallApi.commonApiCall(
                method: HTTP_METHOD.post,
                url: uri,
                data: {
                    "chat_idx" : chatIdx,
                    "contents" : contents
                }
            );

            int noticeIdx = jsonDecode(jsonDecode(response.body)['data'])['announce_idx'];
            chatNoticeList.add(
                ChatNoticeItem(
                    idx : noticeIdx,
                    chat_idx : chatIdx,
                    user_idx : userInfo.idx,
                    country_code : userInfo.countryCode.toString(),
                    phone_number : userInfo.phoneNumber,
                    nickname : userInfo.nickname,
                    user_status : userInfo.userStatus,
                    contents : contents,
                    is_delete : false,
                    reply_cnt : 0,
                    reg_ts : new DateTime.now().toString(),
                    update_ts : new DateTime.now().toString(),
                )
            );
            sortNotice();
            RedToast.toast("공지사항이 등록되었습니다.", ToastGravity.TOP);

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
            RedToast.toast("서버요청을 실패하였습니다. 잠시 후 다시 시도해주세요.", ToastGravity.TOP);
        }

        notifyListeners();
    }

    /*
    * @author : sh
    * @date : 2020-01-11
    * @description : 공지사항 수정
    */
    //TODO 수정하기 API요청
    updateNotice(String contents, int chatIdx, noticeIdx, UserInfoProvider userInfo) async {
        try {
            /// 참여 타입 수정
            String uri = "/api/v2/chat/announce";
            final response = await CallApi.commonApiCall(
                method: HTTP_METHOD.put,
                url: uri,
                data: {
                    "idx": noticeIdx,
                    "chat_idx" : chatIdx,
                    "contents" : contents
                }
            );

            ChatNoticeItem oldNotice = chatNoticeList.singleWhere((notice)=>
                notice.idx == noticeIdx
            );

            oldNotice.contents = contents;
            oldNotice.update_ts = new DateTime.now().toString();

            sortNotice();
            RedToast.toast("공지사항이 수정되었습니다.", ToastGravity.TOP);

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
            RedToast.toast("서버요청을 실패하였습니다. 잠시 후 다시 시도해주세요.", ToastGravity.TOP);
        }

        notifyListeners();
    }

    /*
    * @author : sh
    * @date : 2020-01-12
    * @description : 공지사항 삭제
    */
    deleteNotice(int noticeIdx) async {
        try {
            String uri = "/api/v2/chat/announce?announce_idx=" + noticeIdx.toString();
            await CallApi.commonApiCall(
                method: HTTP_METHOD.delete,
                url: uri,
            );

            chatNoticeList.removeWhere((item) =>
                item.idx == noticeIdx
            );

            sortNotice();
            RedToast.toast("공지사항이 삭제되었습니다.", ToastGravity.TOP);

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
    sortNotice() async {
        chatNoticeList.sort((a, b) => b.update_ts.compareTo(a.update_ts));
        notifyListeners();
    }
}
