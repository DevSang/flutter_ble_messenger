import 'dart:async';
import 'dart:convert';

import 'dart:io' show Platform;
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:Hwa/constant.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/utility/custom_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:geolocator/geolocator.dart';
import 'package:hwa_beacon/hwa_beacon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/models/chat_list_item.dart';
import 'package:Hwa/data/models/chat_join_info.dart';

import 'package:Hwa/pages/chatting/chatroom_page.dart';
import 'package:Hwa/pages/parts/common/loading.dart';
import 'package:Hwa/pages/parts/common/tab_app_bar.dart';
import 'package:Hwa/pages/trend/trend_page.dart';

import 'package:Hwa/service/get_time_difference.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/get_same_size.dart';

import 'package:cached_network_image/cached_network_image.dart';


/*
 * @project : HWA - Mobile
 * @author : hk
 * @date : 2019-12-30
 * @description : HWA 메인 Tab 화면
 */
class HwaTab extends StatefulWidget {
  @override
  _HwaTabState createState() => _HwaTabState();
}

class _HwaTabState extends State<HwaTab> {
    SharedPreferences prefs;
    List<ChatListItem> chatList = <ChatListItem>[];
    List<int> chatIdxList = <int>[];
    ChatInfo chatInfo;
    double sameSize;
    TextEditingController _textFieldController = TextEditingController();
    bool isLoading;

    // 채팅방이 아래 시간 이상 AD를 받지 못하면 리스트에서 삭제 (ms)
    int chatItemRemoveTime = 4000;

    // AD 없는 채팅방 삭제 타이머 반복 시간 (ms)
    int chatItemRemoveTimerDelay = 2500;

    // GPS, BLE 권한 들어왔는지 체크 타이머 반복 시간 (ms)
    int permitTimerDelay = 1500;

    // 채팅방 삭제, GPS 권한 있는지 체크, BLE 권한 체크 타이머
    Timer _chatItemRemoveTimer;
    Timer _gpsTimer;
    Timer _bleTimer;

    // GPS 관련
    Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
    Position _currentPosition;
    String _currentAddress = '위치 검색 중..';

    // 사용자 GPS, BLE 권한 관련
    bool isAllowedGPS = true;
    bool isAuthGPS = true;

    bool isAllowedBLE = true;
    bool isAuthBLE = true;

    bool isBeaconSupport = false;


    @override
    void initState() {

        super.initState();
        _initState();
        isLoading = false;
        sameSize  = GetSameSize().main();
    }

    /*
     * @author : hk
     * @date : 2019-12-30
     * @description : 내부 초기화 함수. BLE Scan 시작, 현재 내 위치 검색
     */
    void _initState() async {
        // BLE Scanning API 초기화
        if(Platform.isAndroid){
            await HwaBeacon().initializeScanning();
        }

        checkGpsBleAndStartService();
    }

    @override
    void dispose() {
	    super.dispose();
	    // BLE Scanning API 초기화
	    if(Platform.isAndroid){
		    HwaBeacon().stopRanging();
	    }


	    // 모든 타이머 정지
	    stopAllTimer();
    }

    /*
     * @author : hk
     * @date : 2019-12-30
     * @description : GPS와 BLE의 권한을 체크. 권한이 있으면 서비스 시작, 권한 없으면 권한 들어올때까지 타이머 돌며 listen
     */
    void checkGpsBleAndStartService() async {
	    bool gpsStatus = await checkGPS();
	    if(gpsStatus) startGpsService();
	    else {
		    _gpsTimer = Timer.periodic(Duration(milliseconds: permitTimerDelay), (timer) async{
			    bool gpsStatus = await checkGPS();
			    if(gpsStatus) {
				    startGpsService();
				    timer.cancel();
			    }
		    });
	    }

	    bool bleStatus = await checkBLE();
	    if(bleStatus) startBleService();
	    else {
		    _bleTimer = Timer.periodic(Duration(milliseconds: permitTimerDelay), (timer) async{
			    bool bleStatus = await checkBLE();
			    if(bleStatus) {
				    startBleService();
				    timer.cancel();
			    }
		    });
	    }
    }

