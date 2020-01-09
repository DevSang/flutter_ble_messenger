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
    List<FriendRequestInfo> friendRequestList = <FriendRequestInfo>[];

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
            if(jsonDecode(response.body)['data'].toString() != '[]'){
                developer.log("# Set friend request list");

                List<dynamic> tempFriendRequestList = jsonDecode(response.body)['data'];

                for(var i = 0; i < tempFriendRequestList.length; i++){
                    var friendRequest = tempFriendRequestList[i]['jb_request_user_data'];

                    developer.log(tempFriendRequestList.toString());
                    developer.log(friendRequest.toString());
                    developer.log(['5101','5102'].contains(tempFriendRequestList[i]['response_type']).toString());
                    developer.log(tempFriendRequestList[i]['is_cancel'].toString());

                    if(!['5101','5102'].contains(tempFriendRequestList[i]['response_type']) && !tempFriendRequestList[i]['is_cancel']){
                        print("req_idx:"+ tempFriendRequestList[i]['idx'].toString());
                        print("user_idx:" + friendRequest['user_idx'].toString());
                        print("nickname:"+ friendRequest['nickname'].toString());
                        print("phone_number:"+ friendRequest['phone_number'].toString());
                        print("profile_picture_idx:"+ friendRequest['profile_picture_idx'].toString());
                        print("business_card_idx:"+ friendRequest['business_card_idx'].toString());
                        print("user_status:"+ friendRequest['user_status'].toString());
                        print("description:"+ friendRequest['description'] ??  '안녕하세요! ' + friendRequest['nickname'] + "입니다! :)");

                        friendRequestList.add(
                            FriendRequestInfo(
                                req_idx: tempFriendRequestList[i]['idx'],
                                user_idx: friendRequest['user_idx'],
                                nickname: friendRequest['nickname'],
                                phone_number: friendRequest['phone_number'],
                                profile_picture_idx: friendRequest['profile_picture_idx'] ?? 0,
                                business_card_idx: friendRequest['business_card_idx'] ?? 0,
                                user_status: friendRequest['user_status'],
                                description: friendRequest['description'] ??  '안녕하세요! ' + friendRequest['nickname'] + '입니다! :)'
                            )
                        );

                        print("됨");

//                        developer.log("# req_idx : " + tempFriendRequestList[i]['idx'].toString());
//                        developer.log("# user_idx : " + friendRequest['user_idx'].toString() + " nickname : " + friendRequest['nickname'].toString());
//                        developer.log("# phone_number : " + friendRequest['phone_number'].toString() + " profile_picture_idx : " + friendRequest['profile_picture_idx'].toString());
//                        developer.log("# description : " + friendRequest['description'].toString() + " business_card_idx : " + friendRequest['business_card_idx'].toString());
                    }
                }
            } else {
                developer.log("# No friend request");
                friendRequestList = <FriendRequestInfo>[];
            }

        } else {
            developer.log("# Server request failed.");
            friendRequestList = <FriendRequestInfo>[];
        }
        notifyListeners();
    }

}
