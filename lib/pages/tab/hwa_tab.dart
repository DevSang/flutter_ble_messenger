import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:hwa_beacon/hwa_beacon.dart';
import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/models/chat_list_item.dart';
import 'package:Hwa/data/models/chat_join_info.dart';
import 'package:Hwa/pages/chatting/chatroom_page.dart';
import 'package:Hwa/pages/parts/common/loading.dart';
import 'package:Hwa/pages/trend/trend_page.dart';
import 'package:Hwa/service/get_time_difference.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/pages/profile/profile_page.dart';
import 'package:Hwa/utility/customRoute.dart';
import 'package:Hwa/utility/custom_dialog.dart';
import 'package:Hwa/animate/rotate.dart';


/*
 * @project : HWA - Mobile
 * @author : hk
 * @date : 2019-12-30
 * @description : HWA 메인 Tab 화면
 */
class HwaTab extends StatefulWidget {
	HwaTab({Key key}) : super(key: key);

	@override
	HwaTabState createState() => HwaTabState();
}

class HwaTabState extends State<HwaTab>  with TickerProviderStateMixin {

    SharedPreferences prefs;
    List<ChatListItem> chatList = <ChatListItem>[];
    List<int> chatIdxList = <int>[];
    List<int> requiredChatIdxList = <int>[];
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
    String _currentAddress;

    // 사용자 GPS, BLE 권한 관련
    bool isAllowedGPS = true;
    bool isAuthGPS = true;

    bool isAllowedBLE = true;
    bool isAuthBLE = true;

    bool isBeaconSupport = false;
    bool isRefreshLocation = false;

    //Animation설정
    AnimationController _animationController;
    Animation<double> _animation;
    Animation<int> _stringAnimation;

    @override
    void initState() {
        _initState();
        isLoading = false;
        sameSize  = GetSameSize().main();
        super.initState();

        _animationController = new AnimationController(
            vsync: this,
            duration: Duration(seconds: 3),
        );
        _animation = Tween(begin: 0.0, end: 40.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));
        _stringAnimation = new StepTween(begin:0 , end: 4).animate(new CurvedAnimation(parent: _animationController, curve: Curves.ease));
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
					    if (!requiredChatIdxList.contains(beacon.roomId))  {
						    _setChatItem(beacon.roomId);
					    } else {
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
    * @description : 단화방 정보 받아오기 API 호출
    */
    void _setChatItem(int chatIdx) async {
        // 요청중인 단화 리스트에 추가
        requiredChatIdxList.add(chatIdx);

	    try {
		    String uri = "/danhwa/room?roomIdx=" + chatIdx.toString();

		    final response = await CallApi.messageApiCall(method: HTTP_METHOD.get, url: uri);

		    Map<String, dynamic> jsonParse = json.decode(response.body);
		    ChatListItem chatItem = new ChatListItem.fromJSON(jsonParse);
		    chatItem.adReceiveTs = new DateTime.now().millisecondsSinceEpoch;

		    // 채팅 리스트에 추가
		    setState(() {
                chatIdxList.insert(0, chatIdx);
			    chatList.insert(0, chatItem);
		    });
	    } catch (e) {
		    developer.log("#### Error :: "+ e.toString());
	    }

        requiredChatIdxList.removeWhere((item)=>item == chatIdx);
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
//        _animationController.forward();
        _animationController.repeat();
        developer.log("# start GpsService!");
        setState(() {
            _currentAddress = AppLocalizations.of(context).tr('tabNavigation.hwa.createRoom.searchLocation');
        });

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
        developer.log("# finish GpsService!");

        _animationController.stop();
        _animationController.reset();
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

            UserInfoProvider userInfo = Provider.of<UserInfoProvider>(context, listen: false);
            int profileImgIdx = userInfo.profilePictureIdx;

            // 방 생성시에 만든 사용자 프로필사진 넣어줌
            jsonParse['danhwaRoom']['createUser']['profile_picture_idx'] = profileImgIdx;

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
            });

            exitPage();

