//pub module
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

//import module
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/data/models/chat_join_info.dart';
import 'package:Hwa/pages/parts/chatting/full_photo.dart';
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/pages/parts/chatting/chat_user_info_list.dart';

class ChatUserList extends StatefulWidget {
    final List<ChatJoinInfo> userInfoList;

    final String joinType;
    final int hostIdx;

    ChatUserList({Key key, @required this.userInfoList, this.joinType, this.hostIdx}) : super(key: key);

    @override
    State createState() => new ChatUserListState();
}

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-30
 * @description : 단화방 유저 리스트
 */
class ChatUserListState extends State<ChatUserList> with TickerProviderStateMixin {
    // 현재 채팅 Advertising condition
    bool existList;
    bool openedList;

    //About image
    Future<File> profileImageFile;
    Image imageFromPreferences;

    double sameSize;

    @override
    void initState() {
        super.initState();
        existList = widget.userInfoList.length > 0;
        openedList = existList;
        sameSize = GetSameSize().main();
    }

    /*
    * @author : sh
    * @date : 2020-01-01
    * @description : chat user list build 위젯
    */
    @override
    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 375, height: 667, allowFontScaling: true)..init(context);

        return new Container(
            color: Colors.white,
              // 유저 목록이 존재하면
                child: existList
                ? Column(
                        children: <Widget>[
                            InkWell(
                                child:
                                Container(
                                    width: ScreenUtil().setWidth(310),
                                    height: ScreenUtil().setHeight(28),
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(19),
                                        right:   ScreenUtil().setWidth(16)
                                    ),
                                    decoration:
                                    !openedList && widget.joinType == "ONLINE"
                                        ? BoxDecoration(
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        border: Border(
                                            top: BorderSide(
                                                width: ScreenUtil().setWidth(1),
                                                color: Color.fromRGBO(39, 39, 39, 0.15)
                                            ),
                                            bottom: BorderSide(
                                                width: ScreenUtil().setWidth(1),
                                                color: Color.fromRGBO(235, 235, 235, 1)
                                            ),
                                        )
                                    )
                                        : BoxDecoration(
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        border: Border(
                                            top: BorderSide(
                                                width: ScreenUtil().setWidth(1),
                                                color: Color.fromRGBO(39, 39, 39, 0.15)
                                            ),
                                        )
                                    )
                                    ,
                                    child:
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                            Container(
                                                child: Row(
                                                    children: <Widget>[
                                                        Text(
                                                            widget.joinType == "BLE_JOIN"
                                                                ? "내 주변 사용자"
                                                                : (
                                                                widget.joinType == "BLE_OUT"
                                                                    ? "온라인 사용자"
                                                                    : "관전 사용자"
                                                            ),
                                                            style: TextStyle(
                                                                height: 1,
                                                                fontFamily: 'NotoSans',
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: ScreenUtil().setSp(13),
                                                                letterSpacing: ScreenUtil().setWidth(-0.33),
                                                                color: Color.fromRGBO(39, 39, 39, 1)
                                                            ),
                                                        ),
                                                        Container(
                                                            padding: EdgeInsets.only(
                                                                left: ScreenUtil().setWidth(5),
                                                            ),
                                                            child: Text(
                                                                widget.userInfoList.length.toString(),
                                                                style: TextStyle(
                                                                    height: 1,
                                                                    fontFamily: 'NotoSans',
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: ScreenUtil().setSp(13),
                                                                    letterSpacing: ScreenUtil().setWidth(-0.65),
                                                                    color: Color.fromRGBO(39, 39, 39, 0.4)
                                                                ),
                                                            ),
                                                        ),
                                                    ],
                                                )
                                            ),
                                            Container(
                                                width: ScreenUtil().setWidth(20),
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image:AssetImage(openedList
                                                            ? "assets/images/icon/iconFold.png"
                                                            : "assets/images/icon/iconUnfold.png")
                                                    ),
                                                ),
                                            )
                                        ],
                                    ),
                                ),
                                onTap:(){
                                    setState(() {
                                        openedList = !openedList;
                                    });
                                }
                            ),
                            AnimatedSize(
                                curve: Curves.ease,
                                vsync: this,
                                duration: new Duration(milliseconds: 200),
                                child:
                                openedList
                                ? Container(
                                    child: ListView.builder(
                                        physics: new NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: widget.userInfoList.length,
                                        itemBuilder: (BuildContext context, int index){
                                            return ChatUserInfoList(hostIdx: widget.hostIdx, userInfo: widget.userInfoList[index]);
                                        }
                                    ),
                                )
                                : Container(),
                            )
                        ],
                )
                : Container()
          );
    }
}
