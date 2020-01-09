import 'dart:convert';
import 'dart:developer' as developer;
import 'package:Hwa/data/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/models/chat_join_info.dart';
import 'package:Hwa/data/models/chat_list_item.dart';
import 'package:Hwa/pages/chatting/chatroom_page.dart';
import 'package:Hwa/service/get_time_difference.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Hwa/constant.dart';
import 'package:easy_localization/easy_localization.dart';


/*
 * @project : HWA - Mobile
 * @author : hk
 * @date : 2019-12-30
 * @description : Chat page
 */
class ChatTab extends StatefulWidget {
    final Function setCurrentIndex;
    ChatTab({Key key, @required this.setCurrentIndex});

    @override
    _ChatTabState createState() => _ChatTabState(setCurrentIndex:setCurrentIndex);
}

class _ChatTabState extends State<ChatTab> {
    _ChatTabState({Key key, @required this.setCurrentIndex});
    final Function setCurrentIndex;

    double sameSize;
    SharedPreferences prefs;

    List<ChatListItem> chatList = <ChatListItem>[];

    bool isLoading;

    @override
    void initState() {
	    super.initState();
        isLoading = true;
	    _getChatList();
	    sameSize = GetSameSize().main();
    }

    /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 채팅 리스트 받아오기 API 호출
    */
    void _getChatList() async {
        try {
            String uri = "/danhwa/list";

            final response = await CallApi.messageApiCall(method: HTTP_METHOD.get, url: uri);
            ChatListItem chatInfo;
            Map<String, dynamic> jsonParse;

            for (var info in json.decode(response.body)) {
                jsonParse = info;
                chatInfo = new ChatListItem.fromJSON(jsonParse);
                // 채팅 리스트에 추가
                chatList.add(chatInfo);
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
     * @date : 2019-12-28
     * @description : 단화방 입장(리스트에서 클릭)
    */
    void _joinChat(int chatIdx) async {
        setState(() {
          isLoading = true;
        });

        try {
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
       * @date : 2019-12-28
       * @description : 단화방 입장 파라미터 처리
      */
    void _enterChat(Map<String, dynamic> chatInfoJson) async {
        List<ChatJoinInfo> chatJoinInfo = <ChatJoinInfo>[];
        List<ChatMessage> chatMessageList = <ChatMessage>[];

        developer.log("enter function" + chatInfoJson.toString());

        try {
            ChatInfo chatInfo = new ChatInfo.fromJSON(chatInfoJson['danhwaRoom']);
            bool isLiked = chatInfoJson['isLiked'];
            int likeCount = chatInfoJson['danhwaLikeCount'];
            bool alreadyJoined = chatInfoJson['alreadyJoin'];
            String myJoinType;

            if (alreadyJoined) {
                myJoinType = chatInfoJson['myJoinType'];
            }

            for (var joinInfo in chatInfoJson['joinList']) {
                chatJoinInfo.add(new ChatJoinInfo.fromJSON(joinInfo));
            }

            if (chatInfoJson['recentMsg'] != null) {
                for (var recentMsg in chatInfoJson['recentMsg']) {
                    chatMessageList.add(new ChatMessage.fromJSON(recentMsg));
                }
            }

            setState(() {
                isLoading = false;
            });

            Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ChatroomPage(
                    chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount, joinInfo: chatJoinInfo, recentMessageList: chatMessageList, from: "ChatTab", disable: (!alreadyJoined || myJoinType == "ONLINE")
                );
            }));

            isLoading = false;

        } catch (e) {
            developer.log("#### Error :: " + e.toString());
        }
    }

    /*
     * @author : sh
     * @date : 2020-01-01
     * @description : Chat page build 위젯
    */
    @override
    Widget build(BuildContext context) {
      return Scaffold(
          body: setScreen()
      );
    }

    /*
    * @author : sh
    * @date : 2020-01-01
    * @description : 참여했던 대화방 상황별 페이지 반환
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
                                // 채팅 리스트
                                buildChatList(),
                            ],
                        )
                    )
                ]
            );
        } else if (chatList.length == 0 && isLoading == false) {
            return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Stack(
                    children: <Widget>[
                        Positioned(
                            bottom: ScreenUtil().setHeight(50),
                            child: Image.asset("assets/images/background/noChatackgroundImg.png")
                        ),
                        Container(
                            height: ScreenUtil().setHeight(535),
                            width: ScreenUtil().setWidth(375),
                            child: Column(
                                children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.only(
                                            top: ScreenUtil().setHeight(50+89)
                                        ),
                                        child: Text((AppLocalizations.of(context).tr('tabNavigation.chat.noChat')),
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
                                        child: Text((AppLocalizations.of(context).tr('tabNavigation.chat.joinChat')),
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
                                                setCurrentIndex(0);
                                            },
                                            color: Color.fromRGBO(77, 96, 191, 1),
                                            elevation: 0.0,
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                    Text(
                                                        (AppLocalizations.of(context).tr('tabNavigation.chat.searchChat')),
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
                        )
                    ]
                )
            );
        }
    }

    /*
    * @author : sh
    * @date : 2020-01-01
    * @description : 채팅리스트 위젯
    */
    Widget buildChatList() {
        return Container(
            child: Flexible(
                child: ListView.builder(
                    itemCount: chatList.length,
                    itemBuilder: (BuildContext context, int index) =>
                      buildChatItem(chatList[index], (index == chatList.length - 1))
                )
            )
        );
    }

    /*
    * @author : sh
    * @date : 2020-01-01
    * @description : 채팅룸 위젯
    */
    Widget buildChatItem(ChatListItem chatListItem, bool isLastItem) {
        return InkWell(
            child: Container(
                height: ScreenUtil().setHeight(82),
                width: ScreenUtil().setWidth(343),
                margin: EdgeInsets.only(
                    top: ScreenUtil().setHeight(10),
                    bottom: isLastItem ? ScreenUtil().setHeight(10) : 0,
                    left: ScreenUtil().setWidth(16),
                    right: ScreenUtil().setWidth(16)
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(14),
                    vertical: ScreenUtil().setWidth(16),
                ),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(250, 250, 250, 1),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  boxShadow: [
                    new BoxShadow(
                        color: Color.fromRGBO(39, 39, 39, 0.1),
                        offset: new Offset(
                            ScreenUtil().setWidth(0),
                            ScreenUtil().setHeight(5)
                        ),
                        blurRadius: ScreenUtil().setWidth(10))
                  ]),
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
                                borderRadius:
                                    new BorderRadius.circular(
                                        ScreenUtil().setWidth(10)
                                    ),
                                child:
//	                                Image.asset(
//	                                    chatListItem.chatImg ?? "assets/images/icon/thumbnailUnset1.png",
//	                                    width: sameSize * 50,
//	                                    height: sameSize * 50,
//	                                    fit: BoxFit.cover,
//	                                ),
		                            chatListItem.roomImgIdx == null ? Image.asset('assets/images/icon/thumbnailUnset1.png') :
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
                                              maxWidth: ScreenUtil().setWidth(190)),
                                          child: Text(
                                            chatListItem.title.length > 13 ? chatListItem.title.substring(0, 13) + ".." : chatListItem.title,
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
                                      ],
                                    )
                                ),

                                /// 인원 수, 시간
                                Container(
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
                                                                color: Color.fromRGBO(107, 107, 107,1),
                                                                letterSpacing: ScreenUtil().setWidth(-0.33),
                                                            ),
                                                        ),
                                                        Text(
                                                          (AppLocalizations.of(context).tr('tabNavigation.chat.people')),
                                                            style: TextStyle(
                                                                height: 1,
                                                                fontFamily: "NotoSans",
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                                                                color: Color.fromRGBO(107, 107, 107,1),
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
	                                                chatListItem.lastMsg.chatTime != null ? GetTimeDifference.timeDifference(chatListItem.lastMsg.chatTime) : (AppLocalizations.of(context).tr('tabNavigation.chat.noMsg')),
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
}
