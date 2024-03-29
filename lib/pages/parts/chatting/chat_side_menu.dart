import 'dart:developer' as developer;


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Hwa/constant.dart';
import 'package:Hwa/service/stomp_client.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/get_same_size.dart';

import 'package:Hwa/pages/parts/chatting/chat_user_list.dart';
import 'package:Hwa/pages/chatting/chatroom_setting.dart';
import 'package:Hwa/pages/parts/common/bottom_navigation.dart';
import 'package:Hwa/pages/chatting/notice_page.dart';

import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/models/chat_join_info.dart';

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-26
 * @description : 단화방 사이드 메뉴
 */
class ChatSideMenu extends StatefulWidget {
    final ChatInfo chatInfo;
    final bool isCreated;
    bool isLiked;
    int likeCount;
    final List<ChatJoinInfo> chatJoinInfoList;
    final List<ChatJoinInfo> joinedUserNow;
    final StompClient sc;
    final String from;
    ChatSideMenu({Key key, @required this.chatInfo, this.isCreated, this.isLiked, this.likeCount, this.chatJoinInfoList, this.joinedUserNow, this.sc, this.from});

    @override
    State createState() => new ChatSideMenuState(chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount, chatJoinInfoList: chatJoinInfoList, joinedUserNow: joinedUserNow);
}


class ChatSideMenuState extends State<ChatSideMenu> {
    ChatSideMenuState({Key key, @required this.chatInfo, this.isLiked, this.likeCount, this.chatJoinInfoList, this.joinedUserNow});

    final ChatInfo chatInfo;
    bool isCreated;
    bool isLiked;
    int likeCount;
    double sameSize;
    final List<ChatJoinInfo> chatJoinInfoList;
    final List<ChatJoinInfo> joinedUserNow;

    List<ChatJoinInfo> userInfoListBle = <ChatJoinInfo>[];
    List<ChatJoinInfo> userInfoListBleOut = <ChatJoinInfo>[];
    List<ChatJoinInfo> userInfoListOnline  = <ChatJoinInfo>[];

    @override
    void initState() {
        _initState();
        super.initState();
        isCreated = widget.isCreated ?? false;
        sameSize = GetSameSize().main();
        _getChatJoinInfo();
    }

    //TODO like 관련 없애기 , async 해제 (_initState아예 없애두댐)
    void _initState() async {
        SharedPreferences spf = await Constant.getSPF();
        bool spfIsLiked = spf.getStringList("likeRoomList").contains(chatInfo.chatIdx.toString());

        print('isLiked : $isLiked');
        print('spfIsLiked : $spfIsLiked');

        if(isLiked != spfIsLiked){
            if(spfIsLiked) likeCount++;
            else likeCount--;
        }

        setState(() {
            isLiked = spf.getStringList("likeRoomList").contains(chatInfo.chatIdx.toString());
        });

    }

    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : 단화방 정보 받아오기
    */
    void _getChatJoinInfo() async {

        if (chatJoinInfoList != null && chatJoinInfoList.length > 0) {
            for(var chatJoinInfo in chatJoinInfoList) {
                switch(chatJoinInfo.joinType) {
                    case "BLE_JOIN": userInfoListBle.add(chatJoinInfo);
                        break;
                    case "BLE_OUT": userInfoListBleOut.add(chatJoinInfo);
                        break;
                    case "ONLINE": userInfoListOnline.add(chatJoinInfo);
                        break;
                }
            }
        }

        if (joinedUserNow.length > 0) {
            for(var chatJoinInfo in joinedUserNow) {
                switch(chatJoinInfo.joinType) {
                    case "BLE_JOIN": userInfoListBle.add(chatJoinInfo);
                    break;
                    case "BLE_OUT": userInfoListBleOut.add(chatJoinInfo);
                    break;
                    case "ONLINE": userInfoListOnline.add(chatJoinInfo);
                    break;
                }
            }
        }

        setState(() { });
    }


