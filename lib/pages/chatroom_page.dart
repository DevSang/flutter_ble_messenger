import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:collection';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Hwa/package/fullPhoto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/service/stomp_client.dart';

import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/data/models/chat_count_user.dart';

import 'package:Hwa/pages/notice_page.dart';
import 'package:Hwa/pages/parts/chat_side_menu.dart';
import 'package:Hwa/pages/parts/chat_message_list.dart';


/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-22
 * @description : 채팅 페이지
 */
class ChatroomPage extends StatefulWidget {
    final String peerId;
    final String peerAvatar;

    ChatroomPage({Key key, @required this.peerId, @required this.peerAvatar}) : super(key: key);

    @override
    State createState() => new ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatroomPage> with TickerProviderStateMixin {
    ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});

    String peerId;
    String peerAvatar;
    String id;

    String groupChatId;
    SharedPreferences prefs;

    File imageFile;
    bool isLoading;
    bool isShowMenu;
    String imageUrl;

    // 채팅방 메세지 View 리스트
    final List<ChatMessage> messageList = <ChatMessage>[];
    // 받은 메세지
    ChatMessage message;

    final TextEditingController textEditingController = new TextEditingController();
    final ScrollController listScrollController = new ScrollController();
    final FocusNode focusNode = new FocusNode();

    // 현재 채팅 Advertising condition
    BoxDecoration adCondition;
    // 현재 채팅 Advertising condition
    bool openedNf;
    // ChatTextField Focused
    bool isFocused;
    // 현재 채팅 좋아요 TODO: 추후 맵핑
    bool isLike;
    // Focus된 메세지
    int focusMsg;
    // 채팅 입력 여부
    bool isEmpty;
    // 채팅 입력 줄 수
    int inputLineCount;
    // 입력칸 높이
    double _inputHeight;

    // Stomp 관련
    StompClient s;
    bool isReceived;

    // TODO : 추후 서버에서 jwt 추출로 변경
    String userIdx = "100";

    @override
    void initState() {
        super.initState();

        focusNode.addListener(onFocusChange);

        groupChatId = '';

        isLoading = false;
        isShowMenu = false;
        imageUrl = '';

        adCondition = startAd(context);

        isFocused = false;
        openedNf = true;
        isLike = false;
        isEmpty = true;
        inputLineCount = 1;
        _inputHeight = 72;

        getMessageList();

        /// Stomp 초기화
        connectStomp();
        isReceived = false;
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
    void dispose() {
        super.dispose();
    }

    void onFocusChange() {
        if (focusNode.hasFocus) {
            // Hide sticker when keyboard appear
            setState(() {
                isShowMenu = false;
            });
        }
    }

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : topic 구독
    */
    void connectStomp() {
        // connect to MsgServer
        s = StompClient(urlBackend: Constant.CHAT_SERVER_WS);
        s.connectWithToken(token: "token");

        // subscribe topic
        s.subscribe(topic: "/sub/danhwa/1", roomIdx: "1", userIdx: userIdx).stream.listen((HashMap data) =>
            messageReceieved(data),
            onDone: () {
                print("Listen Done");
            },
            onError: (error) {
                print("Listen Error $error");
            }
        );
    }

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : 메세지 수신 후 처리
    */
    void messageReceieved(HashMap data) {
        message = new ChatMessage.fromJSON(json.decode(data['contents']));

        print("received!!!!!!!"+json.decode(data['contents']).toString());

        ChatMessage cmb = ChatMessage(
            chatType: message.chatType,
            roomIdx: message.roomIdx,
            senderIdx: message.senderIdx,
            message: message.message,
            chatTime: message.chatTime,
        );

        setState(() {
            messageList.insert(0, cmb);
            isReceived = true;
        });


    }

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : 메세지 리스트 받아오기
    */
    getMessageList() async {
        setState(() {});
    }

    Future getImage() async {
        imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
        print(imageFile.path);
        if (imageFile != null) {
            setState(() {
                isLoading = false;
            });
//            uploadFile();
            onSendMessage(imageFile.path, 1);
        }
    }

    void getMenu() {
        // Hide keyboard when menu appear
        focusNode.unfocus();
        setState(() {
            isShowMenu = !isShowMenu;
        });
    }

    void onSendMessage(String content, int type) {
        // type: 0 = text, 1 = image, 2 = sticker


        if (content.trim() != '') {
            textEditingController.clear();
            var sendType = type == 0
                                ? "TALK"
                                : type == 1
                                    ? "IMAGE"
                                    : "STICKER";
            final int now = new DateTime.now().microsecondsSinceEpoch ~/ 1000;
            String message = '{"type": "'+ sendType +'","roomIdx":1,"senderIdx":' + Constant.USER_IDX.toString() + ',"message": "' + content + '","userCountObj":null,"createTs":' + now.toString() + '}';

            print(message);
            print(s);

            s.send(
                topic: "/pub/danhwa",
                message: message
            );

        } else {
            Fluttertoast.showToast(msg: '메세지를 입력해주세요.');
        }
    }


    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : 마지막 보낸 메세지
    */
    bool isLastSendMessage(int index) {
        if ((index > 0 && messageList != null && messageList[index - 1].senderIdx != Constant.USER_IDX) || index == 0) {
            return true;
        } else {
            return false;
        }
    }

    Future<bool> onBackPress() {
        if (isShowMenu) {
            setState(() {
                isShowMenu = false;
            });
        } else {
//            Firestore.instance.collection('users').document(id).updateData({'chattingWith': null});
            Navigator.pop(context);
        }

        return Future.value(false);
    }


    void _onTapTextField() {
        isFocused
            ? null
            : setState(() {
                isFocused = true;
                isShowMenu = false;
            });
    }


    @override
    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);
        return new Scaffold(
            appBar: new AppBar(
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
                brightness: Brightness.light,
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
                            decoration: adCondition
                        ),
                        onTap:(){
                            setState(() {
                                adCondition == startAd(context) ? adCondition = stopAd(context) : adCondition = startAd(context);
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
            endDrawer: SafeArea(
                child: new ChatSideMenu(isLike: isLike)
            ),
            body: GestureDetector(
                child: WillPopScope(
                    child: Stack(
                        children: <Widget>[
                            Container(
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(210, 217, 250, 1)
                                ),
                                child: Column(
                                    children: <Widget>[
                                        // List of messages
                                        ChatMessageList(messageList: messageList),

                                        // Input content
                                        buildInput(),

                                        // Menu
                                            (isShowMenu && !isFocused ? buildMenu() : Container()),
                                    ],
                                ),
                            ),

                            // Notification
                            openedNf ? buildNoticeOpen() : buildNotice(),

                            // Loading
                            buildLoading()
                        ],
                    ),
                    onWillPop: onBackPress,
                ),
                onTap: () {
                    FocusScope.of(context).requestFocus(focusNode);
                },
            )
        );
    }

    Widget buildLoading() {
        return Positioned(
            child: isLoading
                ? Container(
                child: Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                ),
                color: Colors.white.withOpacity(0.8),
            )
                : Container(),
        );
    }

    Widget buildNotice() {
        return Positioned(
            top: ScreenUtil().setHeight(20),
            right: ScreenUtil().setWidth(20),
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
                    setState(() {
                      openedNf = true;
                    });
                }
            )
        );
    }

    Widget buildNoticeOpen() {
        return Positioned(
            top: ScreenUtil().setHeight(16),
            left: ScreenUtil().setWidth(16),
            child: Container(
                width: ScreenUtil().setWidth(718),
                height: ScreenUtil().setHeight(74),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(8)),
                    ),
                    boxShadow: [
                        new BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: ScreenUtil().setWidth(4), // has the effect of softening the shadow
                            spreadRadius: ScreenUtil().setWidth(0),
                            offset: new Offset(0, ScreenUtil().setWidth(4))
                        )
                    ]
                ),
                child: Row(
                    children: <Widget>[
                        GestureDetector(
                            child: Row(
                                children: <Widget> [
                                    Container(
                                        width: ScreenUtil().setWidth(40),
                                        height: ScreenUtil().setHeight(40),
                                        margin: EdgeInsets.only(
                                            left: ScreenUtil().setHeight(22)
                                        ),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            image: DecorationImage(
                                                image:AssetImage("assets/images/icon/iconBell.png")
                                            )
                                        )
                                    ),
                                    Container(
                                        width: ScreenUtil().setWidth(564),
                                        margin: EdgeInsets.only(
                                            left: ScreenUtil().setHeight(17),
                                            right: ScreenUtil().setHeight(17)
                                        ),
                                        child: Text(
                                            '타인을 향한 비방시 강퇴 조치를 취합니다.',
                                            style: TextStyle(
                                                fontSize: ScreenUtil().setSp(26),
                                                color: Color.fromRGBO(39, 39, 39, 1)
                                            ),
                                        )
                                    ),
                                ]
                            ),
                            onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                        return NoticePage(chatIdx: 0);
                                    })
                                );
                            },
                        ),
                        Container(
                            width: ScreenUtil().setWidth(40),
                            child: FlatButton(
                                onPressed:(){
                                    setState(() {
                                        openedNf = false;
                                    });
                                }
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                    image:AssetImage("assets/images/icon/iconFold.png")

                            ),
                            shape: BoxShape.circle
                            ),
                        )
                    ],
                )
            )
        );
    }

    Widget buildMenu() {
        FocusScope.of(context).unfocus();

        return Container(
            width: ScreenUtil().setWidth(750),
            height: ScreenUtil().setHeight(432),
            padding: EdgeInsets.only(
              top: ScreenUtil().setHeight(43),
              bottom: ScreenUtil().setHeight(43),
              left: ScreenUtil().setHeight(16),
              right: ScreenUtil().setHeight(16),
            ),
            child: Column(
                children: <Widget>[
                    Container(
                        child: Row(
                            children: <Widget>[
                                buildMenuItem("assets/images/icon/iconViewCard.png", "명함"),
                                buildMenuItem("assets/images/icon/iconWallet.png", "거래"),
                                buildMenuItem("assets/images/icon/iconCar.png", "합승/카풀")
                            ],
                        )
                    )
                ],
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(
                        width: ScreenUtil().setWidth(2),
                        color: Color.fromRGBO(39, 39, 39, 0.15)
                    )
                )
            ),
        );
    }

    Widget buildMenuItem(String imgSrc, String name) {
        return
            Container(
                width: ScreenUtil().setWidth(176),
                height: ScreenUtil().setHeight(173),
                child: Column(
                    children: <Widget>[
                        Container(
                            width: ScreenUtil().setWidth(100),
                            height: ScreenUtil().setHeight(100),
                            margin: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(19)
                            ),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(210, 217, 250, 1),
                                image: DecorationImage(
                                    image:AssetImage(imgSrc)
                                ),
                                shape: BoxShape.circle
                            ),
                            child:
                            FlatButton(
                                onPressed: () => {},
                            )
                        ),
                        Container(
                            child: Text(
                                name,
                                style: TextStyle(
                                    height: 1,
                                    fontSize: ScreenUtil().setSp(26)
                                ),
                            )
                        )
                    ],
                ),
            );
    }

    Container chatIconClose() {
        return Container(
            child:
            GestureDetector(
                child: Container(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(8),
                        right: ScreenUtil().setWidth(8),
                        bottom: ScreenUtil().setHeight(32),
                    ),
                    width: ScreenUtil().setWidth(52),
                    height: ScreenUtil().setHeight(100),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image:AssetImage('assets/images/icon/iconAttachFold.png')
                        ),
                    )
                ),
                onTap:(){
                    setState(() {
                        isFocused = false;
                    });
                }
            ),
        );
    }

    BoxDecoration setIcon(String iconPath) {
        return BoxDecoration(
            color: Color.fromRGBO(77, 96, 191, 1),
            image: DecorationImage(
                image:AssetImage(iconPath)
            ),
            shape: BoxShape.circle
        );
    }

    Widget buildInput() {
        return Container(
            width: double.infinity,
            decoration: new BoxDecoration(
                color: Colors.white
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                    isFocused ? chatIconClose() : chatIconOpen(),
                    // Edit text
                    Container(
                        width: isFocused ? ScreenUtil().setWidth(686) :ScreenUtil().setWidth(460),
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setHeight(12),
                            bottom: ScreenUtil().setHeight(12)
                        ),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(245, 245, 245, 1),
                            border: Border.all(
                                color: Color.fromRGBO(214, 214, 214, 1),
                                width: ScreenUtil().setWidth(2.0)
                            ),
                            borderRadius: BorderRadius.all(
                                Radius.circular(ScreenUtil().setWidth(36.0))
                            )
                        ),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                                Expanded (
                                    child: Container(
                                        width: isFocused ? ScreenUtil().setWidth(602) : ScreenUtil().setWidth(376),
                                        height: ScreenUtil().setHeight(_inputHeight),
                                        margin: EdgeInsets.only(right: ScreenUtil().setWidth(16)),

                                        child: new ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minHeight: ScreenUtil().setHeight(72),
                                                maxHeight: ScreenUtil().setHeight(212)
                                            ),


                                            child: new SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                reverse: true,

                                                // here's the actual text box
                                                child: new TextField(
                                                    keyboardType: TextInputType.multiline,
                                                    controller: textEditingController,
                                                    minLines: 1,
                                                    maxLines: null,
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(39, 39, 39, 1),
                                                        fontSize: ScreenUtil().setSp(30.0),
                                                        letterSpacing: ScreenUtil().setWidth(-1.15),
                                                    ),
                                                    decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        contentPadding: EdgeInsets.only(
                                                            left: ScreenUtil().setWidth(26.0),
                                                            right: ScreenUtil().setWidth(18.0),
                                                            bottom: ScreenUtil().setHeight(16)
                                                        )
                                                    ),
                                                    autofocus: false,
                                                    onTap: _onTapTextField,
                                                    onChanged: (String chat){
                                                        int count = '\n'.allMatches(chat).length + 1;
                                                        if (chat.length == 0 && inputLineCount == count) {
                                                            setState(() {
                                                                isEmpty = true;
                                                            });
                                                        } else if (inputLineCount != count && count <= 5) {  // use a maximum height of 6 rows
                                                            // height values can be adapted based on the font size
                                                            var inputHeight = 36.0 + (count * 36.0);

                                                            setState(() {
                                                                inputLineCount = count;
                                                                _inputHeight = inputHeight;

                                                                if (chat.length == 0) isEmpty = true;
                                                                else isEmpty = false;
                                                            });
                                                        } else {
                                                            setState(() {
                                                                isEmpty = false;
                                                            });
                                                        }
                                                    },
                                                ),
                                                // ends the actual text box

                                            ),

                                        )
                                    )
                                ),
                                // Button send message
                                Container(
                                    margin: EdgeInsets.only(
                                        right: ScreenUtil().setWidth(8),
                                        bottom: ScreenUtil().setWidth(8),
                                        top: ScreenUtil().setWidth(8)
                                    ),
                                    child:
                                    GestureDetector(
                                        child: Container(
                                            width: ScreenUtil().setWidth(56),
                                            height: ScreenUtil().setHeight(56),
                                            decoration: BoxDecoration(
                                                color: isEmpty
                                                            ? Color.fromRGBO(204, 204, 204, 1)
                                                            : Color.fromRGBO(77, 96, 191, 1)
                                                ,
                                                image: DecorationImage(
                                                    image:AssetImage('assets/images/icon/iconSendMessage.png')
                                                ),
                                                shape: BoxShape.circle
                                            )
                                        ),
                                        onTap:(){
                                            onSendMessage(textEditingController.text, 0);
                                        }
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(ScreenUtil().setWidth(36.0))
                                        )
                                    ),
                                ),
                            ],
                        )
                    ),
                ],
            ),
        );
    }

    Container chatIconOpen() {
        return Container(
            width: ScreenUtil().setWidth(278),
            child: Row(
                children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(
                            left: ScreenUtil().setWidth(16),
                            right: ScreenUtil().setWidth(24),
                            bottom: ScreenUtil().setWidth(16),
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                margin: EdgeInsets.only(right: ScreenUtil().setWidth(0)),
                                width: ScreenUtil().setWidth(64),
                                height: ScreenUtil().setHeight(64),
                                decoration: setIcon(
                                    isShowMenu
                                        ? 'assets/images/icon/iconAttachClose.png'
                                        : 'assets/images/icon/iconAttachMore.png'
                                )
                            ),
                            onTap:(){
                                getMenu();
                            }
                        ),
                        color: Colors.white,
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            right: ScreenUtil().setWidth(24),
                            bottom: ScreenUtil().setWidth(16),
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                width: ScreenUtil().setWidth(64),
                                height: ScreenUtil().setHeight(64),
                                decoration: setIcon('assets/images/icon/iconAttachCamera.png')
                            ),
                            onTap:(){
                                getImage();
                            }
                        ),
                        color: Colors.white,
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            right: ScreenUtil().setWidth(22),
                            bottom: ScreenUtil().setWidth(16),
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                width: ScreenUtil().setWidth(64),
                                height: ScreenUtil().setHeight(64),
                                decoration: setIcon('assets/images/icon/iconAttachPhoto.png')
                            ),
                            onTap:(){
                                getImage();
                            }
                        ),
                        color: Colors.white,
                    ),
                ],
            ),
        );
    }
}