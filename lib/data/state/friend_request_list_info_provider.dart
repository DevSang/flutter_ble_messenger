import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/data/models/friend_request_info.dart';



/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-30
 * @description : 친구목록 provider model
 */

class FriendRequestListInfoProvider with ChangeNotifier{
    List<FriendRequestInfo> friendRequestList;

    setFriendRequestInfo(dynamic value) {
        notifyListeners();
    }

    FriendRequestListInfoProvider({
        this.friendRequestList
    });

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 친구요청 목록
    */
    Future<void> getFriendRequestList () async {

        String uri = "/api/v2/relation/request/all";
        final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);

        if(response != null){
            List<dynamic> tempFriendRequestList = jsonDecode(response.body)['data'];

            for(var i = 0; i < tempFriendRequestList.length; i++){
                var friendRequest = tempFriendRequestList[i]['jb_request_user_data'];

                if(!['5101','5102'].contains(tempFriendRequestList[i]['response_type']) && !tempFriendRequestList[i]['is_cancel']){
                    friendRequestList.add(
                        FriendRequestInfo(
                            req_idx: tempFriendRequestList[i]['idx'],
                            user_idx: friendRequest['user_idx'],
                            nickname: friendRequest['nickname'],
                            phone_number: friendRequest['phone_number'],
                            profile_picture_idx: friendRequest['profile_picture_idx'],
                            business_card_idx: friendRequest['business_card_idx'],
                            user_status: friendRequest['user_status'],
                            description: friendRequest['description'] ??  '안녕하세요! ' + friendRequest['nickname'] + "입니다! :)"
                        )
                    );
                }
            }

            ///LOGGING
            developer.log("# Set friend List");
            friendRequestList.map((friend){
                developer.log("# req_idx : " + friend.req_idx.toString());
                developer.log("# user_idx : " + friend.user_idx.toString() + " nickname : " + friend.nickname.toString());
                developer.log("# phone_number : " + friend.phone_number.toString() + " profile_picture_idx : " + friend.profile_picture_idx.toString());
                developer.log("# description : " + friend.description.toString() + " business_card_idx : " + friend.business_card_idx.toString()+"\n");
            });
        } else {
            developer.log("# No friend request");
            friendRequestList = [];
        }
    }
}