    /*
     * @author : hk
     * @date : 2019-12-30
     * @description : 현재 위치 서비스 자체 기능 on/off, HWA APP의 위치 서비스 권한 리턴
     */
    Future<GeolocationStatus> getGeolocationStatus() async {
	    GeolocationStatus geolocationStatus  = await geolocator.checkGeolocationPermissionStatus();
	    return geolocationStatus;
    }

    /*
     * @author : hs
     * @date : 2019-12-29
     * @description : BLE Scan
    */
    void _scanBLE() async {
    	// 오래된 채팅방 삭제 타이머 시작
	    startOldChatRemoveTimer();

	    if(Platform.isAndroid){
		    // 비콘 listen 위한 Stream 설정
		    HwaBeacon().subscribeRangingHwa().listen((RangingResult result) {
			    if (result != null && result.beacons.isNotEmpty && mounted) {
				    result.beacons.forEach((beacon) {
					    if (!chatIdxList.contains(beacon.roomId))  {
						    _setChatItem(beacon.roomId);
					    }else {
						    //해당 채팅방이 존재하면 해당 채팅방의 마지막 AD 타임 기록
						    for(ChatListItem chatItem in chatList){
							    if(chatItem.chatIdx == beacon.roomId){
								    chatItem.adReceiveTs = new DateTime.now().millisecondsSinceEpoch;
								    break;
							    }
						    }
					    }
				    });
			    }
		    });

		    // 스캔(비콘 Listen) 시작
		    HwaBeacon().startRanging();
	    }


    }

    /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 채팅 리스트 받아오기 API 호출
    */
    void _setChatItem(int chatIdx) async {
	    try {
		    String uri = "/danhwa/room?roomIdx=" + chatIdx.toString();

		    final response = await CallApi.messageApiCall(method: HTTP_METHOD.get, url: uri);

		    Map<String, dynamic> jsonParse = json.decode(response.body);
		    ChatListItem chatItem = new ChatListItem.fromJSON(jsonParse);
		    chatItem.adReceiveTs = new DateTime.now().millisecondsSinceEpoch;

		    // 채팅 리스트에 추가
		    setState(() {
			    chatList.insert(0, chatItem);
			    chatIdxList.insert(0, chatItem.chatIdx);
		    });

	    } catch (e) {
		    developer.log("#### Error :: "+ e.toString());
	    }
    }

    /*
     * @author : hk
     * @date : 2019-12-30
     * @description : 타이머가 존재, 활성화 중이면 비활성화 시키기
     */
    timerActiveCheckAndCancel(Timer timer){
	    if(timer != null && timer.isActive) timer.cancel();
    }

    /*
     * @author : hk
     * @date : 2019-12-30
     * @description : 타이머가 존재하지 않고, 시작되어 있지 않으면 시작
     */
    timerActiveCheckAndStart(Timer timer, func){
	    if(timer == null || !timer.isActive) timer = Timer.periodic(Duration(milliseconds: permitTimerDelay), (timer) async {
		    func();
	    });
    }

    Future<bool> checkGPS() async {
	    // Location 서비스 켜져있는지 확인
//        bool isLocationAllowed = await HwaBeacon().checkLocationService();


	    if(Platform.isAndroid) {
            bool isLocationAllowed = await HwaBeacon().checkLocationService();
            // 안드로이드 위치 서비스 처리
		    if(isLocationAllowed == false) {
			    isAllowedGPS = false;
                isAuthGPS = false;
                developer.log("# 위치서비스 자체가 꺼져있음!");

			    return false;
		    }else{
			    isAllowedGPS = true;
			    // 위치 서비스 사용 권한
			    AuthorizationStatus authLocation = await HwaBeacon().getAuthorizationStatus();

			    if(authLocation.isAndroid){
				    isAuthGPS = true;
				    developer.log("# 위치서비스, 위치 권한 켜져있음!, Location search Start!");

				    return true;
			    } else{
                    isAuthGPS = false;
				    developer.log("# 위치서비스 켜있지만, 위치 권한이 없음!");
				    return false;
			    }
		    }

	    } else if (Platform.isIOS) {
		    // iOS 위치서비스 처리
		    developer.log("# is iOS!!!");

		    return false;
	    } else {
	    	return false;
	    }
    }

