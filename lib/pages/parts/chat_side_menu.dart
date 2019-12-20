import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:Hwa/data/models/chat_user_info.dart';
import 'package:Hwa/pages/parts/chat_user_list.dart';
import 'package:Hwa/pages/parts/set_user_data.dart';
import 'package:Hwa/pages/parts/set_user_data_online.dart';
import 'package:Hwa/pages/parts/set_user_data_view.dart';


class ChatSideMenu extends StatefulWidget {
    final bool isLike;
    ChatSideMenu({Key key, @required this.isLike});

    @override
    State createState() => new ChatSideMenuState(isLike: isLike);
}


class ChatSideMenuState extends State<ChatSideMenu> {
    ChatSideMenuState({Key key, @required this.isLike});

    // 현재 채팅 좋아요 TODO: 추후 맵핑
    final bool isLike;
    BoxDecoration likeCondition;

    // 현재 채팅 참여유저 TODO: 추후 맵핑
    List<ChatUserInfo> userInfoListBLE = new SetUserData().main();// 현재 채팅 참여유저 TODO: 추후 맵핑
    List<ChatUserInfo> userInfoListOnline = new SetUserDataOnline().main();// 현재 채팅 참여유저 TODO: 추후 맵핑
    List<ChatUserInfo> userInfoListView = new SetUserDataView().main();

    @override
    BoxDecoration unlikeChat(BuildContext context) {
        return BoxDecoration(
            color: Color.fromRGBO(153, 153, 153, 1),
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconLock.png")
            ),
            shape: BoxShape.circle
        );

    }

    @override
    BoxDecoration likeChat(BuildContext context) {
        return BoxDecoration(
            color: Color.fromRGBO(77, 96, 191, 1),
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconUnlock.png")
            ),
            shape: BoxShape.circle
        );

    }

    @override
    void initState() {
        super.initState();
        isLike ? likeCondition = likeChat(context) : likeCondition = unlikeChat(context);
    }
    
    @override
    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);

        return
        new SizedBox(
            width: ScreenUtil().setWidth(618),
            child: Drawer(
                child: Column(
                    children: <Widget>[
                        Container(
                            height: ScreenUtil().setHeight(180),
                            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    Container(
                                        width: ScreenUtil().setWidth(478),
                                        height: ScreenUtil().setHeight(142),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                                Row(
                                                    children: <Widget>[
                                                        Text(
                                                            "단화방 정보",
                                                            style: TextStyle(
                                                                fontSize: ScreenUtil().setSp(30)
                                                            ),
                                                        ),
                                                        Container(
                                                            height: ScreenUtil().setHeight(24),
                                                            padding: EdgeInsets.only(
                                                                left: ScreenUtil().setWidth(10),
                                                                right: ScreenUtil().setWidth(16),
                                                            ),
                                                            child: Text(
                                                                "3,400",
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(22)
                                                                ),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                                Text(
                                                    "스타벅스 강남R점 사람들 얘기나눠요",
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil().setSp(24),
                                                        color: Colors.grey
                                                    ),
                                                ),
                                            ],
                                        )
                                    ),
                                    GestureDetector(
                                        child: Container(
                                            width: ScreenUtil().setWidth(80),
                                            height: ScreenUtil().setHeight(120),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                    Container(
                                                        width: ScreenUtil().setWidth(80),
                                                        height: ScreenUtil().setHeight(80),
                                                        decoration: likeCondition,
                                                    ),
                                                    Container(
                                                        width: ScreenUtil().setWidth(80),
                                                        child:
                                                        Text(
                                                            "3,400",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                fontSize: ScreenUtil().setSp(22)
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            )
                                        ),
                                        onTap:(){
                                            setState(() {
                                                likeCondition == likeChat(context) ? likeCondition = unlikeChat(context) : likeCondition = likeChat(context);
                                            });
                                        }
                                    )
                                ],
                            )
                        ),
                        Flexible(
                            child: ListView(
                                children: <Widget>[
                                    ChatUserList(userInfoList: userInfoListBLE),
                                    ChatUserList(userInfoList: userInfoListOnline),
                                    ChatUserList(userInfoList: userInfoListView),
                                ],
                            ),
                        )
                    ],
                )
            )
        );
    }
}