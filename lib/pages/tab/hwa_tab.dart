import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:developer' as developer;

import 'package:Hwa/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:geolocator/geolocator.dart';
import 'package:hwa_beacon/hwa_beacon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/models/chat_list_item.dart';

import 'package:Hwa/pages/chatroom_page.dart';
import 'package:Hwa/pages/parts/loading.dart';
import 'package:Hwa/pages/parts/tab_app_bar.dart';
import 'package:Hwa/pages/trend_page.dart';

import 'package:Hwa/service/get_time_difference.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/get_same_size.dart';


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
    TextEditingController _textFieldController;
    bool isLoading;

    // 채팅방이 아래 시간 이상 AD를 받지 못하면 리스트에서 삭제 (ms)
    int chatItemRemoveTime = 4000;

    // AD 없는 채팅방 삭제 타이머 반복 시간 (ms)
    int chatItemRemoveTimerDelay = 2000;

    // 채팅방 삭제 타이머
    Timer chatItemRemoveTimer;

    // GPS 관련
    Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
    Position _currentPosition;
    String _currentAddress = '위치 검색중..';


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
        await Constant.setUserIdx();

        // BLE Scanning API 초기화
        await HwaBeacon().initializeScanning();
        developer.log("# HwaBeacon. finish initialize");

        // 비콘 송수신 가능 체크
        // TODO BLE, GPS 상태 종합하여 화면 UI 설정
        BeaconStatus status = await HwaBeacon().checkTxSupported();

        developer.log("## status : " + status.toString());

        // BLE Scan start
        _scanBLE();

        // 현재 위치 검색
        _getCurrentLocation();
    }

    @override
    void dispose() {
	    super.dispose();
	    HwaBeacon().stopRanging();
	    stopOldChatRemoveTimer();
    }

    /*
     * @author : hk
     * @date : 2019-12-29
     * @description : 위치정보 검색
     */
    _getCurrentLocation() async {
	    developer.log("# start get location.");
	    // 현재 위치정보 권한 체크
	    GeolocationStatus geolocationStatus  = await geolocator.checkGeolocationPermissionStatus();

	    if(geolocationStatus == GeolocationStatus.denied || geolocationStatus == GeolocationStatus.disabled){
		    developer.log("# GeolocationPermission denied. " + geolocationStatus.toString());
		    // TODO 화면에 GPS 켜달라고 피드백, 디자인 적용
		    setState(() {
			    _currentAddress = '위치정보 권한이 필요합니다.';
		    });
	    }else{
		    developer.log("# getCurrentPosition");
		    // 현재 위도 경도 찾기, TODO 일부 디바이스에서 Return 이 안되는 문제
		    Position position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

		    // TODO 삭제
		    developer.log(position.toString());

		    // 위도, 경도로 주소지 찾기
		    List<Placemark> placemark = await geolocator.placemarkFromCoordinates(position.latitude, position.longitude);

		    if(placemark != null && placemark.length > 0){
			    Placemark p = placemark[0];

			    // TODO 삭제
			    developer.log(p.toJson().toString());

			    // TODO 디자인 적용
			    setState(() {
				    _currentAddress = '${p.locality} ${p.subLocality} ${p.thoroughfare}';
                    _textFieldController = TextEditingController(text: '$_currentAddress');
			    });
		    }
	    }
    }

    /*
     * @author : hs
     * @date : 2019-12-29
     * @description : BLE Scan
    */
    void _scanBLE() async {
    	// 오래된 채팅방 삭제 타이머 시작
	    startOldChatRemoveTimer();

    	// 비콘 listen 위한 Stream 설정
	    HwaBeacon().subscribeRangingHwa().listen((RangingResult result) {
	    	// TODO 삭제
		    //developer.log("Scaning!!! " + result.toString());
		    if (result != null && result.beacons.isNotEmpty && mounted) {
			    setState(() {
				    result.beacons.forEach((beacon) {
//					    developer.log("RoomID = ${beacon.roomId}, TTL = ${beacon.ttl}, maj=${beacon.major}, min=${beacon.minor}");
//					    developer.log("# chatIdxList : " + chatIdxList.toString());

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
			    });
		    }
	    });

	    // 스캔(비콘 Listen) 시작
	    HwaBeacon().startRanging();
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
	 * @description : 채팅방 삭제 타이머 동작 시작 - 1.5초마다 동작
	 */
    void startOldChatRemoveTimer(){
	    if(chatItemRemoveTimer != null && chatItemRemoveTimer.isActive) chatItemRemoveTimer.cancel();

        chatItemRemoveTimer = Timer.periodic(Duration(milliseconds: chatItemRemoveTimerDelay), (timer) {
            deleteOldChat();
        });
    }

    /*
     * @author : hk
     * @date : 2019-12-30
     * @description : 채팅방 삭제 타이머 동작 멈춤
     */
    void stopOldChatRemoveTimer(){
	    chatItemRemoveTimer.cancel();
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
            int createdChatIdx = jsonParse['danhwaRoom']['roomIdx'];

            // 단화방 입장
            _enterChat(jsonParse);

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    /*
       * @author : hs
       * @date : 2019-12-28
       * @description : 단화방 입장 파라미터 처리
      */
    void _enterChat(Map<String, dynamic> chatInfoJson) async {

        try {
            ChatInfo chatInfo = new ChatInfo.fromJSON(chatInfoJson['danhwaRoom']);
            bool isLiked = chatInfoJson['isLiked'];
            int likeCount = chatInfoJson['danhwaLikeCount'];

            setState(() {
                isLoading = false;
                HwaBeacon().stopRanging();
                stopOldChatRemoveTimer();
                chatList.clear();
                chatIdxList.clear();
            });

            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                    return ChatroomPage(chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount);
                })
            ).then((onValue) {
                _scanBLE();
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
            _enterChat(jsonParse);

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    /*
    * @author : hs
    * @date : 2019-12-27
    * @description : 단화방 생성 Dialog
    */
    void _displayIosDialog(BuildContext context) async {
        return showDialog(
            context: context,
            child: new CupertinoAlertDialog(
                title: Text(
                    '단화 생성하기'
                ),
                content: TextField(
                    controller: _textFieldController,
                    decoration: InputDecoration(

                        /// GPS 연동
                        hintText: _textFieldController.text
                    ),
                ),
                actions: <Widget>[
                    new FlatButton(
                        child: new Text('취소'),
                        onPressed: () {
                            Navigator.of(context).pop();
                        },
                    ),
                    new FlatButton(
                        child: new Text('생성하기'),
                        onPressed: () {
                            _createChat(_textFieldController.text);
                            Navigator.of(context).pop();

                            setState(() {
                                isLoading = true;
                            });

                            _textFieldController.clear();
                        },
                    )
                ]
            )
        );
    }

    /*
    * @author : hs
    * @date : 2019-12-27
    * @description : 단화방 생성 Dialog
    */
    void _displayAndroidDialog(BuildContext context) async {
        return showDialog(
            context: context,
            child: new AlertDialog(
                title: Text(
                    '단화 생성하기'
                ),
                content: TextField(
                    controller: _textFieldController,
                    decoration: InputDecoration(

                        /// GPS 연동
                        hintText: _textFieldController.text
                    ),
                ),
                actions: <Widget>[
                    new FlatButton(
                        child: new Text('취소'),
                        onPressed: () {
                            Navigator.of(context).pop();
                        },
                    ),
                    new FlatButton(
                        child: new Text('생성하기'),
                        onPressed: () {
                            _createChat(_textFieldController.text);
                            Navigator.of(context).pop();

                            setState(() {
                                isLoading = true;
                            });

                            _textFieldController.clear();
                        },
                    )
                ]
            )
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: TabAppBar(
                title: '주변 단화방',
                leftChild: Row(
                    children: <Widget>[
                        Container(
                            width: sameSize * 22,
                            height: sameSize * 22,
                            margin: EdgeInsets.only(left: 16),

                            child: InkWell(
                                child: Image.asset(
                                    'assets/images/icon/navIconHot.png'),
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
                                onTap: () =>
                                {
                                    if (Platform.isAndroid) {
                                        _displayAndroidDialog(context)
                                    } else
                                        if (Platform.isIOS) {
                                            _displayIosDialog(context)
                                        }
                                },
                            )
                        ),
                    ],
                ),
            ),
            body: Stack(
                children: <Widget>[
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(16),
                        ),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(210, 217, 250, 1),
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/background/bgMap.png"),
                                fit: BoxFit.cover,
                            ),
                        ),
                        child: Column(
                            children: <Widget>[
                                // 위치 정보 영역
                                getLocation(),
                                // 채팅 리스트
                                buildChatList(),
                            ],
                        ),
                    ),
                    isLoading ? Loading() : new Container()
                ],
            )
        );
    }

    Widget getLocation() {
        return Container(
            height: ScreenUtil().setHeight(22),
            margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(21),
                bottom: ScreenUtil().setHeight(18),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Container(
                        height: ScreenUtil().setHeight(22),
                        child: Row(
                            children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(8),
                                        right: ScreenUtil().setWidth(4.5),
                                    ),
                                    width: sameSize * 22,
                                    height: sameSize * 22,
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(107, 107, 107, 1),
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/icon/iconPin.png')
                                        ),
                                        shape: BoxShape.circle
                                    ),
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
                                            letterSpacing: ScreenUtil()
                                                .setWidth(-0.33),
                                        ),
                                    ),
                                )
                            ],
                        )
                    ),
                    Container(
                        child: Text(
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

              itemBuilder: (BuildContext context, int index) => buildChatItem(chatList[index])
            )
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
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(14),
                    vertical: ScreenUtil().setWidth(16),
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                        Radius.circular(10.0)
                    ),
                    boxShadow: [
                        new BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            offset: new Offset(ScreenUtil().setWidth(0),
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
                                right: ScreenUtil().setWidth(15),
                            ),
                            child: ClipRRect(
                                borderRadius: new BorderRadius.circular(
                                    ScreenUtil().setWidth(10)
                                ),
                                child:
                                Image.asset(
                                    chatListItem.chatImg,
                                    width: sameSize * 50,
                                    height: sameSize * 50,
                                    fit: BoxFit.cover,
                                ),
                            )
                        ),
                        // 단화방 정보
                        Container(
                            width: ScreenUtil().setWidth(250),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                    /// 정보, 뱃지
                                    Container(
                                        height: ScreenUtil().setHeight(22),
                                        margin: EdgeInsets.only(
                                            top: ScreenUtil().setHeight(1),
                                            bottom: ScreenUtil().setHeight(10),
                                        ),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .end,
                                            children: <Widget>[
                                                Container(
                                                    constraints: BoxConstraints(
                                                        maxWidth: ScreenUtil()
                                                            .setWidth(190)
                                                    ),
                                                    child: Text(
                                                        chatListItem.title,
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontFamily: "NotoSans",
                                                            fontWeight: FontWeight
                                                                .w500,
                                                            fontSize: ScreenUtil(
                                                                allowFontScaling: true)
                                                                .setSp(16),
                                                            color: Color
                                                                .fromRGBO(
                                                                39, 39, 39, 1),
                                                            letterSpacing: ScreenUtil()
                                                                .setWidth(-0.8),
                                                        ),
                                                    ),
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
                                        height: ScreenUtil().setHeight(13),
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
                                                    margin: EdgeInsets.only(
                                                        right: ScreenUtil()
                                                            .setWidth(5),
                                                    ),
                                                    child: Text(
                                                        GetTimeDifference
                                                            .timeDifference(
                                                            chatListItem.lastMsg
                                                                .chatTime),
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontFamily: "NotoSans",
                                                            fontWeight: FontWeight
                                                                .w400,
                                                            fontSize: ScreenUtil(
                                                                allowFontScaling: true)
                                                                .setSp(13),
                                                            color: Color
                                                                .fromRGBO(
                                                                107, 107, 107,
                                                                1),
                                                            letterSpacing: ScreenUtil()
                                                                .setWidth(
                                                                -0.33),
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