    /*
     * @author : hk
     * @date : 2019-12-31
     * @description : GPS 찾아서 주소 셋팅
     */
    void startGpsService() async {
	    developer.log("# start GpsService!");

	    // 현재 위도 경도 찾기, TODO 일부 디바이스에서 Return 이 안되는 문제
	    Position position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

	    // 위도, 경도로 주소지 찾기
	    List<Placemark> placemark = await geolocator.placemarkFromCoordinates(position.latitude, position.longitude);

	    if(placemark != null && placemark.length > 0){
		    Placemark p = placemark[0];

		    setState(() {
			    _currentAddress = '${p.locality} ${p.subLocality} ${p.thoroughfare}';
			    _textFieldController.text = '$_currentAddress';

		    });
	    }
    }

    /*
     * @author : hk
     * @date : 2019-12-31
     * @description : 현재 블루투스 사용 가능 여부 체크
     */
    Future<bool> checkBLE() async {

	    // Bluetooth 상태 확인
	    BluetoothState bs = await HwaBeacon().getBluetoothState();

	    if (Platform.isAndroid) {
		    // Android BLE 처리
		    if(bs.value == 'STATE_ON'){
			    isAllowedBLE = true;
			    isAuthBLE = true;

			    developer.log("# 블루투스 켜져있음!");
			    BeaconStatus isBS = await HwaBeacon().checkTxSupported();

			    if(isBS != BeaconStatus.SUPPORTED){
				    developer.log("# 블루투스 켜져있으나 비콘 송수신을 지원하지 않음!");
				    return false;
			    }else{
				    return true;
			    }
		    }else{
		        setState(() {
                    isAllowedBLE = false;
                    isAuthBLE = false;
		        });
			    developer.log("# 블루투스 꺼져있음!");
			    return false;
		    }

	    } else if (Platform.isIOS) {
		    // iOS BLE 처리
		    developer.log("# is iOS!!!");
		    return false;
	    } else {
	    	return false;
	    }
    }

    /*
     * @author : hk
     * @date : 2019-12-31
     * @description : 블루투스 서비스 시작. Scan start
     */
    void startBleService(){
	    developer.log("# start BleService!");
	    _scanBLE();
    }

	/*
	 * @author : hk
	 * @date : 2019-12-30
	 * @description : 채팅방 삭제 타이머 동작 시작 - 1.5초마다 동작
	 */
    void startOldChatRemoveTimer(){
	    timerActiveCheckAndCancel(_chatItemRemoveTimer);

	    _chatItemRemoveTimer = Timer.periodic(Duration(milliseconds: chatItemRemoveTimerDelay), (timer) {
            deleteOldChat();
        });
    }

    /*
     * @author : hk
     * @date : 2019-12-30
     * @description : 채팅방 삭제 타이머 동작 멈춤
     */
    void stopOldChatRemoveTimer(){
	    timerActiveCheckAndCancel(_chatItemRemoveTimer);
    }

    /*
     * @author : hk
     * @date : 2019-12-30
     * @description : 현재 페이지에 있는 모든 타이머 스톱
     */
    void stopAllTimer(){
	    timerActiveCheckAndCancel(_chatItemRemoveTimer);
	    timerActiveCheckAndCancel(_gpsTimer);
	    timerActiveCheckAndCancel(_bleTimer);
    }

