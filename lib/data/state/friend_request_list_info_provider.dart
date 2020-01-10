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

                    if(!['5101','5102'].contains(tempFriendRequestList[i]['response_type']) && !tempFriendRequestList[i]['is_cancel']){
                        friendRequestList.add(
                            FriendRequestInfo(
                                req_idx: tempFriendRequestList[i]['idx'],
                                user_idx: friendRequest['user_idx'],
                                nickname: friendRequest['nickname'],
                                phone_number: friendRequest['phone_number'],
                                profile_picture_idx: friendRequest['profile_picture_idx'] ?? 0,
                                business_card_idx: friendRequest['business_card_idx'] ?? 0,
                                user_status: friendRequest['user_status'],
                                description: friendRequest['description']
                            )
                        );
                        developer.log("# req_idx : " + tempFriendRequestList[i]['idx'].toString());
                        developer.log("# user_idx : " + friendRequest['user_idx'].toString() + " nickname : " + friendRequest['nickname'].toString());
                        developer.log("# phone_number : " + friendRequest['phone_number'].toString() + " profile_picture_idx : " + friendRequest['profile_picture_idx'].toString());
                        developer.log("# description : " + friendRequest['description'].toString() + " business_card_idx : " + friendRequest['business_card_idx'].toString());
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

    /*
     * @author : sh
     * @date : 2020-01-08
     * @description : 친구요청 목록 추가
     */
    addFriendRequest(Map data) async {
        friendRequestList.add(
            FriendRequestInfo(
                req_idx: int.parse(data['request_idx']),
                user_idx: int.parse(data['user_idx']),
                nickname: data['nickname'],
                phone_number: data['phone_number'],
                profile_picture_idx: int.parse(data['profile_picture_idx'] ?? "0"),
                business_card_idx: int.parse(data['business_card_idx'] ?? "0"),
                user_status: data['user_status'],
                description: data['description']
            )
        );
        notifyListeners();
    }

}
