import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

import 'package:Hwa/utility/call_api.dart';


class SetFCM {
    static FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    /*
    * @author : hk
    * @date : 2019-12-21
    * @description : FCM 수신 테스트 코드 삽입, TODO 소스코드 적용, MSG 혹은 API서버 - token 저장 api 연동
    */
    static firebaseCloudMessagingListeners() async {

        // 푸시 권한 획득 및 token 저장
        if (Platform.isIOS) iOSPermission();

        _firebaseMessaging.getToken().then((token) async {
            await addPushTokenRequest(token.toString());
        });

        _firebaseMessaging.configure(
            onMessage: (Map<String, dynamic> message) async {
                developer.log('on message $message');
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
    static addPushTokenRequest(String pushToken) async {
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
}