    /*
     * @author : hk
     * @date : 2019-12-30
     * @description : 채팅방 리스트에서 기준 시간 이상 AD를 받지 못한 아이템 삭제
     */
    void deleteOldChat(){
    	setState(() {
		    int current = new DateTime.now().millisecondsSinceEpoch;
		    if(chatList != null){
			    chatList.retainWhere((chat){
				    if(current - chat.adReceiveTs > chatItemRemoveTime){
					    chatIdxList.remove(chat.chatIdx);
					    return false;
				    }else{
					    return true;
				    }
			    });
		    }
    	});
    }

    /*
    * @author : hs
    * @date : 2019-12-27
    * @description : 단화방 생성 API 호출
    */
    void _createChat(String title) async {
        setState(() {
            isLoading = true;
        });

        try {
            String uri = "/danhwa/room?title=" + title;
            final response = await CallApi.messageApiCall(method: HTTP_METHOD.post, url: uri);

            Map<String, dynamic> jsonParse = json.decode(response.body);

            // 단화방 입장
            _enterChat(jsonParse, true);

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    /*
       * @author : hs
       * @date : 2019-12-28
       * @description : 단화방 입장 파라미터 처리
      */
    void _enterChat(Map<String, dynamic> chatInfoJson, bool isCreated) async {
        List<ChatJoinInfo> chatJoinInfo = <ChatJoinInfo>[];
        List<ChatMessage> chatMessageList = <ChatMessage>[];

        try {
            ChatInfo chatInfo = new ChatInfo.fromJSON(chatInfoJson['danhwaRoom']);
            bool isLiked = chatInfoJson['isLiked'];
            int likeCount = chatInfoJson['danhwaLikeCount'];

            if (!isCreated) {
                try {
                    for (var joinInfo in chatInfoJson['joinList']) {
                        chatJoinInfo.add(new ChatJoinInfo.fromJSON(joinInfo));
                    }

                    for (var recentMsg in chatInfoJson['recentMsg']) {
                        chatMessageList.add(new ChatMessage.fromJSON(recentMsg));
                    }
                } catch (e) {
                    developer.log("#### Error :: "+ e.toString());
                }
            }

            setState(() {
                isLoading = false;
                HwaBeacon().stopRanging();
                stopOldChatRemoveTimer();
                chatList.clear();
                chatIdxList.clear();
                _textFieldController.text = _currentAddress != null ? '$_currentAddress' : '';
            });

            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                    return ChatroomPage(chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount, joinInfo: chatJoinInfo, recentMessageList: chatMessageList, from: "HwaTab", isCreated: isCreated);
                })
            ).then((onValue) {
                startBleService();
            });

            isLoading = false;
        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }


    /*
     * @author : hs
     * @date : 2019-12-28
     * @description : 단화방 입장(리스트에서 클릭)
    */
    void _joinChat(int chatIdx) async {
        setState(() {
            isLoading = true;
        });

        try {
            /// 참여 타입 수정
            String uri = "/danhwa/join?roomIdx=" + chatIdx.toString() + "&type=BLE_JOIN";
            final response = await CallApi.messageApiCall(method: HTTP_METHOD.post, url: uri);

            Map<String, dynamic> jsonParse = json.decode(response.body);
            // 단화방 입장
            _enterChat(jsonParse, false);

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    /*
    * @author : hs
    * @date : 2019-12-27
    * @description : 단화방 생성 Dialog
    */
    void _displayDialog(BuildContext context) async {
        return showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
                title: '단화 생성하기',
                type: 1,
                leftButtonText: "취소",
                rightButtonText: "생성하기",
                value: _currentAddress,
                hintText: _currentAddress == '위치 검색 중..'
                    ? '단화방 이름을 입력해주세요.'
                    : _currentAddress,
                func: (String titleValue) {
                    _createChat(titleValue);
                    Navigator.of(context).pop();

                    setState(() {
                        isLoading = true;
                    });
                },
                maxLength: 15,
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: TabAppBar(
                title: "단화방",
                leftChild: Row(
                    children: <Widget>[
                        Container(
                            width: sameSize * 22,
                            height: sameSize * 22,
                            margin: EdgeInsets.only(left: 16),

                            child: InkWell(
                                child: Image.asset('assets/images/icon/navIconHot.png'),
                                onTap: () =>
                                    Navigator.push(
                                        context, MaterialPageRoute(
                                        builder: (context) => TrendPage())),
                            )
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 16),
                            width: sameSize * 22,
                            height: sameSize * 22,
                            child: InkWell(
                                child: Image.asset(
                                    'assets/images/icon/navIconNew.png'),
                                onTap: (){
                                    _displayDialog(context);
                                }
//                                {
//                                    if (Platform.isAndroid) {
//                                        _displayAndroidDialog(context)
//                                    } else if (Platform.isIOS) {
//                                        _displayIosDialog(context)
//                                    }
//                                },
                                )
                        ),
                    ],
                ),
            ),
            body: setScreen(),
            resizeToAvoidBottomPadding: false,
        );
    }

