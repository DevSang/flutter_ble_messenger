import 'package:Hwa/pages/trend_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Hwa/service/get_time_difference.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/utility/get_same_size.dart';

import 'package:Hwa/data/models/chat_list_item.dart';
import 'package:Hwa/pages/parts/set_chat_list_data.dart';
import 'package:Hwa/pages/parts/tab_app_bar.dart';

class HwaTab extends StatefulWidget {
  @override
  _HwaTabState createState() => _HwaTabState();
}

class _HwaTabState extends State<HwaTab> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  List<ChatListItem> chatList;
  Position _currentPosition;
  String _currentAddress;
  double sameSize;

  @override
  void initState() {
    super.initState();
    chatList = new SetChaListData().main();
    sameSize  = GetSameSize().main();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: TabAppBar(
        title: '단화방',
        /// AppBar Row 내 요소 하단 정렬을 위한 높이 처리
        leftChild: Container(
            height: 0
        ),
        rightChild: Row(
          children: <Widget>[
            Container(
                width: sameSize*22,
                height: sameSize*22,
                margin: EdgeInsets.only(right: 16),
                child: InkWell(
                  child: Image.asset('assets/images/icon/navIconHot.png'),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => TrendPage())),
                )
            ),
            Container(
                width: sameSize*22,
                height: sameSize*22,
                child: InkWell(
                  child: Image.asset('assets/images/icon/navIconNew.png'),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => TrendPage())),
                )
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
        ),
        decoration: BoxDecoration(
          color: Color.fromRGBO(210, 217, 250, 1),
          image: DecorationImage(
            image: AssetImage("assets/images/background/bgMap.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            // 위치 정보 영역
            getLocation(),

            // 채팅 리스트
            buildChatList()
          ],
        ),
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
                  width: sameSize*22,
                  height: sameSize*22,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(107, 107, 107, 1),
                      image: DecorationImage(
                          image:AssetImage('assets/images/icon/iconPin.png')
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
                      fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                      color: Color.fromRGBO(107, 107, 107, 1),
                      letterSpacing: ScreenUtil().setWidth(-0.33),
                    ),
                  ),
                )
              ],
            )
          ),
          Container(
            child: Text(
              "$_currentAddress",
              style: TextStyle(
                height: 1,
                fontFamily: "NotoSans",
                fontWeight: FontWeight.w400,
                fontSize: ScreenUtil(allowFontScaling: true).setSp(15),
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
    return Container(
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
            offset: new Offset(ScreenUtil().setWidth(0), ScreenUtil().setWidth(5)),
            blurRadius: ScreenUtil().setWidth(10)
          )
        ]
      ),
      child: Row(
        children: <Widget>[
          // 단화방 이미지
          Container(
              width: sameSize*50,
              height: sameSize*50,
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
                  width: sameSize*50,
                  height: sameSize*50,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: ScreenUtil().setWidth(190)
                        ),
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
                      ),
                      chatListItem.isPopular
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
                                chatListItem.count.toString(),
                                style: TextStyle(
                                  height: 1,
                                  fontFamily: "NanumSquare",
                                  fontWeight: FontWeight.w500,
                                  fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                                  color: Color.fromRGBO(107, 107, 107, 1),
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
                                  color: Color.fromRGBO(107, 107, 107, 1),
                                  letterSpacing: ScreenUtil().setWidth(-0.33),
                                ),
                              ),
                            ],
                          )
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          right: ScreenUtil().setWidth(5),
                        ),
                        child: Text(
                          GetTimeDifference.timeDifference(chatListItem.time),
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
    );
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
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
      child: Center (
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
