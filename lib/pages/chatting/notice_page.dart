import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Hwa/pages/chatting/notice_write_page.dart';
import 'package:Hwa/pages/chatting/notice_detail_page.dart';
import 'package:Hwa/data/models/chat_notice_item.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/convert_time.dart';
import 'package:Hwa/constant.dart';
import 'package:intl/intl.dart';


/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-23
 * @description : 공지사항 리스트
 */
class NoticePage extends StatefulWidget {
    final int hostIdx;
    final int chatIdx;
    NoticePage({Key key, @required this.hostIdx, this.chatIdx}) :super(key: key);

    @override
    State createState() =>  NoticePageState(chatIdx: chatIdx);
}

class NoticePageState extends State<NoticePage> {
    final int chatIdx;
    NoticePageState({Key key, this.chatIdx});
    List<ChatNoticeItem> chatNoticeList =  <ChatNoticeItem>[];

    @override
    void initState() {
        getNoticeList();

        super.initState();
    }

    /*
    * @author : sh
    * @date : 2020-01-01
    * @description : chat user list build 위젯
    */
    getNoticeList() async {
        try {
            /// 참여 타입 수정
            String uri = "/api/v2/chat/announce/all?chat_idx=" +  chatIdx.toString();
            final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);

            List resList = json.decode(response.body)['data'];

            for(var i = 0; i < resList.length; i++){
                chatNoticeList.add(ChatNoticeItem.fromJSON(resList[i]));
            }
            setState(() {
                chatNoticeList = chatNoticeList;
            });
            print(chatNoticeList.length.toString());

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                brightness: Brightness.light,
                title: Text(
                    "코엑스 별마당 도서관",
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil().setSp(16)
                    ),
                ),
                leading: new IconButton(
                    icon: new Image.asset('assets/images/icon/navIconClose.png'),
                    onPressed: (){
                        Navigator.of(context).pop();
                    }
                ),
                actions:[
                    Builder(
                        builder: (context) => IconButton(
                            icon:  Image.asset('assets/images/icon/navIconWrite.png'),
                            onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                        return NoticeWritePage(chatIdx: chatIdx);
                                    })
                                );
                            },
                        ),
                    ),
                ],
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color.fromRGBO(250, 250, 250, 1),
            ),
            body: noticeList(),
        );
    }

    Widget noticeList() {
        return  Container(
            decoration: BoxDecoration(
                color: Color.fromRGBO(235, 235, 235, 1),
                border: Border(
                    top: BorderSide(
                        width: ScreenUtil().setWidth(0.5),
                        color: Color.fromRGBO(178, 178, 178, 0.8)
                    )
                )
            ),
            child: Column(
                children: <Widget>[
                    // 상단 Tab Bar
                    noticeHeader(),

                    // 하단 공지 list
                    noticeBody()
                ],
            )
        );
    }

    Widget noticeHeader() {
        return  Container(
            height: ScreenUtil().setHeight(80),
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(17),
                bottom: ScreenUtil().setHeight(14),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    headerTab(1),
//                    headerTab(2),
                    Container()
                ],
            )
        );
    }

    Widget headerTab(int index) {
        Color tabColor = index == 1 ? Color.fromRGBO(77, 96, 191, 1) : Color.fromRGBO(158, 158, 158, 1);
        Color textColor = index == 1 ? Color.fromRGBO(77, 96, 191, 1) : Color.fromRGBO(107, 107, 107, 1);

        return new Container(
            width: ScreenUtil().setWidth(74),
            height: ScreenUtil().setHeight(36),
            margin: EdgeInsets.only(
                left: index == 2 ? ScreenUtil().setWidth(20) : 0,
            ),
            decoration: BoxDecoration(
                border: Border.all(
                    width: ScreenUtil().setWidth(1),
                    color: tabColor,
                ),
                borderRadius: BorderRadius.all(
                    Radius.circular(ScreenUtil().setWidth(20))
                )
            ),
            child: Center (
                child: Text(
                    index == 1 ? '공지' : '투표',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w500,
                        fontSize: ScreenUtil().setSp(14),
                        color: textColor
                    ),
                ),
            ),
        );
    }

    Widget noticeBody() {
        return new Container(
            child: Flexible(
                child: ListView.builder(
                    itemCount: chatNoticeList.length,
                    itemBuilder: (BuildContext context, int index) => buildNoticeItem(chatNoticeList[index])
                )
            )
        );

    }

    Widget buildNoticeItem(ChatNoticeItem chatNoticeItem) {

        return new GestureDetector(
            child: Container(
                padding: EdgeInsets.only(
                    top: ScreenUtil().setWidth(17),
                    bottom: ScreenUtil().setWidth(18),
                    left: ScreenUtil().setWidth(16),
                    right: ScreenUtil().setWidth(16),
                ),
                margin: EdgeInsets.only(
                    bottom: ScreenUtil().setHeight(10)
                ),
                color: Colors.white,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(
                                top: ScreenUtil().setHeight(2),
                                right: ScreenUtil().setWidth(11.5)
                            ),
                            child: ClipRRect(
                                borderRadius:  BorderRadius.circular(ScreenUtil().setWidth(45)),
                                child: FadeInImage(
                                    width: ScreenUtil().setHeight(40),
                                    height: ScreenUtil().setHeight(40),
                                    placeholder: AssetImage("assets/images/icon/profile.png"),
                                    image: chatNoticeItem.profile_picture_idx == 0 ? AssetImage("assets/images/icon/profile.png")
                                        : CachedNetworkImageProvider(Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + chatNoticeItem.user_idx.toString() + "&type=SMALL", headers: Constant.HEADER),
                                    fit: BoxFit.cover,
                                    fadeInDuration: Duration(milliseconds: 1)
                                )
                            )
                        ),
                        Container(
                            margin: EdgeInsets.only(
                                top: ScreenUtil().setHeight(0),
                                right: ScreenUtil().setWidth(21)
                            ),
                            child: Column (
                                children: <Widget>[
                                    Container(
                                        width: ScreenUtil().setWidth(245),
                                        margin: EdgeInsets.only(
                                            bottom: ScreenUtil().setWidth(6)
                                        ),
                                        child: Text(
                                            chatNoticeItem.contents,
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                fontSize: ScreenUtil().setSp(15),
                                                color: Color.fromRGBO(39, 39, 39, 1),
                                                letterSpacing: ScreenUtil().setWidth(-0.75),
                                                height: 1.5,

                                            ),
                                        )
                                    ),
                                    Container(
                                        width: ScreenUtil().setWidth(245),
                                        height: ScreenUtil().setHeight(13.5),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        right: ScreenUtil().setWidth(13.5)
                                                    ),
                                                    child: Text(
                                                        DateFormat("yyyy-MM-DD HH:mm:ss").format(DateTime.parse(chatNoticeItem.reg_ts)).toString(),
                                                        style: TextStyle(
                                                            fontFamily: "NanumSquare",
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: ScreenUtil().setSp(13),
                                                            height: 1.1,
                                                            color: Color.fromRGBO(107, 107, 107, 1)
                                                        ),
                                                    ),
                                                ),
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        right: ScreenUtil().setWidth(5.5)
                                                    ),
                                                    child: Text(
                                                        '댓글',
                                                        style: TextStyle(
                                                            fontFamily: "NotoSans",
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: ScreenUtil().setSp(13),
                                                            height: 1.1,
                                                            color: Color.fromRGBO(107, 107, 107, 1)
                                                        ),
                                                    ),
                                                ),
                                                Container(
                                                    child: Text(
                                                        chatNoticeItem.reply_cnt.toString(),
                                                        style: TextStyle(
                                                            fontFamily: "NanumSquare",
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: ScreenUtil().setSp(13),
                                                            height: 1.1,
                                                            color: Color.fromRGBO(107, 107, 107, 1)
                                                        ),
                                                    ),
                                                )
                                            ],
                                        )
                                    )
                                ],
                            )
                        ),
                        Container(
                            margin: EdgeInsets.only(
                                top: ScreenUtil().setHeight(2),
                            ),
                            child: GestureDetector(
                                child: Container(
                                    width: ScreenUtil().setWidth(20),
                                    height: ScreenUtil().setHeight(20),
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image:AssetImage("assets/images/icon/iconActionMenuOpen.png")
                                        ),
                                    )
                                ),
                                onTap:(){
                                    showCupertinoModalPopup(context: context, builder: (context) => _buildActionSheet());
                                }
                            ),
                        )
                    ],
                )
            ),
            onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                        return NoticeDetailPage(notice: chatNoticeItem);
                    })
                );
            },
        );
    }

    Widget _buildActionSheet() {
        return CupertinoActionSheet(
            actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text("수정하기"),
                    onPressed: () {
                        Navigator.pop(context);
                    },
                ),
                CupertinoActionSheetAction(
                    child: Text("삭제하기"),
                    isDestructiveAction: true,
                    onPressed: () {
                        Navigator.pop(context);
                    },
                )
            ],
            cancelButton: CupertinoActionSheetAction(
                child: Text("취소"),
                onPressed: () {
                    Navigator.pop(context);
                },
            ),
        );
    }
}
