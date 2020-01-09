import 'dart:convert';
import 'dart:developer' as developer;

import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/models/chat_join_info.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/data/models/trend_chat_list_item.dart';
import 'package:Hwa/pages/chatting/chatroom_page.dart';
import 'package:Hwa/pages/parts/common/loading.dart';
import 'package:Hwa/service/get_time_difference.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/customRoute.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:Hwa/utility/get_same_size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Hwa/constant.dart';


class TrendPage extends StatefulWidget {
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  bool showSearch;
  double sameSize;
  bool isLoading;

  List<TrendChatListItem> trendChatList = <TrendChatListItem>[];
  List<TrendChatListItem> topTrendChatList = <TrendChatListItem>[];

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
          TrendChatListItem chatInfo;
          List<dynamic> jsonParseList = json.decode(response.body);

          for (var index = jsonParseList.length; index > 0; index--) {
              chatInfo = new TrendChatListItem.fromJSON(jsonParseList[index - 1]);

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
          developer.log("#### Error :: " + e.toString());
      }
  }

  /*
   * @author : hs
   * @date : 2020-01-01
   * @description : 단화방 조인
  */
  void _joinChat(int chatIdx) async {
      setState(() {
          isLoading = true;
      });

      try {
          /// 참여 타입 수정
          String uri = "/danhwa/join?roomIdx=" + chatIdx.toString() + "&type=ONLINE";
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
   * @date : 2020-01-01
   * @description : 단화방 입장
  */
  void _enterChat(Map<String, dynamic> chatInfoJson) {
      List<ChatJoinInfo> chatJoinInfo = <ChatJoinInfo>[];
      List<ChatMessage> chatMessageList = <ChatMessage>[];

      try {
          ChatInfo chatInfo = new ChatInfo.fromJSON(chatInfoJson['danhwaRoom']);
          bool isLiked = chatInfoJson['isLiked'];
          int likeCount = chatInfoJson['danhwaLikeCount'];
          bool alreadyJoined = chatInfoJson['alreadyJoin'];
          String myJoinType;

          if (alreadyJoined) {
              myJoinType = chatInfoJson['myJoinType'];
          }


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

          setState(() {
              isLoading = false;
          });

          Navigator.push(context,
              CustomRoute(builder: (context) {
                  return ChatroomPage(chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount, joinInfo: chatJoinInfo, recentMessageList: chatMessageList, from: "Trend", disable: (!alreadyJoined || myJoinType == "ONLINE"));
              })
          );

          isLoading = false;
      } catch (e) {
          developer.log("#### Error :: "+ e.toString());
      }
  }

  /*
     * @author : hs
     * @date : 2019-12-29
     * @description : 단화방 좋아요
    */
  void _likeChat(List<TrendChatListItem> chatList, int listIdx) async {

      try {
          /// 참여 타입 수정
          String uri = "/danhwa/like?roomIdx=" + chatList[listIdx].chatIdx.toString();
          final response = await CallApi.messageApiCall(method: HTTP_METHOD.post, url: uri);

          developer.log(response.body);

          setState(() {
              chatList[listIdx].isLiked = true;
              chatList[listIdx].likeCount++;
          });

      } catch (e) {
          developer.log("#### Error :: "+ e.toString());
      }
  }

  /*
     * @author : hs
     * @date : 2019-12-29
     * @description : 단화방 좋아요 취소
    */
  void _unLikeChat(List<TrendChatListItem> chatList, int listIdx) async {

      try {
          /// 참여 타입 수정
          String uri = "/danhwa/likeCancel?roomIdx=" + chatList[listIdx].chatIdx.toString();
          final response = await CallApi.messageApiCall(method: HTTP_METHOD.post, url: uri);

          developer.log(response.body);

          setState(() {
              chatList[listIdx].isLiked = false;
              chatList[listIdx].likeCount--;
          });

      } catch (e) {
          developer.log("#### Error :: "+ e.toString());
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
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
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        Container(
                            color: Color.fromRGBO(240, 240, 240, 1),
                            child: Column(
                                children: <Widget>[
                                    // 검색 영역
                                    showSearch ? _searchTrend() : Container(),

                                    // 상단 탭 영역
                                    trendHeader(),

                                    // 상단 Top2 영역
                                    topChat(),
                                ],
                            )
                        ),

                        // 하단 단화 리스트
                        chatList()
                    ],
                ),
                isLoading ? Loading() : new Container()
            ],
        ),
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
//              headerTab(2)
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

    Widget topChatItem(TrendChatListItem trendChatInfo, bool isFirst) {
        int index = isFirst ? 0 : 1;
        return InkWell(
            child: Container(
                width: ScreenUtil().setWidth(163.5) + sameSize*8,
                height: ScreenUtil().setHeight(190) + sameSize*8,
                margin: EdgeInsets.only(
                    left: ScreenUtil().setWidth(16) - sameSize*8,
                    bottom: ScreenUtil().setHeight(5),
                ),
                child: Stack(
                    children: <Widget>[
                        Container(
                            width: ScreenUtil().setWidth(163.5),
                            height: ScreenUtil().setHeight(180),
                            margin: EdgeInsets.only(
                                left: sameSize*8,
                                top: sameSize*8,
                            ),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(ScreenUtil().setWidth(8))
                                ),
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
                                        width: ScreenUtil().setWidth(163.5),
                                        height: ScreenUtil().setHeight(110),
                                        decoration: BoxDecoration(
                                            color: trendChatInfo.chatImg != null ? Color.fromRGBO(255, 255, 255, 1) : Color.fromRGBO(0, 0, 0, 0.02)
                                            ,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(ScreenUtil().setWidth(8)),
                                                topRight: Radius.circular(ScreenUtil().setWidth(8))
                                            ),
                                        ),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(ScreenUtil().setWidth(8)),
                                                topRight: Radius.circular(ScreenUtil().setWidth(8))
                                            ),
                                            child:
//                                            Image.asset(
//                                                trendChatInfo.chatImg ?? "assets/images/icon/thumbnailUnset1.png",
//                                                fit: BoxFit.scaleDown,
//                                            ),
		                                        CachedNetworkImage(
				                                        imageUrl: Constant.API_SERVER_HTTP + "/api/v2/chat/profile/image?type=SMALL&chat_idx=" + trendChatInfo.chatIdx.toString(),
				                                        placeholder: (context, url) => Image.asset('assets/images/icon/thumbnailUnset1.png'),
				                                        errorWidget: (context, url, error) => Image.asset('assets/images/icon/thumbnailUnset1.png'),
				                                        httpHeaders: Constant.HEADER, fit: BoxFit.fill
		                                        )
                                        ),
                                    ),
                                    Container(
                                        child: Column(
                                            children: <Widget>[
                                                Container (
                                                    width: ScreenUtil().setWidth(143.5),
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal: ScreenUtil().setWidth(10),
                                                        vertical: sameSize*14.5,
                                                    ),
                                                    child:
                                                    Text(
                                                        trendChatInfo.title.length > 15 ? trendChatInfo.title.substring(0, 15) + "..." : trendChatInfo.title,
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontFamily: "NotoSans",
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: ScreenUtil().setSp(16),
                                                            letterSpacing: ScreenUtil().setWidth(-0.8),
                                                            color: Color.fromRGBO(39, 39, 39, 1)
                                                        ),
                                                    ),
                                                ),
                                                Container(
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal: ScreenUtil().setWidth(10),
                                                    ),
                                                    child: Row(
                                                        children:<Widget>[
                                                            getCount(topTrendChatList, index, true),
                                                            getCount(topTrendChatList, index, false)
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
            ),
            onTap: () {
                _joinChat(trendChatInfo.chatIdx);
            }
        );
    }

    Widget getCount(List<TrendChatListItem> chatList, int index, bool isViewCount) {
      return
      InkWell(
          child: Container(
              width: ScreenUtil().setWidth(71.75),
              padding: EdgeInsets.only(
                  left: isViewCount ? ScreenUtil().setWidth(0) : ScreenUtil().setWidth(4.75)
              ),
              child: Row(
                  children: <Widget>[
                      Container(
                          width: sameSize*20,
                          height: sameSize*20,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:AssetImage(
                                      isViewCount
                                          ? "assets/images/icon/iconViewCount.png"
                                          : chatList[index].isLiked
                                                ? "assets/images/icon/iconHeartRed.png"
                                                : "assets/images/icon/iconLikeCount.png"
                                  ),
                                  fit: BoxFit.contain
                              ),
                          ),
                      ),
                      Container(
                          margin: EdgeInsets.only(
                              left: ScreenUtil().setWidth(4.5),
                          ),
                          child: Text(
                              isViewCount ? chatList[index].userCount.total.toString() : chatList[index].likeCount.toString(),
                              style: TextStyle(
                                  height: 1,
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
          ),
          onTap: () {
              chatList[index].isLiked ? _unLikeChat(chatList, index) : _likeChat(chatList, index);
          },
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

    Widget buildChatItem(TrendChatListItem trendChatInfo, int index) {
        return InkWell(
            child: Container(
                width: ScreenUtil().setWidth(375),
                height: ScreenUtil().setHeight(81),
                padding: EdgeInsets.only(
                    left:ScreenUtil().setWidth(16),
                ),
                child: Stack(
                    children: <Widget>[
                        Container(
                            width: ScreenUtil().setWidth(334),
                            height: ScreenUtil().setHeight(81),
                            margin: EdgeInsets.only(
                                left:ScreenUtil().setWidth(25),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: (ScreenUtil().setHeight(81) - sameSize*50)/2
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: ScreenUtil().setWidth(1),
                                        color: Color.fromRGBO(39, 39, 39, 0.15)
                                    )
                                )
                            ),
                            child: Row(
                                children: <Widget>[
                                    Container(
                                        width: sameSize * 50,
                                        height: sameSize * 50,
                                        decoration: BoxDecoration(
                                            borderRadius: new BorderRadius.circular(
                                                ScreenUtil().setWidth(10)
                                            ),
                                        ),
                                        margin: EdgeInsets.only(
                                            right: ScreenUtil().setWidth(14.5),
                                        ),
                                        child: ClipRRect(
                                            borderRadius: new BorderRadius.circular(
                                                ScreenUtil().setWidth(10)
                                            ),
                                            child:
//                                            Image.asset(
//                                                trendChatInfo.chatImg ?? "assets/images/icon/thumbnailUnset1.png",
//                                                width: sameSize * 50,
//                                                height: sameSize * 50,
//                                                fit: BoxFit.cover,
//                                            ),
		                                        CachedNetworkImage(
				                                        imageUrl: Constant.API_SERVER_HTTP + "/api/v2/chat/profile/image?type=SMALL&chat_idx=" + trendChatInfo.chatIdx.toString(),
				                                        placeholder: (context, url) => Image.asset('assets/images/icon/thumbnailUnset1.png'),
				                                        errorWidget: (context, url, error) => Image.asset('assets/images/icon/thumbnailUnset1.png'),
				                                        httpHeaders: Constant.HEADER, fit: BoxFit.fill
		                                        )
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
                                                                        trendChatInfo.title.length > 13 ? trendChatInfo.title.substring(0, 13) + "..." : trendChatInfo.title,
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
                                    InkWell(
                                        child: Container(
                                            width: ScreenUtil().setWidth(64),
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
                                                                    trendChatList[index].isLiked
                                                                        ? "assets/images/icon/iconHeartRed.png"
                                                                        : "assets/images/icon/iconLikeCount.png"
                                                                ),
                                                                fit: BoxFit.contain
                                                            ),
                                                        ),
                                                    ),
                                                    Container(
                                                        child: Text(
                                                            trendChatInfo.likeCount.toString(),
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
                                        ),
                                        onTap: () {
                                            trendChatList[index].isLiked ? _unLikeChat(trendChatList, index) : _likeChat(trendChatList, index);
                                        },
                                    )
                                ],
                            ),
                        ),
                        Positioned(
                            top:  (ScreenUtil().setHeight(81) - sameSize*29)/2,
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
                ),
            ),
            onTap: () {
                _joinChat(trendChatInfo.chatIdx);
            },
        );
    }
}
