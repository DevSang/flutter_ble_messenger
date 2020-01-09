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
    List<FriendInfo> friendList;

    setFriendInfo(dynamic value) {
        notifyListeners();
    }

    FriendListInfoProvider({
        this.friendList
    });

    /*
    * @author : sh
    * @date : 2020-01-08
    * @description : 친구목록이 Store에 없을 경우 api call 하여 저장
    */
    Future<void> getFriendList () async {

        String uri = "/api/v2/relation/relationship/all";
        final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);

        if(response != null ? true : false){
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
            }

            ///LOGGING
            developer.log("# Set friend List");
            friendList.map((friend){
                developer.log("# user_idx : " + friend.user_idx.toString() + " nickname : " + friend.nickname.toString());
                developer.log("# phone_number : " + friend.phone_number.toString() + " profile_picture_idx : " + friend.profile_picture_idx.toString());
                developer.log("# description : " + friend.description.toString() + " business_card_idx : " + friend.business_card_idx.toString()+"\n");
            });

        } else {
            developer.log("# No friend");
            friendList = [];
        }
    }
}
