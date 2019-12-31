import 'dart:convert';

import 'dart:developer' as developer;

import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/models/chat_join_info.dart';
import 'package:Hwa/data/models/chat_list_item.dart';
import 'package:Hwa/pages/chatroom_page.dart';
import 'package:Hwa/pages/parts/tab_app_bar.dart';
import 'package:Hwa/service/get_time_difference.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatTab extends StatefulWidget {
  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
    double sameSize;
    SharedPreferences prefs;

    List<ChatListItem> chatList = <ChatListItem>[];

    bool isLoading;

    @override
    void initState() {
	    super.initState();
	    _getChatList();

	    sameSize = GetSameSize().main();
	    isLoading = false;
    }

    /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 채팅 리스트 받아오기 API 호출
    */
    void _getChatList() async {
      try {
          String uri = "/danhwa/list";

          final response =
          await CallApi.messageApiCall(method: HTTP_METHOD.get, url: uri);
          ChatListItem chatInfo;
          Map<String, dynamic> jsonParse;

          for (var info in json.decode(response.body)) {
              jsonParse = info;
              chatInfo = new ChatListItem.fromJSON(jsonParse);
              // 채팅 리스트에 추가
              chatList.add(chatInfo);
          }

          setState(() {});
      } catch (e) {
          print("#### Error :: " + e.toString());
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
            String uri =
              "/danhwa/roomDetail?roomIdx=" + chatIdx.toString();
            final response = await CallApi.messageApiCall(method: HTTP_METHOD.get, url: uri);

            Map<String, dynamic> jsonParse = json.decode(response.body);
            // 단화방 입장
            _enterChat(jsonParse);
        } catch (e) {
            print("#### Error :: " + e.toString());
        }
    }

    /*
       * @author : hs
       * @date : 2019-12-28
       * @description : 단화방 입장 파라미터 처리
      */
    void _enterChat(Map<String, dynamic> chatInfoJson) async {
        List<ChatJoinInfo> chatJoinInfo = <ChatJoinInfo>[];

        try {
            ChatInfo chatInfo = new ChatInfo.fromJSON(chatInfoJson['danhwaRoom']);
            bool isLiked = chatInfoJson['isLiked'];
            int likeCount = chatInfoJson['danhwaLikeCount'];

            setState(() {
            isLoading = false;
            });

            Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ChatroomPage(
                    chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount, joinInfo: chatJoinInfo, isFromMain: false
                );
            }));

            isLoading = false;

        } catch (e) {
            print("#### Error :: " + e.toString());
        }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          backgroundColor: Color.fromRGBO(214, 214, 214, 1),
          appBar: TabAppBar(title: '참여했던 단화방', leftChild: Container(height: 0)),
          body: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(16),
              ),
              child: Column(
                  children: <Widget>[
                      // 채팅 리스트
                      buildChatList(),
                  ],
              ),
          )
      );
    }

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

    Widget buildChatItem(ChatListItem chatListItem, bool isLastItem) {
        return InkWell(
            child: Container(
                height: ScreenUtil().setHeight(82),
                width: ScreenUtil().setWidth(343),
                margin: EdgeInsets.only(
                    top: ScreenUtil().setHeight(10),
                    bottom: isLastItem ? ScreenUtil().setHeight(10) : 0
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(14),
                    vertical: ScreenUtil().setWidth(16),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                                new BorderRadius.circular(ScreenUtil().setWidth(10)),
                            child: Image.asset(
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Container(
                                          constraints: BoxConstraints(
                                              maxWidth: ScreenUtil().setWidth(190)),
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
                                                                color: Color.fromRGBO(107, 107, 107,1),
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
	                                                chatListItem.lastMsg.chatTime != null ? GetTimeDifference.timeDifference(chatListItem.lastMsg.chatTime) : "메시지 없음",
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