            Navigator.push(
                context,
                CustomRoute(builder: (context) {
                    return ChatroomPage(chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount, joinInfo: chatJoinInfo, recentMessageList: chatMessageList, from: "HwaTab", isCreated: isCreated);
                }),
            ).then((onValue) {
                startBleService();
            });

//            Navigator.push(context,
//                MaterialPageRoute(builder: (context) {
//                    return ChatroomPage(chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount, joinInfo: chatJoinInfo, recentMessageList: chatMessageList, from: "HwaTab", isCreated: isCreated);
//                })
//            ).then((onValue) {
//                startBleService();
//            });

            isLoading = false;
        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    /*
       * @author : hs
       * @date : 2019-12-28
       * @description : 프로필 설정 입장
      */
    void enterProfile() async {
        exitPage();

        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
                return ProfilePage();
            })
        ).then((val) {
            comebackPage();
        });
    }

    /*
       * @author : hs
       * @date : 2019-12-28
       * @description : 트렌드 입장
      */
    void enterTrend() async {
        exitPage();

        Navigator.push(
            context, MaterialPageRoute(
            builder: (context) => TrendPage()
            )
        ).then((val) {
            comebackPage();
        });
    }

    /*
     * @author : hs
     * @date : 2020-01-11
     * @description : 타 페이지로 이동시 기능 처리
    */
    void exitPage() async {
        setState(() {
            HwaBeacon().stopRanging();
            stopOldChatRemoveTimer();
            chatList.clear();
            chatIdxList.clear();
            _textFieldController.text = _currentAddress != null ? '$_currentAddress' : '';
        });
    }

    /*
     * @author : hs
     * @date : 2020-01-11
     * @description : 타 페이지에서 돌아올 시 기능 처리
    */
    void comebackPage() async {
        startBleService();
        checkGpsBleAndStartService();
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
    void displayDialog() async {
        return showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
                title: (AppLocalizations.of(context).tr('tabNavigation.hwa.createRoom.title')),
                type: 1,
                leftButtonText: (AppLocalizations.of(context).tr('tabNavigation.hwa.createRoom.cancel')),
                rightButtonText: (AppLocalizations.of(context).tr('tabNavigation.hwa.createRoom.create')),
                value: _currentAddress,
                hintText: _currentAddress != null
                            ? _currentAddress == (AppLocalizations.of(context).tr('tabNavigation.hwa.createRoom.searchLocation'))
                                ? (AppLocalizations.of(context).tr('tabNavigation.hwa.createRoom.pleaseRoomName'))
                                : _currentAddress
                            : '단화방 제목을 입력해 주세요'
                ,
                maxLength: 15,
            ),
        ).then((onValue){
            if (onValue != null) {
                _createChat(onValue);
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: setScreen(),
            resizeToAvoidBottomPadding: false,
            backgroundColor: chatList.length != 0 ? Color.fromRGBO(255, 255, 255, 1) : Color.fromRGBO(250, 250, 250, 1)
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
            String titleText =(AppLocalizations.of(context).tr('tabNavigation.hwa.main.roomFlag.titleText'));
            String subTitle =(AppLocalizations.of(context).tr('tabNavigation.hwa.main.roomFlag.subTitle'));
            String buttonText = (AppLocalizations.of(context).tr('tabNavigation.hwa.main.roomFlag.buttonText'));
            Function buttonClick = displayDialog;


            if(noRoomFlag){
                mainBackImg = "assets/images/background/noRoomBackgroundImg.png";
                titleText= (AppLocalizations.of(context).tr('tabNavigation.hwa.main.roomFlag.titleText'));
                subTitle=(AppLocalizations.of(context).tr('tabNavigation.hwa.main.roomFlag.subTitle'));
                buttonText=(AppLocalizations.of(context).tr('tabNavigation.hwa.main.roomFlag.buttonText'));
                buttonClick = displayDialog;
            } else if(!isAuthBLE) {
                mainBackImg = "assets/images/background/noBleBackgroundImg.png";
                titleText= (AppLocalizations.of(context).tr('tabNavigation.hwa.main.authBle.titleText'));
                subTitle=(AppLocalizations.of(context).tr('tabNavigation.hwa.main.authBle.subTitle'));
                buttonText=(AppLocalizations.of(context).tr('tabNavigation.hwa.main.authBle.buttonText'));
                buttonClick = HwaBeacon().openBluetoothSettings;

                if(!isAllowedBLE) {
                    titleText= (AppLocalizations.of(context).tr('tabNavigation.hwa.main.allowedBle.titleText'));
                    subTitle=(AppLocalizations.of(context).tr('tabNavigation.hwa.main.allowedBle.subTitle'));
                    buttonText=(AppLocalizations.of(context).tr('tabNavigation.hwa.main.allowedBle.buttonText'));
                    buttonClick = HwaBeacon().openBluetoothSettings;
                }
            } else if(!isAuthGPS){
                mainBackImg = "assets/images/background/noLocationBackgroundImg.png";
                titleText= (AppLocalizations.of(context).tr('tabNavigation.hwa.main.authGps.titleText'));
                subTitle=(AppLocalizations.of(context).tr('tabNavigation.hwa.main.authGps.subTitle'));
                buttonText=(AppLocalizations.of(context).tr('tabNavigation.hwa.main.authGps.buttonText'));
                buttonClick = HwaBeacon().requestAuthorization;

                if(!isAllowedGPS) {
                    titleText= (AppLocalizations.of(context).tr('tabNavigation.hwa.main.allowedGps.titleText'));
                    subTitle=(AppLocalizations.of(context).tr('tabNavigation.hwa.main.allowedGps.subTitle'));
                    buttonText=(AppLocalizations.of(context).tr('tabNavigation.hwa.main.allowedGps.buttonText'));
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
                                        titleText,
                                        style: TextStyle(
                                            fontFamily: 'NotoSans',
                                            color: Color(0xff272727),
                                            fontSize: ScreenUtil().setSp(20),
                                            fontWeight: FontWeight.w700,
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
                                            color: Color.fromRGBO(39, 39, 39, 1),
                                            fontSize: ScreenUtil().setSp(20),
                                            fontWeight: FontWeight.w400,
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
                                            (buttonClick != displayDialog) ? buttonClick() : buttonClick(context);
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
            height: ScreenUtil().setHeight(42),
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(11)),
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
                                      (AppLocalizations.of(context).tr('tabNavigation.hwa.location.nowLocation')),
                                      style: TextStyle(
                                            height: 1,
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight.w400,
                                            fontSize: ScreenUtil().setSp(13),
                                            color: Color.fromRGBO(107, 107, 107, 1),
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
		                            children: <Widget>[
		                                Container(
                                            margin: EdgeInsets.only(right: ScreenUtil().setWidth(6)),
                                            child: AnimatedBuilder(
                                                animation: _animation,
                                                child: Container(child: Image.asset('assets/images/icon/iconRefresh.png')),
                                                builder: (context, child) {
                                                    return Transform.rotate(
                                                        angle: _animation.value,
                                                        child: child,
                                                    );
                                                })
		                                ),
                                        Container(
                                            constraints: BoxConstraints(
                                                maxWidth: ScreenUtil().setWidth(154),
                                                maxHeight: ScreenUtil().setHeight(40)
                                            ),
                                            child: Text(
                                                _currentAddress != null ? '$_currentAddress' : '위치 검색 중 ',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    height: 1,
                                                    fontFamily: "NotoSans",
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: ScreenUtil().setSp(15),
                                                    color: Color.fromRGBO(39, 39, 39, 1),
                                                    letterSpacing: ScreenUtil().setWidth(-0.75),
                                                ),
                                            ),
                                        ),
                                        AnimatedBuilder(
                                            animation: _stringAnimation,
                                            builder: (context, child) {
                                                String text ='.'*_stringAnimation.value;
                                                return  Text(
                                                    text,
                                                    style: TextStyle(
                                                        height: 1,
                                                        fontFamily: "NotoSans",
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: ScreenUtil().setSp(15),
                                                        color: Color.fromRGBO(39, 39, 39, 1),
                                                        letterSpacing: ScreenUtil().setWidth(-0.75),
                                                    ),
                                                );
                                            }
                                        )
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
                  itemBuilder: (BuildContext context, int index) => buildChatItem(index, chatList[index]))
            )
        );
    }

    Widget buildChatItem(int index, ChatListItem chatListItem) {
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
                    color:Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.all(
                        Radius.circular(
                            sameSize*8
                        )
                    ),
                    boxShadow: [
                         BoxShadow(
                            color: Color.fromRGBO(39, 39, 39, 0.1),
                            offset: Offset(
                                ScreenUtil().setWidth(0),
                                ScreenUtil().setHeight(5)
                            ),
                            blurRadius: ScreenUtil().setWidth(10)
                        )
                    ]
                ),
                child: Stack(
                    children: <Widget>[
                        Row(
                            children: <Widget>[
                                // 단화방 이미지
                                Container(
                                    width: ScreenUtil().setWidth(77.5),
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                            width: sameSize*50,
                                            height: sameSize*50,
                                            child: ClipRRect(
                                                borderRadius: new BorderRadius.circular(
                                                    ScreenUtil().setWidth(10)
                                                ),
                                                child:
                                                chatListItem.roomImgIdx == null
                                                    ? Image.asset(
                                                    (index % 2 == 0)
                                                        ? 'assets/images/icon/thumbnailUnset1.png'
                                                        : 'assets/images/icon/thumbnailUnset2.png',

                                                    fit: BoxFit.cover
                                                )
                                                    : CachedNetworkImage(
                                                        imageUrl: Constant.API_SERVER_HTTP + "/api/v2/chat/profile/image?type=SMALL&chat_idx=" + chatListItem.chatIdx.toString(),
                                                        placeholder: (context, url) => Image.asset('assets/images/icon/thumbnailUnset1.png'),
                                                        errorWidget: (context, url, error) => Image.asset('assets/images/icon/thumbnailUnset1.png'),
                                                        httpHeaders: Constant.HEADER,
                                                        fit: BoxFit.cover
                                                )

                                            )
                                        ),
                                    ),
                                ),
                                // 단화방 정보
                                Container(
                                    width: ScreenUtil().setWidth(233),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                            /// 정보, 뱃지
                                            Container(
                                                height: ScreenUtil().setHeight(23.5),
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                        Container(
                                                            constraints: BoxConstraints(
                                                                maxWidth: ScreenUtil().setWidth(190)
                                                            ),
                                                            child: Align(
                                                                alignment: Alignment.centerLeft,
                                                                child: Text(
                                                                    chatListItem.title.length > 15 ? chatListItem.title.substring(0, 15) + "..." : chatListItem.title,
                                                                    style: TextStyle(
                                                                        height: 1,
                                                                        fontFamily: "NotoSans",
                                                                        fontWeight: FontWeight.w500,
                                                                        fontSize: ScreenUtil().setSp(16),
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
                                                height: ScreenUtil().setHeight(19),
                                                margin: EdgeInsets.only(
                                                    top: ScreenUtil().setHeight(6),
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
                                                                            fontSize: ScreenUtil().setSp(13),
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
                                                                            fontSize: ScreenUtil().setSp(13),
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
                                                                    fontSize: ScreenUtil().setSp(13),
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
                        ),
                        Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                                width: ScreenUtil().setWidth(59),
                                height: ScreenUtil().setHeight(28),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(248, 248, 248, 1),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(sameSize*8),
                                        bottomLeft: Radius.circular(sameSize*8),
                                    )
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                        Container(
                                            width: ScreenUtil().setWidth(11.7),
                                            margin: EdgeInsets.only(
                                                left: ScreenUtil().setWidth(9),
                                            ),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        chatListItem.isAlreadyJoin ? 'assets/images/icon/personIconColor.png' : 'assets/images/icon/personIconGrey.png'
                                                    )
                                                )
                                            ),
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(
                                                right: ScreenUtil().setWidth(8),
                                            ),
                                            child: Text(
                                                '참여',
                                                style: TextStyle(
                                                    height: 1,
                                                    fontFamily: "NotoSans",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: ScreenUtil().setSp(12),
                                                    color: chatListItem.isAlreadyJoin ? Color.fromRGBO(78, 78, 78, 1) : Color.fromRGBO(78, 78, 78, 0.25)
                                                ),
                                            )
                                        ),

                                    ],
                                ),
                            )
                        )
                    ],
                )
            ),
            onTap: () => _joinChat(chatListItem.chatIdx),
        );
    }

    Widget popularBadge() {
        Color color = Color.fromRGBO(77, 96, 191, 1);

        return Container(
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
                        fontWeight: FontWeight.w700,
                        fontSize: ScreenUtil().setSp(13),
                        color: color
                    ),
                ),
            ),
        );
    }
}