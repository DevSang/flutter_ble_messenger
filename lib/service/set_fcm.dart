import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';

import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/pages/tab/friend_tab.dart';
import 'package:Hwa/data/models/friend_request_info.dart';
import 'package:Hwa/data/state/friend_request_list_info_provider.dart';

class SetFCM {
    static FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    /*
    * @author : hk
    * @date : 2019-12-21
    * @description : FCM 수신 테스트 코드 삽입, TODO 소스코드 적용, MSG 혹은 API서버 - token 저장 api 연동
    */
    static firebaseCloudMessagingListeners(BuildContext context) async {

        // 푸시 권한 획득 및 token 저장
        if (Platform.isIOS) iOSPermission();


        _firebaseMessaging.onTokenRefresh.listen((token){
        	developer.log("############## _firebaseMessaging.onTokenRefresh. token: $token");
            callPushTokenRequest(token);
        });

        _firebaseMessaging.configure(
            onMessage: (Map<String, dynamic> message) async {
                developer.log('on message $message');
                dynamic data = message['data'];
                developer.log('on data $data');
//                addFriendRequest(data, context);

            },
            onResume: (Map<String, dynamic> message) async {
                developer.log('on resume $message');
            },
            onLaunch: (Map<String, dynamic> message) async {
                developer.log('on launch $message');
            },
        );
    }

    /*
     * @author : sh
     * @date : 2020-01-08
     * @description : 푸쉬토큰 서버에 저장
     */
    static addFirebasePushToken() async {
        _firebaseMessaging.getToken().then((token) async {
            await callPushTokenRequest(token.toString());
        });

    }

    /*
    * @author : hk
    * @date : 2019-12-21
    * @description : FCM 수신 iOS 권한 획득
    */
    static iOSPermission() {
        _firebaseMessaging.requestNotificationPermissions(
            IosNotificationSettings(sound: true, badge: true, alert: true));
        _firebaseMessaging.onIosSettingsRegistered
            .listen((IosNotificationSettings settings) {
        });
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : Save push token function
     */
    static callPushTokenRequest(String pushToken) async {
        try {
            String url = "/api/v2/user/push_token?push_token=" + pushToken;
            final response = await CallApi.commonApiCall(method: HTTP_METHOD.post, url: url);
            if(response != null){
                developer.log("# Push token 저장에 성공하였습니다.");
            } else {
                developer.log('#Request failed：${response.statusCode}');
            }
        } catch (e) {
            developer.log('#Request failed：${e}');
        }
    }

    /*
     * @author : sh
     * @date : 2020-01-08
     * @description : 친구요청 목록 추가
     */
//    static addFriendRequest(Map data, BuildContext ctx) async {
//        FriendRequestListInfoProvider friendRequestListInfoProvider = Provider.of<FriendRequestListInfoProvider>(context , listen: false);
//
//        friendRequestListInfoProvider.friendRequestList.add(
//            FriendRequestInfo(
//                req_idx: int.parse(data['request_idx']),
//                user_idx: int.parse(data['user_idx']),
//                nickname: data['nickname'],
//                phone_number: data['phone_number'],
//                profile_picture_idx: int.parse(data['profile_picture_idx'] ?? "0"),
//                business_card_idx: int.parse(data['business_card_idx'] ?? "0"),
//                user_status: data['user_status'],
//                description: data['description']
//            )
//        );
//    }
}