    /*
     * @author : hs
     * @date : 2019-12-29
     * @description : 단화방 좋아요
     * TODO 좋아요 SPF 저장 없애기
     * TODO API call 성공시에 likeCount 올려야 될듯
    */
    void _likeChat() async {
        SharedPreferences spf = await Constant.getSPF();
        List<String> likeRoomList = spf.getStringList("likeRoomList") ?? [];

        setState(() {
            likeCount++;
        });

        try {
            /// 참여 타입 수정
            String uri = "/danhwa/like?roomIdx=" + chatInfo.chatIdx.toString();
            final response = await CallApi.messageApiCall(method: HTTP_METHOD.post, url: uri);

            likeRoomList.add(chatInfo.chatIdx.toString());
            spf.setStringList("likeRoomList", likeRoomList);

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    /*
     * @author : hs
     * @date : 2019-12-29
     * @description : 단화방 좋아요 취소
    */
    void _unLikeChat() async {
        SharedPreferences spf = await Constant.getSPF();
        List<String> likeRoomList = spf.getStringList("likeRoomList") ?? [];

        setState(() {
            likeCount--;
        });

        try {
            /// 참여 타입 수정
            String uri = "/danhwa/likeCancel?roomIdx=" + chatInfo.chatIdx.toString();
            final response = await CallApi.messageApiCall(method: HTTP_METHOD.post, url: uri);

            likeRoomList.removeWhere((idx) => idx == chatInfo.chatIdx.toString());
            spf.setStringList("likeRoomList", likeRoomList);
        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    /*
     * @author : hs
     * @date : 2019-12-31
     * @description : 단화방 나가기
    */
    void quitChat() async {

        try {
            /// 참여 타입 수정
            String uri = "/danhwa/out?roomIdx=" + chatInfo.chatIdx.toString();
            final response = await CallApi.messageApiCall(method: HTTP_METHOD.post, url: uri);

            developer.log("quit" + response.body);

            widget.sc.disconnect();

            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                    int activeTab;

                    if (widget.from == 'HwaTab') {
                        activeTab = 0;
                    }
                    else {
                        activeTab = 2;
                    }

                    return BottomNavigation(activeIndex: activeTab);
                })
            );

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }


    @override
    Widget build(BuildContext context) {

        return
        new SizedBox(
            width: ScreenUtil().setWidth(310),
            child: Drawer(
                child: Column(
                    children: <Widget>[
                        Container(
                            color: Color.fromRGBO(255, 255, 255, 1),
                            height: ScreenUtil().setHeight(72),
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(20)
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    Container(
                                        width: ScreenUtil().setWidth(174),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                                Container (
                                                    margin: EdgeInsets.only(
                                                        top: ScreenUtil().setHeight(14.5),
                                                        bottom: ScreenUtil().setHeight(10)
                                                    ),
                                                    child: Row(
                                                        children: <Widget>[
                                                            Text(
                                                                chatInfo.title.length > 13 ? chatInfo.title.substring(0, 13) + ".." : chatInfo.title,
                                                                style: TextStyle(
                                                                    height: 1,
                                                                    fontFamily: 'NotoSans',
                                                                    fontWeight: FontWeight.w700,
                                                                    fontSize: ScreenUtil().setSp(16),
                                                                    letterSpacing: ScreenUtil().setWidth(-0.8),
                                                                    color: Color.fromRGBO(39, 39, 39, 1)
                                                                ),
                                                            ),
//                                                            Container(
//                                                                height: ScreenUtil().setHeight(12),
//                                                                padding: EdgeInsets.only(
//                                                                    left: ScreenUtil().setWidth(11.5),
//                                                                ),
//                                                                child: Text(
//                                                                    chatInfo.userCount.total.toString(),
//                                                                    style: TextStyle(
//                                                                        height: 1,
//                                                                        fontSize: ScreenUtil().setSp(13),
//                                                                        letterSpacing: ScreenUtil().setWidth(-0.33),
//                                                                        color: Color.fromRGBO(107, 107, 107, 1)
//                                                                    ),
//                                                                ),
//                                                            ),
                                                        ],
                                                    ),
                                                ),
//                                                Container (
//                                                    child: Text(
//                                                        chatInfo.intro ?? "단화방 정보가 없습니다.",
//                                                        style: TextStyle(
//                                                            height: 1,
//                                                            fontSize: ScreenUtil().setSp(13),
//                                                            letterSpacing: ScreenUtil().setWidth(-0.33),
//                                                            color: Color.fromRGBO(107, 107, 107, 1)
//                                                        ),
//                                                    ),
//                                                )
                                            ],
                                        )
                                    ),
                                    Container(
                                        width: ScreenUtil().setWidth(57.5),
                                        height: ScreenUtil().setHeight(72),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                                Container(
                                                    width: ScreenUtil().setWidth(25.5),
                                                    height: ScreenUtil().setHeight(32),
                                                    margin: EdgeInsets.only(
                                                        top: ScreenUtil().setHeight(10),
                                                        bottom: ScreenUtil().setHeight(4)
                                                    ),
                                                    child: Container(
                                                        width: ScreenUtil().setWidth(25.5),
                                                        height: ScreenUtil().setHeight(18.6),
                                                        margin: EdgeInsets.only(
                                                            top: ScreenUtil().setHeight(9.9)
                                                        ),
                                                        decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                                image: AssetImage(
                                                                    "assets/images/icon/howmanyIcon.png",
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                                Container(
                                                    child:
                                                    Text(
                                                        chatInfo.userCount != null
                                                            ? isCreated
                                                                ? (joinedUserNow.length).toString()
                                                                : (chatInfo.userCount.total + joinedUserNow.length).toString()
                                                            : chatInfo.mode == "P_TO_P"
                                                                ? 2.toString()
                                                                : 0,

                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontFamily: 'NotoSans',
                                                            fontWeight: FontWeight.w500,
                                                            color:Color.fromRGBO(107, 107, 107, 1),
                                                            fontSize: ScreenUtil().setSp(12.5),
                                                            letterSpacing: ScreenUtil().setWidth(-0.33)
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        )
                                    ),
                                    GestureDetector(
                                        child: Container(
                                            width: ScreenUtil().setWidth(58),
                                            height: ScreenUtil().setHeight(72),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                    Container(
                                                        width: ScreenUtil().setHeight(32),
                                                        height: ScreenUtil().setHeight(32),
                                                        margin: EdgeInsets.only(
                                                            top: ScreenUtil().setHeight(10),
                                                            bottom: ScreenUtil().setHeight(4)
                                                        ),
                                                        decoration: isLiked ?? false
                                                                        ? likeChat(context)
                                                                        : unlikeChat(context),
                                                    ),
                                                    Container(
                                                        child:
                                                        Text(
                                                            (likeCount ?? 0).toString(),
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                fontFamily: 'NotoSans',
                                                                fontWeight: FontWeight.w500,
                                                                letterSpacing: ScreenUtil().setWidth(-0.33),
                                                                color:Color.fromRGBO(107, 107, 107, 1),
                                                                fontSize: ScreenUtil().setSp(12.5),
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            )
                                        ),
                                        onTap:(){
                                            setState(() {
                                                isLiked = !isLiked;
                                            });

                                            isLiked
                                                ? _likeChat()
                                                : _unLikeChat();
                                        }
                                    )
                                ],
                            )
                        ),
                        Flexible(
                            child: ListView(
                                children: <Widget>[
                                    ChatUserList(userInfoList: userInfoListBle, joinType: "BLE_JOIN", hostIdx: chatInfo.createUserIdx),
                                    ChatUserList(userInfoList: userInfoListBleOut, joinType: "BLE_OUT", hostIdx: chatInfo.createUserIdx),
                                    ChatUserList(userInfoList: userInfoListOnline, joinType: "ONLINE", hostIdx: chatInfo.createUserIdx),
                                ],
                            ),
                        ),
                        Container(
                            width: ScreenUtil().setWidth(310),
                            height: sameSize*48,
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(14),
                              right: ScreenUtil().setWidth(14)
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        width: ScreenUtil().setWidth(1),
                                        color: Color.fromRGBO(39, 39, 39, 0.15)
                                    )
                                ),
                                color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    InkWell(
                                        child: Container(
                                            width: sameSize*28,
                                            height: sameSize*28,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image:AssetImage("assets/images/icon/iconExit.png")
                                                ),
                                            )
                                        ),
                                        onTap: () {
                                            quitChat();
                                        },
                                    ),
                                    Row(
                                        children: <Widget>[
                                            InkWell(
                                                child: Container(
                                                    width: sameSize*28,
                                                    height: sameSize*28,
                                                    margin: EdgeInsets.only(
                                                        right: ScreenUtil().setWidth(10)
                                                    ),
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image:AssetImage("assets/images/icon/iconBell.png")
                                                        ),
                                                    )
                                                ),
                                                onTap: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(builder: (context) {
                                                            return NoticePage(chatInfo: chatInfo);
                                                        })
                                                    );
                                                },
                                            ),
                                            Constant.USER_IDX == chatInfo.createUser.userIdx
                                                ? InkWell(
                                                child: Container(
                                                    width: sameSize*28,
                                                    height: sameSize*28,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image:AssetImage("assets/images/icon/iconSetting.png")
                                                        ),
                                                    )
                                                ),
                                                onTap: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(builder: (context) {
                                                            return ChatroomSettingPage(chatInfo: chatInfo);
                                                        })
                                                    );
                                                },
                                            )
                                                : Container()
                                        ],
                                    )
                                ],
                            ),
                        )
                    ],
                )
            )
        );
    }


    @override
    BoxDecoration unlikeChat(BuildContext context) {
        return BoxDecoration(
            color: Color.fromRGBO(153, 153, 153, 1),
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconLike.png")
            ),
            shape: BoxShape.circle,
            boxShadow: [
                new BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.16),
                    blurRadius: ScreenUtil().setWidth(3), // has the effect of softening the shadow
                    spreadRadius: ScreenUtil().setWidth(0),
                    offset: new Offset(0, ScreenUtil().setHeight(1.5))
                )
            ]
        );

    }

    @override
    BoxDecoration likeChat(BuildContext context) {
        return BoxDecoration(
            color: Color.fromRGBO(221, 54, 67, 1),
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconLike.png")
            ),
            shape: BoxShape.circle,
            boxShadow: [
                new BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.16),
                    blurRadius: ScreenUtil().setWidth(3), // has the effect of softening the shadow
                    spreadRadius: ScreenUtil().setWidth(0),
                    offset: new Offset(0, ScreenUtil().setHeight(1.5))
                )
            ]
        );

    }

}