import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/data/models/friend_info.dart';


/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-30
 * @description : 친구목록 provider model
 */

class FriendListInfoProvider with ChangeNotifier{
    List<FriendInfo> friendList = <FriendInfo>[];

    setFriendInfo(dynamic value) {
        notifyListeners();
    }

    FriendListInfoProvider({
        this.friendList
    });

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 친구목록이 Provider에 api call 하여 저장
    */
    Future<void> getFriendList () async {
        String uri = "/api/v2/relation/relationship/all";
        final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);

        if(response != null){
            if(jsonDecode(response.body)['data'].toString() != '[]'){
                developer.log("# Set friend list");

                List<dynamic> tempFriendList = jsonDecode(response.body)['data'];
                for(var i = 0; i < tempFriendList.length; i++){
                    var friendInfo = tempFriendList[i]['related_user_data'];

                    friendList.add(
                        FriendInfo(
                            user_idx: friendInfo['user_idx'],
                            nickname: friendInfo['nickname'],
                            phone_number: friendInfo['phone_number'],
                            profile_picture_idx: friendInfo['profile_picture_idx'],
                            business_card_idx: friendInfo['business_card_idx'],
                            user_status: friendInfo['user_status'],
                            description: friendInfo['description']
                        )
                    );

                    developer.log("# user_idx : " + friendInfo['user_idx'].toString() + " nickname : " + friendInfo['nickname'].toString());
                    developer.log("# phone_number : " + friendInfo['phone_number'].toString() + " profile_picture_idx : " + friendInfo['profile_picture_idx'].toString());
                    developer.log("# business_card_idx : " + friendInfo['business_card_idx'].toString() + " description : " + friendInfo['description'].toString());
                }
            } else {
                developer.log("# No friend");
                friendList = <FriendInfo>[];
            }
        } else {
            developer.log("# Server request failed.");
            friendList = <FriendInfo>[];
        }
        notifyListeners();
    }

    /*
     * @author : sh
     * @date : 2020-01-08
     * @description : 친구 수락
     */
    addFriend(Map data) async {
        friendList.add(
            FriendInfo(
                user_idx: int.parse(data['user_idx'].toString()),
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
