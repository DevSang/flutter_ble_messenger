import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/data/models/chat_setting.dart';
import 'package:Hwa/pages/parts/set_chat_setting_data.dart';

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

    ChatSetting chatSetting = new SetChatSettingData().main();
    ChatSetting chatSettingUpdated = new ChatSetting();

    @override
    void initState() {
        super.initState();

        chatSettingUpdated.chatImg = chatSetting.chatImg;
        chatSettingUpdated.title = chatSetting.title;
        chatSettingUpdated.intro = chatSetting.intro;
        chatSettingUpdated.isPublic = chatSetting.isPublic;
        chatSettingUpdated.inviteRange = chatSetting.inviteRange;
        chatSettingUpdated.mode = chatSetting.mode;
    }

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

                  new Expanded(
                      child: buildChatSettingList()
                  )
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
                    InkWell(
                        child: Center(
                            child: Container(
                                width: ScreenUtil().setWidth(90),
                                height: ScreenUtil().setHeight(90),
                                margin: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(41),
                                    bottom: ScreenUtil().setHeight(46),
                                ),
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
                                        chatSetting.chatImg,
                                        fit: BoxFit.cover,
                                    )
                                ),
                            ),
                        ),
                        onTap: () {
                            // TODO: Gallery
                        },
                    ),
                    Positioned(
                        bottom: ScreenUtil().setHeight(41),
                        left: ScreenUtil().setWidth(206),
                        child: InkWell(
                            child: Container(
                                width: ScreenUtil().setWidth(32),
                                height: ScreenUtil().setHeight(32),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(77, 96, 191, 1),
                                    image: DecorationImage(
                                        image:AssetImage("assets/images/icon/iconAttachCamera.png")
                                    ),
                                    shape: BoxShape.circle
                                )
                            ),
                            onTap:(){
                                // TODO: Gallery
                            }
                        )
                    )
                ],
            ),
        );
    }

    Widget buildChatSettingList() {
        return Container(
            child: Column(
                children: <Widget>[
                    buildTextItem('단화방 이름', chatSettingUpdated.title),
                    buildTextItem('단화방 소개', chatSettingUpdated.intro),
                    buildSwitchItem('온라인 공개', chatSettingUpdated.isPublic),
                    buildRangeItem('온라인 공개', chatSettingUpdated.inviteRange),
                ],
            ),
        );
    }

    Widget buildTextItem(String title, String value) {
        return Container(
            height: ScreenUtil().setHeight(49),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(16),
                right: ScreenUtil().setWidth(8)
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    Container(
                        child: Row(
                            children: <Widget>[
                                Text(
                                    value,
                                    style: TextStyle(
                                        height: 1,
                                        fontFamily: "NotoSans",
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromRGBO(107, 107, 107, 1),
                                        fontSize: ScreenUtil.getInstance().setSp(15),
                                        letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                                    )
                                ),
                                Container(
                                    width: ScreenUtil().setWidth(20),
                                    height: ScreenUtil().setHeight(20),
                                    margin: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(6)
                                    ),
                                    child: Image.asset(
                                        'assets/images/icon/iconMore.png'
                                    )
                                )
                            ],
                        ),
                    )
                ],
            )
        );
    }

    Widget buildSwitchItem(String title, bool value) {
        return Container(
            height: ScreenUtil().setHeight(49),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(16),
                right: ScreenUtil().setWidth(8)
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    Expanded(
                        child: SwitchListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            value: value,
                            onChanged: (value) {
                                print(value);
                                setState(() {
                                    chatSettingUpdated.isPublic = value;
                                });
                            },
                        ),
                    )
                ],
            )
        );
    }

    Widget buildRangeItem(String title, int _value) {
        return Container(
            width: ScreenUtil().setWidth(375),
            height: ScreenUtil().setHeight(49),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(16),
                right: ScreenUtil().setWidth(8)
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    Container(
                        child: Slider(
                            min: 1.0,
                            max: 3.0,
                            value: _value.toDouble(),
                            divisions: 3,
                            onChanged: (  value) {
                                print(value.round().toString());
                                setState(() {
                                    _value = value.round();
                                });
                            },
                        ),
                    )
                ],
            )
        );
    }

    Widget buildSelectItem(String title, int value) {
        return Container();
    }
}