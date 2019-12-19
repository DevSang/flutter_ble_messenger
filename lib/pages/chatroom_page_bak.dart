import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:expandable/expandable.dart';

const String _name = "HWAFriend";

class ChatroomPage extends StatefulWidget {
    @override
    _ChatroomPageState createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> with TickerProviderStateMixin {
    // 입력된 메세지 리스트
    final List<ChatMessage> _message = <ChatMessage>[];
    // 텍스트 필드 제어용 컨트롤러
    final TextEditingController _textController = TextEditingController();
    // 텍스트필드에 입력된 데이터의 존재 여부
    bool _isComposing = false;
    // 현재 채팅 Advertising condition
    BoxDecoration AdCondition;


    @override
    BoxDecoration stopAd(BuildContext context) {
        return BoxDecoration(
            color: Color.fromRGBO(153, 153, 153, 1),
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconLock.png")
            ),
            shape: BoxShape.circle
        );

    }

    @override
    BoxDecoration startAd(BuildContext context) {
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
        AdCondition = startAd(context);
    }

    @override
    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);
        final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

        Widget enterNotice = new Container(
            child: Container(
                margin: EdgeInsets.only(
                    top: ScreenUtil.getInstance().setHeight(18),
                    bottom: ScreenUtil.getInstance().setHeight(18)
                ),
                width: ScreenUtil().setWidth(718),
                height: ScreenUtil().setHeight(48),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.16),
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil.getInstance().setWidth(8))
                    )
                ),
                child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text(
                            "ㅇㅇ님이 입장하였습니다.",
                            style: TextStyle(
                                fontSize: ScreenUtil(allowFontScaling: true).setSp(22),
                                color: Colors.white
                            ),
                        )
                    ],
                )
            )
        );

        return Scaffold(
            appBar: AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                title: Text(
                    "코엑스 별마당 도서관",
                    style: TextStyle(
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil.getInstance().setSp(32)
                    ),
                ),
                leading: new IconButton(
                    icon: new Image.asset('assets/images/icon/navIconPrev.png'),
                    onPressed: (){
                        Navigator.of(context).pop();
                    }
                ),
                actions:[
                    GestureDetector(
                        child: Container(
                            margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                            width: ScreenUtil().setWidth(54),
                            height: ScreenUtil().setHeight(54),
                            decoration: AdCondition
                        ),
                        onTap:(){
                            setState(() {
                                AdCondition == startAd(context) ? AdCondition = stopAd(context) : AdCondition = startAd(context);
                            });
                        }
                    ),
                    Builder(
                        builder: (context) => IconButton(
                            icon: new Image.asset('assets/images/icon/navIconMenu.png'),
                            onPressed: () => Scaffold.of(context).openEndDrawer(),
                        ),
                    ),
                ],
                centerTitle: true,
                elevation: 6.0,
                backgroundColor: Colors.white,
            ),
            endDrawer: Drawer(),
            body: Stack(
                children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(210, 217, 250, 1)
                        ),
                        child: Column(
                            children: <Widget>[
                                Flexible(
                                    child: ListView.builder(
                                        padding: EdgeInsets.only(
                                            left: ScreenUtil.getInstance().setWidth(26.0),
                                            right: ScreenUtil.getInstance().setWidth(26.0)
                                        ),
                                        reverse: true,
                                        itemCount: _message.length,

                                        itemBuilder: (BuildContext context, int index) {
                                            return _message[index];
                                        },
                                    ),
                                ),
                                Divider(height: 1.0),
                                Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                    ),
                                    child: _buildTextComposer(),
                                )
                            ]
                        ),
                    ),
                    Positioned(
                        top: ScreenUtil().setHeight(20),
                        right: ScreenUtil().setWidth(10),
                        child: GestureDetector(
                            child: Container(
                                width: ScreenUtil().setWidth(66),
                                height: ScreenUtil().setHeight(66),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    image: DecorationImage(
                                        image:AssetImage("assets/images/icon/iconBell.png")
                                    ),
                                    shape: BoxShape.circle
                                )
                            ),
                            onTap:(){

                            }
                        )
                    )
                ],
            )
        );
    }

    Widget _buildTextComposer() {
        return IconTheme(
            data: IconThemeData(color: Theme.of(context).accentColor),
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                    children: <Widget>[
                        //채팅 입력 필드
                        Flexible(
                            child: TextField(
                                controller: _textController,
                                onChanged: (text) {
                                    setState(() {
                                        _isComposing = text.length > 0;
                                    });
                                },
                                // 키보드 상 전송버튼 클릭 시, 입력값이 있을 경우에만 호출
                                onSubmitted: _isComposing ? _handleSubmitted : null,
                                decoration: InputDecoration.collapsed(hintText: "메세지를 입력하세요."),
                            ),
                        ),
                        //전송 버튼
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            child:
                            GestureDetector(
                                child: Container(
                                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                                    width: ScreenUtil().setWidth(56),
                                    height: ScreenUtil().setHeight(56),
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(77, 96, 191, 1),
                                        image: DecorationImage(
                                            image:AssetImage('assets/images/icon/iconSendMessage.png')
                                        ),
                                        shape: BoxShape.circle
                                    )
                                ),
                                onTap:(){
                                    // 전송버튼 클릭 시, 입력값이 있을 경우에만 호출
                                    _isComposing ? () => _handleSubmitted(_textController.text) : null;
                                }
                            )
                        )
                    ],
                )
            )
        );
    }

    // 메시지 전송 버튼이 클릭될 때 호출
    void _handleSubmitted(String text) {
        _textController.clear();
        setState(() {
            _isComposing = false;
        });

        ChatMessage message = ChatMessage(
            chat: text,
            receivedMsg: false,
            animationController: AnimationController(
                duration: Duration(milliseconds: 700),
                vsync: this,
            )
        );

        //List에 메세지 추가
        setState(() {
          _message.insert(0, message);
        });

        message.animationController.forward();
    }
}

