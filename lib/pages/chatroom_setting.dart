import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-26
 * @description : 채팅 설정 페이지
 */
class ChatroomSettingPage extends StatefulWidget {
    final int chatIdx;

    ChatroomSettingPage({Key key, @required this.chatIdx}) : super(key: key);

    @override
    State createState() => new ChatroomSettingPageState(chatIdx: chatIdx);
}

class ChatroomSettingPageState extends State<ChatroomSettingPage> {
    final int chatIdx;

    ChatroomSettingPageState({Key key, @required this.chatIdx});

    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 375, height: 667, allowFontScaling: true)..init(context);

        return new Scaffold(
            appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                brightness: Brightness.light,
                title: Text(
                    "단화방 설정",
                    style: TextStyle(
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil.getInstance().setSp(16),
                        fontFamily: "NotoSans"
                    ),
                ),
                elevation: 0.0,
                leading: new IconButton(
                    icon: new Image.asset('assets/images/icon/navIconClose.png'),
                    onPressed: (){
                        Navigator.of(context).pop();
                    }
                ),
                actions:[
                    Builder(
                        builder: (context) =>
                            Row(
                                children: <Widget>[
                                    Container (
                                        margin: EdgeInsets.only(
                                            right: ScreenUtil().setWidth(16),
                                        ),
                                        child: GestureDetector(
                                            child: Text(
                                                '저장',
                                                style: TextStyle(
                                                    color: Color.fromRGBO(77, 96, 191, 1),
                                                    letterSpacing: ScreenUtil().setWidth(-0.75),
                                                    fontSize: ScreenUtil.getInstance().setSp(15),
                                                    fontFamily: "NotoSans",
                                                    fontWeight: FontWeight.w500
                                                ),
                                            ),
                                            onTap: () {
                                                // TODO 저장 API
                                                Navigator.of(context).pop();
                                            },
                                        )
                                    ),
                                ],
                            ),
                    ),
                ],
                centerTitle: true,
                backgroundColor: Colors.white,
            ),
            body: buildChatSetting(),
        );
    }

    Widget buildChatSetting() {
        return Container(
          child: Column(
              children: <Widget>[
                  buildChatImage(),
                  buildChatSettingList()
              ],
          ),
        );
    }

    Widget buildChatImage() {
        return Container(
            width: ScreenUtil().setWidth(375),
            height: ScreenUtil().setHeight(177),
            color: Color.fromRGBO(214, 214, 214, 1),
            child: Stack(
                children: <Widget>[
                    Container(
                        width: ScreenUtil().setWidth(90),
                        height: ScreenUtil().setHeight(90),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: ScreenUtil().setWidth(1),
                                color: Color.fromRGBO(0, 0, 0, 0.05)
                            ),
                            borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(22.5)),
                        ),
                        child: ClipRRect(
                            borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(22.5)),
                            child: Image.asset(
                                "assets/images/visualImageLogin.png",
                                width: ScreenUtil().setWidth(45),
                                height: ScreenUtil().setWidth(45),
                                fit: BoxFit.cover,
                            )
                        ),
                    ),
                ],
            ),
        );
    }

    Widget buildChatSettingList() {
        return Container();
    }
}