    /*
    * @author : sh
    * @date : 2019-12-31
    * @description : 메인페이지 상황별 페이지 반환
    */
    Widget setScreen () {
        if(chatList.length != 0) {
            return Stack(
                children: <Widget>[
                    Positioned(
                        bottom: ScreenUtil().setHeight(74.5),
                        right: 0,
                        child: Image.asset(
                            "assets/images/background/commonBackgroundImg.png"),
                    ),
                    Container(
                        child: Column(
                            children: <Widget>[
                                // 위치 정보 영역
                                getLocation(),
                                // 채팅 리스트
                                buildChatList(),
                            ],
                        )
                    )
                ]
            );
        } else if (chatList.length == 0) {
            bool noRoomFlag = (isAllowedBLE && isAllowedGPS && isAuthBLE && isAuthGPS && chatList.length == 0);
//            developer.log("####################################");
//            developer.log("##noRoomFlag : " + noRoomFlag.toString());
//            developer.log("##isAuthBLE : " + isAuthBLE.toString());
//            developer.log("##isAllowedBLE : " + isAllowedBLE.toString());
//            developer.log("##isAuthGPS : " + isAuthGPS.toString());
//            developer.log("##isAllowedGPS : " + isAllowedGPS.toString());
//            developer.log("####################################");

//            developer.log("##chatList.length == 0 : " + (chatList.length == 0).toString());
//            developer.log("##notAllowedBLE : " + notAllowedBLE.toString());
//            developer.log("##notAllowedLoc : " + notAllowedLoc.toString());

            String mainBackImg = "assets/images/background/noRoomBackgroundImg.png";
            String titleText = "현재 위치 단화방이 없습니다.";
            String subTitle = "원하는 방을 만들어 보실래요?";
            String buttonText = "방 만들기";
            Function buttonClick = _displayDialog;
            if(noRoomFlag){
                mainBackImg = "assets/images/background/noRoomBackgroundImg.png";
                titleText= "현재 위치 단화방이 없습니다.";
                subTitle="원하는 방을 만들어 보실래요?";
                buttonText="방 만들기";
                buttonClick = _displayDialog;
            } else if(!isAuthBLE) {
                mainBackImg = "assets/images/background/noBleBackgroundImg.png";
                titleText= "블루투스 권한이 필요합니다.";
                subTitle="설정 > 앱 > 앱 권한";
                buttonText="설정으로 이동";
                buttonClick = HwaBeacon().openBluetoothSettings;

                if(!isAllowedBLE) {
                    titleText= "블루투스가 꺼져있습니다.";
                    subTitle="설정 > 블루투스 켜기";
                    buttonText="설정으로 이동";
                    buttonClick = HwaBeacon().openBluetoothSettings;
                }
            } else if(!isAuthGPS){
                mainBackImg = "assets/images/background/noLocationBackgroundImg.png";
                titleText= "위치 접근 권한이 필요합니다.";
                subTitle="설정 > 앱 > 앱 권한";
                buttonText="설정으로 이동";
                buttonClick = HwaBeacon().requestAuthorization;

                if(!isAllowedGPS) {
                    titleText= "GPS가 꺼져있습니다.";
                    subTitle="설정 > GPS 켜기";
                    buttonText="설정으로 이동";
                    buttonClick = HwaBeacon().openLocationSettings;
                }
            }

            return Stack(
                children: <Widget>[
                    SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                            children: <Widget>[
                                Container(
                                    child: Column(
                                        children: <Widget>[
                                            // 위치 정보 영역
                                            getLocation(),
                                        ],
                                    )
                                ),
                                Container(
                                    margin:EdgeInsets.only(
                                        top: 11 + ScreenUtil().setHeight(35.5),
                                        bottom: ScreenUtil().setHeight(35.5),
                                    ),
                                    child: Image.asset(mainBackImg,
                                        width: ScreenUtil().setWidth(375),
                                    )
                                ),

                                Container(
                                    child:Text(
                                        titleText.length > 15 ? titleText.substring(0, 15) + "..." : titleText,
                                        style: TextStyle(
                                            fontFamily: 'NotoSans',
                                            color: Color(0xff272727),
                                            fontSize: ScreenUtil().setSp(20),
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                            letterSpacing: ScreenUtil().setWidth(-1),
                                        )
                                    )
                                ),
                                Container(
                                    margin: EdgeInsets.only(
                                        top:ScreenUtil().setHeight(10),
                                        bottom:ScreenUtil().setHeight(6),
                                    ),
                                    child: Text(subTitle,
                                        style: TextStyle(
                                            fontFamily: 'NotoSans',
                                            color: Color(0xff6b6b6b),
                                            fontSize: ScreenUtil().setSp(20),
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            letterSpacing: ScreenUtil().setWidth(-1),
                                        )
                                    )
                                ),
                                Container(
                                    width: ScreenUtil().setWidth(319),
                                    height: 44.0,
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                                    child: RaisedButton(
                                        onPressed: (){
                                            (buttonClick != _displayDialog) ? buttonClick() : buttonClick(context);
                                        },
                                        color: Color.fromRGBO(77, 96, 191, 1),
                                        elevation: 0.0,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                                Text(
                                                    buttonText,
                                                    style: TextStyle(
                                                        fontFamily: 'NotoSans',
                                                        color: Colors.white,
                                                        fontSize: ScreenUtil().setSp(16),
                                                        fontWeight: FontWeight.w500,
                                                        letterSpacing: ScreenUtil().setWidth(-0.8),
                                                    )
                                                ),
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        left: 12
                                                    ),
                                                    width: ScreenUtil().setWidth(9),
                                                    height: ScreenUtil().setHeight(15),
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image:AssetImage("assets/images/icon/iconMoreWhite.png"),
                                                            fit: BoxFit.cover
                                                        ),
                                                    ),
                                                )
                                            ],
                                        ),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0)
                                        )
                                    )
                                )
                            ],
                        )
                    ),
                    // Loading
                    isLoading ? Loading() : Container()
                ]
            );
        } else {
            return Loading();
        }
    }

    Widget getLocation() {
        return Container(
            height: ScreenUtil().setHeight(22),
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(21)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
                        height: ScreenUtil().setHeight(22),
                        child: Row(
                            children: <Widget>[
                                Container(
                                    width: sameSize * 22,
                                    height: sameSize * 22,
                                    child: isAllowedBLE ?
                                        Image.asset('assets/images/icon/bluetoothIconConnected.png')
                                        : Image.asset('assets/images/icon/bluetoothIconUnconnected.png')
                                ),
                                Container(
                                    margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(8)),
                                    width: sameSize * 22,
                                    height: sameSize * 22,
                                    child: isAllowedGPS ?
                                        Image.asset('assets/images/icon/gpsIconConnected.png')
                                        :Image.asset('assets/images/icon/gpsIconUnconnected.png')
                                ),
                                Container(
                                    child: Text(
                                        '현재 위치',
                                        style: TextStyle(
                                            height: 1,
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight.w400,
                                            fontSize: ScreenUtil(
                                                allowFontScaling: true).setSp(
                                                13),
                                            color: Color.fromRGBO(
                                                107, 107, 107, 1),
                                            letterSpacing: ScreenUtil().setWidth(-0.33),
                                        ),
                                    ),
                                )
                            ],
                        )
                    ),
                    Container(
                        margin: EdgeInsets.only(right:ScreenUtil().setWidth(16)),
	                    child: InkWell(
	                        child:
		                        Row(
		                            children: <Widget>[
		                                Container(
				                                child: Image.asset('assets/images/icon/iconRefresh.png'),
			                                margin: EdgeInsets.only(right: ScreenUtil().setWidth(6)),
		                                ),
		                                Text(
		                                    '$_currentAddress',
		                                    style: TextStyle(
		                                        height: 1,
		                                        fontFamily: "NotoSans",
		                                        fontWeight: FontWeight.w400,
		                                        fontSize: ScreenUtil(allowFontScaling: true)
		                                            .setSp(15),
		                                        color: Color.fromRGBO(39, 39, 39, 1),
		                                        letterSpacing: ScreenUtil().setWidth(-0.75),
		                                    ),
		                                ),
		                            ]
		                        ),
						    onTap: () => {
							    startGpsService()
						    },
					    ),
                    ),
                ],
            ),
        );
    }

    Widget buildChatList() {
        return Container(
            child: Flexible(
                child: ListView.builder(
                  itemCount: chatList.length,

                  itemBuilder: (BuildContext context, int index) => buildChatItem(chatList[index]))
            )
        );
    }

    Widget buildChatItem(ChatListItem chatListItem) {
        return InkWell(
            child: Container(
                height: ScreenUtil().setHeight(82),
                width: ScreenUtil().setWidth(343),
                margin: EdgeInsets.only(
                    bottom: ScreenUtil().setHeight(10),
                    left:ScreenUtil().setHeight(16),
                    right:ScreenUtil().setHeight(16),
                ),
                decoration: BoxDecoration(
                    color:Color.fromRGBO(250, 250, 250, 1),
                    borderRadius: BorderRadius.all(
                        Radius.circular(10.0)
                    ),
                    boxShadow: [
                        new BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            offset: new Offset(
                                ScreenUtil().setWidth(0),
                                ScreenUtil().setWidth(5)),
                            blurRadius: ScreenUtil().setWidth(10)
                        )
                    ]
                ),
                child: Row(
                    children: <Widget>[
                        // 단화방 이미지
                        Container(
                            width: sameSize * 50,
                            height: sameSize * 50,
                            margin: EdgeInsets.only(
                                left: ScreenUtil().setWidth(13.2),
                            ),
                            child: ClipRRect(
                                borderRadius: new BorderRadius.circular(
                                    ScreenUtil().setWidth(10)
                                ),
                                child:
//	                                Image.asset(
//	                                    chatListItem.chatImg ?? "assets/images/icon/thumbnailUnset1.png",
//	                                    width: sameSize * 50,
//	                                    height: sameSize * 50,
//	                                    fit: BoxFit.cover,
//	                                ),
		                            CachedNetworkImage(
				                            imageUrl: Constant.API_SERVER_HTTP + "/api/v2/chat/profile/image?type=SMALL&chat_idx=" + chatListItem.chatIdx.toString(),
				                            placeholder: (context, url) => Image.asset('assets/images/icon/thumbnailUnset1.png'),
				                            errorWidget: (context, url, error) => Image.asset('assets/images/icon/thumbnailUnset1.png'),
				                            httpHeaders: Constant.HEADER, fit: BoxFit.fill
		                            )
	                            )
                        ),
                        // 단화방 정보
                        Container(
                            width: ScreenUtil().setWidth(260),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    /// 정보, 뱃지
                                    Container(
                                        height: ScreenUtil().setHeight(22),
                                        margin: EdgeInsets.only(
                                            left: ScreenUtil().setHeight(14.1),
                                            top: ScreenUtil().setHeight(17),
                                        ),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .end,
                                            children: <Widget>[
                                                Container(
                                                    height:ScreenUtil().setHeight(23.5),
                                                    constraints: BoxConstraints(
                                                        maxWidth: ScreenUtil().setWidth(190)
                                                    ),
                                                    child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(
                                                            chatListItem.title,
                                                            style: TextStyle(
                                                                height: 1,
                                                                fontFamily: "NotoSans",
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: ScreenUtil(allowFontScaling: true).setSp(16),
                                                                color: Color.fromRGBO(39, 39, 39, 1),
                                                                letterSpacing: ScreenUtil().setWidth(-0.8),
                                                            ),
                                                        ),
                                                    )
                                                ),
                                                // TODO : 인기 정책 변경
                                                (chatListItem.score ?? 0) > 10
                                                    ? popularBadge()
                                                    : Container()
                                            ],
                                        )
                                    ),

                                    /// 인원 수, 시간
                                    Container(
                                        width: ScreenUtil().setWidth(260),
                                        margin: EdgeInsets.only(
                                            left:ScreenUtil().setWidth(14),
                                            top:ScreenUtil().setHeight(6.8),
                                        ),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                                Container(
                                                    child: Row(
                                                        children: <Widget>[
                                                            Text(
                                                                chatListItem.userCount.total.toString(),
                                                                style: TextStyle(
                                                                    height: 1,
                                                                    fontFamily: "NanumSquare",
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                                                                    color: Color.fromRGBO(107,107,107, 1),
                                                                    letterSpacing: ScreenUtil().setWidth(-0.33),
                                                                ),
                                                            ),
                                                            Text(
                                                                '명',
                                                                style: TextStyle(
                                                                    height: 1,
                                                                    fontFamily: "NotoSans",
                                                                    fontWeight: FontWeight.w400,
                                                                    fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                                                                    color: Color.fromRGBO(107,107,107, 1),
                                                                    letterSpacing: ScreenUtil().setWidth(-0.33),
                                                                ),
                                                            ),
                                                        ],
                                                    )
                                                ),
                                                Container(
                                                    child: Text(
                                                        chatListItem.lastMsg.chatTime != null ? GetTimeDifference.timeDifference(chatListItem.lastMsg.chatTime) : '메시지 없음',
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontFamily: "NotoSans",
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                                                            color: Color.fromRGBO(107, 107, 107, 1),
                                                            letterSpacing: ScreenUtil().setWidth(-0.33),
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        )
                                    )
                                ],
                            ),
                        )
                    ],
                )
            ),
            onTap: () => _joinChat(chatListItem.chatIdx),
        );
    }

    _getAddressFromLatLng() async {
        try {
            List<Placemark> p = await geolocator.placemarkFromCoordinates(
                _currentPosition.latitude, _currentPosition.longitude);

            Placemark place = p[0];

            setState(() {
                _currentAddress = "${place.locality}, ${place.postalCode}";
            });
        } catch (e) {
            developer.log(e);
        }
    }

    Widget popularBadge() {
        Color color = Color.fromRGBO(77, 96, 191, 1);

        return new Container(
            width: ScreenUtil().setWidth(43),
            height: ScreenUtil().setHeight(22),
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(2),
            ),
            decoration: BoxDecoration(
                border: Border.all(
                    width: ScreenUtil().setWidth(1),
                    color: color,
                ),
                borderRadius: BorderRadius.all(
                    Radius.circular(ScreenUtil().setWidth(11))
                )
            ),
            child: Center(
                child: Text(
                    '인기',
                    style: TextStyle(
                        height: 1,
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w600,
                        fontSize: ScreenUtil().setSp(13),
                        color: color
                    ),
                ),
            ),
        );
    }
}