//  ListView에 추가될 메세지 위젯
class ChatMessage extends StatelessWidget {
    final String chat;
    final bool receivedMsg; // false : Send, true : Received
    final AnimationController animationController; // 등록 시 보여질 효과
    final String date;

    ChatMessage({this.chat, this.receivedMsg, this.animationController, this.date});

    @override
    Widget build(BuildContext context) {
        // 위젯에 애니메이션을 발생하기 위해 SizeTransition을 추가
        return SizeTransition(
            sizeFactor: CurvedAnimation(parent: animationController, curve: Curves.easeOut),
            axisAlignment: 0.0,
            child: Container(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        // 유저 썸네일 노출 여부 (상대방 메세지에만 노출)
                        !receivedMsg ? thumbnail : new Container(),
                        Expanded(
                            child: receivedBubble(context, chat)
                        )
                    ],
                )
            ),
        );

    }

    Widget thumbnail = new Container(
        margin: EdgeInsets.only(right: ScreenUtil.getInstance().setWidth(14)),
        child: CircleAvatar(
            child: Text(_name[0]),

        )
    );

    // 받은 메세지 말풍선 스타일
    Widget receivedBubble(BuildContext context, String nick) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                Text(
                    _name,
                    style: TextStyle(
                                fontSize: ScreenUtil(allowFontScaling: true).setSp(22),
                                color: Color.fromRGBO(39, 39, 39, 0.7)
                            )
                ),
                // Triangle on the bubble
                Container(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    alignment: AlignmentDirectional(0.0, 0.0),
                    width: 10,
                    child: Container(
                        padding: const EdgeInsets.only(top:3.0, bottom: 3.0),
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10.0)
                            ),
                            color: Color.fromRGBO(210, 217, 250, 1)
                        )
                    ),
                ),
                // Bubble
                Container(
                    child: Row(
                        children: [
                            Container(
                                constraints: BoxConstraints(maxWidth: 230),
                                padding: const EdgeInsets.all(8.0),
                                margin: EdgeInsets.only(
                                    bottom: ScreenUtil.getInstance().setHeight(28),
                                    right: ScreenUtil.getInstance().setHeight(15)
                                ),
                                child: Text(
                                    chat,
                                    style: TextStyle(
                                        fontSize: ScreenUtil(allowFontScaling: true).setSp(30),
                                        color: Color.fromRGBO(39, 39, 39, 0.96)
                                    )
                                ),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0),
                                    )
                                ),
                            ),
                            Container(
                                margin: EdgeInsets.only(
                                    bottom: ScreenUtil.getInstance().setHeight(8)
                                ),
                                child: Text(
                                    '4분 전',
                                    style: TextStyle(
                                        fontSize: ScreenUtil(allowFontScaling: true).setSp(22),
                                        color: Color.fromRGBO(39, 39, 39, 0.7)
                                    )
                                ),
                            )
                        ],
                    )
                )
            ],
        );
    }

    // 보낸 메세지 말풍선 스타일
    Widget sendBubble(BuildContext context, String chat) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
                Container(
                    color: Color.fromRGBO(166, 181, 255, 1),
                    alignment: AlignmentDirectional(0.0, 0.0),
                    width: 10,
                    child: Container(
                        padding: const EdgeInsets.only(top:3.0, bottom: 3.0),
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(10.0)
                            ),
                            color: Color.fromRGBO(210, 217, 250, 1)
                        )
                    ),
                ),
                Container(
                    constraints: BoxConstraints(maxWidth: 230),
                    padding: const EdgeInsets.all(8.0),
                    child: Text(chat),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(166, 181, 255, 1),
                        borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                        )
                    ),
                )
            ],
        );
    }
}
