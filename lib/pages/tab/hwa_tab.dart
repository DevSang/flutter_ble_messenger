import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:developer' as developer;

import 'package:Hwa/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class HwaTab extends StatefulWidget {
  @override
  _HwaTabState createState() => _HwaTabState();
}

class _HwaTabState extends State<HwaTab> {
    SharedPreferences prefs;
    List<ChatListItem> chatList = <ChatListItem>[];
    ChatInfo chatInfo;
    double sameSize;
    TextEditingController _textFieldController;
    bool isLoading;

    // GPS 관련
    Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
    Position _currentPosition;
    String _currentAddress = '위치 검색중..';

    // BLE 관련
    final _beacons = <Beacon>[];
    final StreamController<BluetoothState> streamController = StreamController();
    StreamSubscription<BluetoothState> _streamBluetooth;
    StreamSubscription<RangingResult> _streamRanging;
    StreamSubscription<MonitoringResult> _streamMonitoring;
    String _platformVersion = 'Unknown';
    BeaconStatus _beaconStatus;
    AuthorizationStatus _authorizationStatus;
    BluetoothState _bluetoothState;
    bool _ranging = false;
    bool _monitoring = false;

    @override
    void initState() async {
        super.initState();

        await Constant.setUserIdx();

        // BLE Scanning API 초기화
        HwaBeacon().initializeScanning();
        // BLE Status 초기화
        _initBleStatus();

        isLoading = false;
        sameSize  = GetSameSize().main();
        _textFieldController = TextEditingController(text: '스타벅스 강남R점');

        // 현재 위치 검색
        _getCurrentLocation();

        // TODO: 주변 채팅 리스트 받아오기
        _getChatList();
    }

    @override
    void dispose() {
        super.dispose();
        HwaBeacon().stopRanging();
    }

    /*
     * @author : hk
     * @date : 2019-12-29
     * @description : 위치정보 검색
     */
    _getCurrentLocation() async {
    	print("# start get location.");
	    GeolocationStatus geolocationStatus  = await geolocator.checkGeolocationPermissionStatus();

	    if(geolocationStatus == GeolocationStatus.denied || geolocationStatus == GeolocationStatus.disabled){
		    print("# GeolocationPermission denied. " + geolocationStatus.toString());
		    // TODO 화면에 GPS 켜달라고 피드백, 디자인 적용
		    setState(() {
			    _currentAddress = '위치정보 권한이 필요합니다.';
		    });

	    }else{
	    	print("# getCurrentPosition");
		    Position position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

		    print(position.toString());

		    List<Placemark> placemark = await geolocator.placemarkFromCoordinates(position.latitude, position.longitude);

		    if(placemark != null && placemark.length > 0){
			    Placemark p = placemark[0];

			    // TODO 삭제
			    print(p.toJson().toString());

			    // TODO 디자인 적용
			    setState(() {
				    _currentAddress = '${p.locality} ${p.subLocality} ${p.thoroughfare}';
			    });
		    }
	    }
    }


    /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 채팅 리스트 API 요청
    */
    void _getChatList() {
//        testGetChatList.forEach((itemId) => _getChatItem(itemId));
//        _getChatItem(18);
    }

    /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 채팅 리스트 받아오기 API 호출
    */
    void _getChatItem(int chatIdx) async {
        try {
            String uri = "/danhwa/room?roomIdx=" + chatIdx.toString();

            final response = await CallApi.messageApiCall(method: HTTP_METHOD.get, url: uri);

            Map<String, dynamic> jsonParse = json.decode(response.body);
            ChatListItem chatInfo = new ChatListItem.fromJSON(jsonParse);

            // 채팅 리스트에 추가
            setState(() {
                chatList.insert(0, chatInfo);
            });

        } catch (e) {
            print("#### Error :: "+ e.toString());
        }
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

            // 채팅 리스트에 추가
//            setState(() {
//                _getChatItem(createdChatIdx);
//            });

            // 단화방 입장
             _enterChat(jsonParse);

        } catch (e) {
            print("#### Error :: "+ e.toString());
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
            });


            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                    return ChatroomPage(chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount);
                })
            );

            isLoading = false;
        } catch (e) {
            print("#### Error :: "+ e.toString());
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
            print("#### Error :: "+ e.toString());
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

    /*
     * @author : hs
     * @date : 2019-12-29
     * @description : BLE Status Initialize
    */
    Future<void> _initBleStatus() async {
        String platformVersion;
        try {
            platformVersion = await HwaBeacon().getPlatformVersion();
        } on PlatformException {
            platformVersion = 'Failed to get platform version.';
        }

        print("platformVersion ::: " + platformVersion.toString());

        BeaconStatus st;
        st = await HwaBeacon().checkTxSupported();

        print("st ::: " + st.toString());

        AuthorizationStatus ast;
        ast = await HwaBeacon().getAuthorizationStatus();

        print("ast ::: " + ast.toString());

        BluetoothState bst = await HwaBeacon().getBluetoothState();

        print("bst ::: " + bst.toString());

        if (!mounted) return;

        setState(() {
            _platformVersion = platformVersion;
            _beaconStatus = st;
            _authorizationStatus = ast;
            _bluetoothState = bst;
        });

        _scanBLE();
    }

    /*
     * @author : hs
     * @date : 2019-12-29
     * @description : BLE Scan
    */
    void _scanBLE() {
        setState(() {
            _streamRanging = HwaBeacon()
                .subscribeRangingHwa()
                .listen((RangingResult result) {
                    print("Scaning!!! " + result.toString());
                if (result != null && result.beacons.isNotEmpty && mounted) {
                    setState(() {
                        _beacons.clear();
                        result.beacons.forEach((beacon) {
                            developer.log("RoomID = ${beacon.roomId}, TTL = ${beacon.ttl}, maj=${beacon.major}, min=${beacon.minor}");
                            _beacons.add(beacon);
                            _getChatItem(beacon.roomId);
                        });
                    });
                }
            });
            HwaBeacon().startRanging();
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: TabAppBar(
                title: '주변 단화방',

                /// AppBar Row 내 요소 하단 정렬을 위한 높이 처리
                leftChild: Container(
                    height: 0
                ),
                rightChild: Row(
                    children: <Widget>[
                        Container(
                            width: sameSize * 22,
                            height: sameSize * 22,
                            margin: EdgeInsets.only(right: 16),
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
            print(e);
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
