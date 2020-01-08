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
import 'package:Hwa/package/fullPhoto.dart';
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
class ChatUserListState extends State<ChatUserList> {
    // 현재 채팅 Advertising condition
    bool openedList;

    //About image
    Future<File> profileImageFile;
    Image imageFromPreferences;

    double sameSize;

    @override
    void initState() {
        super.initState();
        openedList = true;
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
              child: Column(
                  children: <Widget>[
                      Container(
                          width: ScreenUtil().setWidth(310),
                          height: ScreenUtil().setWidth(32),
                          padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(20),
                            right:   ScreenUtil().setWidth(18)
                          ),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(240, 240, 240, 1),
                              border: Border(
                                  top: BorderSide(
                                      width: ScreenUtil().setWidth(1),
                                      color: Color.fromRGBO(39, 39, 39, 0.15)
                                  )
                              )
                          ),
                          child:
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                  Container(
                                      child: Row(
                                          children: <Widget>[
                                              Text(
                                                  widget.joinType == "BLE_JOIN"
                                                      ? "내 주변 사람"
                                                      : (
                                                      widget.joinType == "BLE_OUT"
                                                          ? "온라인 유저"
                                                          : "관전 유저"
                                                  ),
                                                  style: TextStyle(
                                                      height: 1,
                                                      fontSize: ScreenUtil().setSp(13),
                                                      letterSpacing: ScreenUtil().setWidth(-0.33),
                                                      color: Color.fromRGBO(39, 39, 39, 1)
                                                  ),
                                              ),
                                              Container(
                                                  height: ScreenUtil().setHeight(13),
                                                  padding: EdgeInsets.only(
                                                      left: ScreenUtil().setWidth(8),
                                                      right: ScreenUtil().setWidth(8),
                                                  ),
                                                  child: Text(
                                                      widget.userInfoList.length.toString(),
                                                      style: TextStyle(
                                                          height: 1,
                                                          fontSize: ScreenUtil().setSp(13),
                                                          letterSpacing: ScreenUtil().setWidth(-0.33),
                                                          color: Color.fromRGBO(107, 107, 107, 1)
                                                      ),
                                                  ),
                                              ),
                                          ],
                                      )
                                  ),
                                  Container(
                                      width: ScreenUtil().setWidth(20),
                                      child: FlatButton(
                                          onPressed:(){
                                              setState(() {
                                                  openedList = !openedList;
                                              });
                                          }
                                      ),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image:AssetImage(openedList
                                                                ? "assets/images/icon/iconFold.png"
                                                                : "assets/images/icon/iconExpand.png")
                                          ),
                                      ),
                                  )
                              ],
                          ),
                      ),
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

                  ],
              )
          );
    }
}
