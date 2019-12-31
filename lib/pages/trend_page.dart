import 'dart:convert';

import 'package:Hwa/data/models/chat_list_item.dart';
import 'package:Hwa/pages/parts/loading.dart';
import 'package:Hwa/service/get_time_difference.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:Hwa/utility/get_same_size.dart';

class TrendPage extends StatefulWidget {
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  bool showSearch;
  double sameSize;
  bool isLoading;

  List<ChatListItem> trendChatList = <ChatListItem>[];
  List<ChatListItem> topTrendChatList = <ChatListItem>[];

  @override
  void initState() {
    super.initState();
    showSearch = false;
    sameSize = GetSameSize().main();
    isLoading = false;
    _getChatList();
  }

  /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 채팅 리스트 받아오기 API 호출
    */
  void _getChatList() async {
      setState(() {
          isLoading = true;
      });

      try {
          String uri = "/danhwa/trend";

          final response = await CallApi.messageApiCall(method: HTTP_METHOD.get, url: uri);
          ChatListItem chatInfo;
          Map<String, dynamic> jsonParse;
          List<dynamic> jsonParseList = json.decode(response.body);

          for (var index = jsonParseList.length; index > 0; index--) {

              print(index.toString() + "##############" + jsonParseList[index - 1].toString());
              chatInfo = new ChatListItem.fromJSON(jsonParseList[index - 1]);

              if (topTrendChatList.length < 2) {
                  // 채팅 리스트에 추가
                  topTrendChatList.add(chatInfo);
              } else {
                  // 채팅 리스트에 추가
                  trendChatList.add(chatInfo);
              }
          }

          setState(() {
              isLoading = false;
          });

      } catch (e) {
          print("#### Error :: " + e.toString());
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
            title: Text(
              "실시간 단화 트랜드",
              style: TextStyle(
                  fontFamily: "NotoSans",
                  color: Color.fromRGBO(39, 39, 39, 1),
                  fontSize: ScreenUtil.getInstance().setSp(16)),
            ),
            brightness: Brightness.light,
            leading: IconButton(
              icon: Image.asset("assets/images/icon/navIconPrev.png"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            actions: <Widget>[
              IconButton(
                icon: Image.asset('assets/images/icon/navIconSearch.png'),
                padding: EdgeInsets.only(right: 16),
                onPressed: () {
                    setState(() {
                        showSearch = true;
                    });
                },
              )
            ],
            elevation: 0.0,
        ),
        body: Stack(
            children: <Widget>[
                Positioned(
                    top: ScreenUtil().setHeight(-72),
                    left: 0,
                    child: Container(
                        width: ScreenUtil().setWidth(375),
                        height: ScreenUtil().setHeight(500),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/images/background/bgGrade.png"),
                                fit: BoxFit.fitHeight,
                            ),
                        ),
                    ),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        // 검색 영역
                        showSearch ? _searchTrend() : Container(),

                        // 상단 탭 영역
                        trendHeader(),

                        // 상단 Top2 영역
                        topChat(),

                        // 하단 단화 리스트
                        chatList()
                    ],
                ),
                isLoading ? Loading() : new Container()
            ],
        ),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
    );
  }

  Widget _searchTrend() {
    return Container(
        height: ScreenUtil().setHeight(48),
        color: Color.fromRGBO(0, 0, 0, 0.2),
        child: Row(
          children: <Widget>[
              Container(
                  width: ScreenUtil().setWidth(314),
                  height: ScreenUtil().setHeight(36),
                  margin: EdgeInsets.only(
                      left: ScreenUtil().setWidth(8)
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white
                  ),
                  child: TextField(
                      style: TextStyle(
                          fontFamily: 'NotoSans',
                          color: Color.fromRGBO(39, 39, 39, 1),
                          fontSize: ScreenUtil().setSp(15),
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          letterSpacing: ScreenUtil().setWidth(-0.75),
                      ),
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              fontFamily: 'NotoSans',
                              color: Color.fromRGBO(39, 39, 39, 0.4),
                              fontSize: ScreenUtil().setSp(15),
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              letterSpacing: ScreenUtil().setWidth(-0.75),
                          ),
                          hintText: "단화방 검색",
                      ),
                  ),
              ),
              InkWell(
                  child: Container(
                      height: ScreenUtil().setHeight(48),
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(13)
                      ),
                      child: Center(
                          child: Text(
                              '취소',
                              style: TextStyle(
                                  height: 1,
                                  fontFamily: 'NotoSans',
                                  color: Color.fromRGBO(39, 39, 39, 1),
                                  fontSize: ScreenUtil().setSp(15),
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: ScreenUtil().setWidth(-0.75),
                              ),
                          )
                      )
                  ),
                  onTap: () {
                      setState(() {
                        showSearch = false;
                      });
                  },
              )
          ],
        )
    );
  }

  Widget trendHeader() {
    return new Container(
        height: ScreenUtil().setHeight(36),
        margin: EdgeInsets.only(
          top: ScreenUtil().setHeight(17),
          bottom: ScreenUtil().setHeight(18 - sameSize*8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              headerTab(1),
              headerTab(2)
          ],
        )
    );
  }

    Widget headerTab(int index) {
        Color tabColor = index == 1
            ? Color.fromRGBO(77, 96, 191, 1)
            : Color.fromRGBO(158, 158, 158, 1);

        Color textColor = index == 1
            ? Color.fromRGBO(77, 96, 191, 1)
            : Color.fromRGBO(107, 107, 107, 1);

        double width = index == 1
            ? 74
            : 87;

        return new Container(
            width: ScreenUtil().setWidth(width),
            height: ScreenUtil().setWidth(36),
            margin: EdgeInsets.only(
                left: index == 2 ? ScreenUtil().setWidth(8) : 0,
            ),
            decoration: BoxDecoration(
                border: Border.all(
                    width: ScreenUtil().setWidth(1),
                    color: tabColor,
                ),
                borderRadius:
                    BorderRadius.all(Radius.circular(ScreenUtil().setWidth(18)))
            ),
            child: Center(
                child: Text(
                    index == 1 ? '전체' : '내 주변',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w500,
                        fontSize: ScreenUtil().setSp(14),
                        letterSpacing: ScreenUtil().setWidth(-0.7),
                        color: textColor
                    ),
                ),
            ),
        );
    }

    Widget topChat() {
        return Container(
            child: Row(
                children: <Widget>[
                    // 1위
                    topTrendChatList.length > 0 ? topChatItem(topTrendChatList[0], true) : Container(),

                    // 2위
                    topTrendChatList.length > 1 ? topChatItem(topTrendChatList[1], false) : Container()
                ],
            )
        );
    }

    Widget topChatItem(ChatListItem trendChatInfo, bool isFirst) {
        return Container(
            width: ScreenUtil().setWidth(isFirst ? 181.5 : 161.5) + sameSize*8,
            height: ScreenUtil().setHeight(190) + sameSize*8,
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(16) - sameSize*8,
                bottom: ScreenUtil().setHeight(5),
            ),
            child: Stack(
                children: <Widget>[
                    Container(
                        width: ScreenUtil().setWidth(isFirst ? 181.5 : 161.5),
                        height: ScreenUtil().setHeight(180),
                        margin: EdgeInsets.only(
                            left: sameSize*8,
                            top: sameSize*8,
                            bottom: ScreenUtil().setHeight(10),
                        ),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 1),
                            borderRadius: isFirst
                                ? BorderRadius.all(
                                Radius.circular(ScreenUtil().setWidth(8))
                            )
                                : BorderRadius.only(
                                bottomLeft:  Radius.circular(ScreenUtil().setWidth(8))
                            )
                            ,
                            boxShadow: [
                                new BoxShadow(
                                    color: Color.fromRGBO(39, 39, 39, 0.1),
                                    offset: new Offset(ScreenUtil().setWidth(0),ScreenUtil().setWidth(5)),
                                    blurRadius: ScreenUtil().setWidth(10)
                                )
                            ]
                        ),
                        child: Column(
                            children: <Widget>[
                                Container(
                                    width: ScreenUtil().setWidth(isFirst ? 181.5 : 161.5),
                                    height: ScreenUtil().setHeight(110),
                                    decoration: BoxDecoration(
                                        color: trendChatInfo.chatImg != null ? Color.fromRGBO(255, 255, 255, 1) : Color.fromRGBO(0, 0, 0, 0.1)
                                        ,
                                        borderRadius: isFirst
                                            ? BorderRadius.only(
                                            topLeft: Radius.circular(ScreenUtil().setWidth(8)),
                                            topRight: Radius.circular(ScreenUtil().setWidth(8))
                                        )
                                            : BorderRadius.circular(0)
                                        ,
                                    ),
                                    child: ClipRRect(
                                        borderRadius: isFirst
                                            ? BorderRadius.only(
                                            topLeft: Radius.circular(ScreenUtil().setWidth(8)),
                                            topRight: Radius.circular(ScreenUtil().setWidth(8))
                                        )
                                            : BorderRadius.circular(0)
                                        ,
                                        child:
                                        Image.asset(
                                            trendChatInfo.chatImg ?? "assets/images/icon/thumbnailUnset1.png",
                                            fit: BoxFit.scaleDown,
                                        ),
                                    ),
                                ),
                                Container(
                                    child: Column(
                                        children: <Widget>[
                                            Container (
                                                width: ScreenUtil().setWidth(151.5),
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: ScreenUtil().setWidth(15),
                                                    vertical: ScreenUtil().setWidth(14.5),
                                                ),
                                                child:
                                                Text(
                                                    trendChatInfo.title,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontFamily: "NotoSans",
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: ScreenUtil().setSp(16),
                                                        letterSpacing: ScreenUtil().setWidth(-0.8),
                                                        color: Color.fromRGBO(39, 39, 39, 1)
                                                    ),
                                                ),
                                            ),
                                            Container(
                                                margin: EdgeInsets.only(
                                                    left: ScreenUtil().setWidth(15),
                                                    right: ScreenUtil().setWidth(isFirst ? 3.5 : 0),
                                                ),
                                                child: Row(
                                                    children:<Widget>[
                                                        getCount(trendChatInfo.userCount.total, true),
                                                        getCount(120, false)
                                                    ]
                                                ),
                                            )
                                        ],
                                    )
                                )
                            ],
                        ),
                    ),
                    Positioned(
                        top:  0,
                        left: 0,
                        child: Container(
                            width: sameSize*34,
                            height: sameSize*34,
                            child: Center(
                                child: Text(
                                    isFirst ? '1' : '2',
                                    style: TextStyle(
                                        fontFamily: "NanumSquare",
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScreenUtil().setSp(15),
                                        letterSpacing: ScreenUtil().setWidth(-0.38),
                                        color: Color.fromRGBO(255, 255, 255, 1)
                                    ),
                                ),
                            ),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(77, 96, 191, 1),
                                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8))),
                                boxShadow: [
                                    new BoxShadow(
                                        color: Color.fromRGBO(39, 39, 39, 0.2),
                                        offset: new Offset(ScreenUtil().setWidth(0),ScreenUtil().setWidth(5)),
                                        blurRadius: ScreenUtil().setWidth(5)
                                    )
                                ]
                            ),
                        ),
                    )
                ],
            )
        );
    }

    Widget getCount(int value, bool isViewCount) {
      return
      Container(
          width: ScreenUtil().setWidth(65),
          margin: EdgeInsets.only(
              right: isViewCount ? ScreenUtil().setWidth(16.5) : ScreenUtil().setWidth(0)
          ),
          child: Row(
              children: <Widget>[
                  Container(
                      width: sameSize*20,
                      height: sameSize*20,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image:AssetImage(
                                  isViewCount ? "assets/images/icon/iconViewCount.png" : "assets/images/icon/iconLikeCount.png"
                              ),
                              fit: BoxFit.cover
                          ),
                      ),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                          left: ScreenUtil().setWidth(4.5),
                      ),
                      child: Text(
                          (value ?? 0).toString(),
                          style: TextStyle(
                              fontFamily: "NanumSquare",
                              fontWeight: FontWeight.w500,
                              fontSize: ScreenUtil().setSp(13),
                              letterSpacing: ScreenUtil().setWidth(-0.32),
                              color: Color.fromRGBO(107, 107, 107, 1)
                          ),
                      ),
                  ),
              ],
          ),
      );
    }

    Widget chatList() {
        return Container(
            child: Flexible(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: trendChatList.length,
                    itemBuilder: (BuildContext context, int index) => buildChatItem(trendChatList[index], index)
                )
            )
        );
    }

    Widget buildChatItem(ChatListItem trendChatInfo, int index) {
        return InkWell(
            child: Container(
                height: ScreenUtil().setHeight(81),
                width: ScreenUtil().setWidth(359),
                margin: EdgeInsets.only(
                    left:ScreenUtil().setWidth(16),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: (ScreenUtil().setHeight(81) - sameSize*50)/2
                ),
                child: Row(
                    children: <Widget>[
                        Container(
                            width:  ScreenUtil().setWidth(89),
                            height: ScreenUtil().setHeight(81),
                            child: Stack(
                                children: <Widget>[
                                    // 단화방 이미지
                                    Container(
                                        width: sameSize * 50,
                                        height: sameSize * 50,
                                        decoration: BoxDecoration(
                                            borderRadius: new BorderRadius.circular(
                                                ScreenUtil().setWidth(10)
                                            ),
                                        ),
                                        margin: EdgeInsets.only(
                                            left: sameSize*25,
                                        ),
                                        child: ClipRRect(
                                            borderRadius: new BorderRadius.circular(
                                                ScreenUtil().setWidth(10)
                                            ),
                                            child:
                                            Image.asset(
                                                trendChatInfo.chatImg ?? "assets/images/icon/thumbnailUnset1.png",
                                                width: sameSize * 50,
                                                height: sameSize * 50,
                                                fit: BoxFit.cover,
                                            ),
                                        )
                                    ),
                                    Positioned(
                                        top:  sameSize*10,
                                        left: 0,
                                        child: Container(
                                            width: sameSize*29,
                                            height: sameSize*29,
                                            child: Center(
                                                child: Text(
                                                    (index + 3).toString(),
                                                    style: TextStyle(
                                                        fontFamily: "NanumSquare",
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: ScreenUtil().setSp(13),
                                                        letterSpacing: ScreenUtil().setWidth(-0.32),
                                                        color: Color.fromRGBO(255, 255, 255, 1)
                                                    ),
                                                ),
                                            ),
                                            decoration: BoxDecoration(
                                                color: Color.fromRGBO(77, 96, 191, 1),
                                                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8))),
                                                boxShadow: [
                                                    new BoxShadow(
                                                        color: Color.fromRGBO(39, 39, 39, 0.2),
                                                        offset: new Offset(ScreenUtil().setWidth(0),ScreenUtil().setWidth(5)),
                                                        blurRadius: ScreenUtil().setWidth(5)
                                                    )
                                                ]
                                            ),
                                        ),
                                    )
                                ],
                            )
                        ),
                        // 단화방 정보
                        Container(
                            width: ScreenUtil().setWidth(205),
                            padding: EdgeInsets.only(
                                top: sameSize * 5,
                                bottom: sameSize * 2,
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    /// 정보
                                    Container(
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .end,
                                            children: <Widget>[
                                                Container(
                                                    constraints: BoxConstraints(
                                                        maxWidth: ScreenUtil().setWidth(190)
                                                    ),
                                                    child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(
                                                            trendChatInfo.title,
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
                                            ],
                                        )
                                    ),

                                    /// 인원 수, 시간
                                    Container(
                                        width: ScreenUtil().setWidth(205),
                                        height: ScreenUtil().setHeight(12),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        right:ScreenUtil().setHeight(10),
                                                    ),
                                                    padding: EdgeInsets.only(
                                                        right:ScreenUtil().setHeight(12),
                                                    ),
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                            right: BorderSide(
                                                                width: ScreenUtil().setWidth(1),
                                                                color: Color.fromRGBO(194, 194, 194, 1)
                                                            )
                                                        )
                                                    ),
                                                    child: Row(
                                                        children: <Widget>[
                                                            Text(
                                                                (trendChatInfo.userCount.total ?? 0).toString(),
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
                                                        trendChatInfo.lastMsg.chatTime != null ? GetTimeDifference.timeDifference(trendChatInfo.lastMsg.chatTime) : "메시지 없음",
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
                        ),
                        // 좋아요
                        Container(
                            width: ScreenUtil().setWidth(65),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    Container(
                                        width: sameSize*20,
                                        height: sameSize*20,
                                        margin: EdgeInsets.only(
                                            bottom: sameSize*2.5
                                        ),
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image:AssetImage(
                                                    "assets/images/icon/iconLikeCount.png"
                                                ),
                                                fit: BoxFit.cover
                                            ),
                                        ),
                                    ),
                                    Container(
                                        child: Text(
                                            index.toString(),
                                            style: TextStyle(
                                                fontFamily: "NanumSquare",
                                                fontWeight: FontWeight.w500,
                                                fontSize: ScreenUtil().setSp(13),
                                                letterSpacing: ScreenUtil().setWidth(-0.32),
                                                color: Color.fromRGBO(107, 107, 107, 1)
                                            ),
                                        ),
                                    ),
                                ],
                            )
                        )
                    ],
                )
            ),
            onTap: () {},
        );
    }
}
