import 'dart:async';
import 'dart:io';
import 'dart:convert';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Hwa/package/fullPhoto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/data/models/chat_count_user.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/pages/parts/chat_side_menu.dart';

class ChatroomPage extends StatefulWidget {
    final String peerId;
    final String peerAvatar;

    ChatroomPage({Key key, @required this.peerId, @required this.peerAvatar}) : super(key: key);

    @override
    State createState() => new ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatroomPage> {
    ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});

    String peerId;
    String peerAvatar;
    String id;

    var listMessage;
    String groupChatId;
    SharedPreferences prefs;

    File imageFile;
    bool isLoading;
    bool isShowMenu;
    String imageUrl;

    // 채팅방 메세지 리스트
    final List<ChatMessage> _message = <ChatMessage>[];

    final TextEditingController textEditingController = new TextEditingController();
    final ScrollController listScrollController = new ScrollController();
    final FocusNode focusNode = new FocusNode();

    // 현재 채팅 Advertising condition
    BoxDecoration adCondition;
    // 현재 채팅 Advertising condition
    bool openedNf;
    // ChatTextField Focused
    bool isFocused;
    // ChatTextField Line View
    double _inputHeight = 72;
    // 현재 채팅 좋아요 TODO: 추후 맵핑
    bool isLike;

    // Stomp 관련
    String _initState = "";
    String _connectionState = "";
    String _subscriberState = "";
    String _content = "";
    String _sendContent = "";

    // TODO : 추후 서버에서 jwt 추출로 변경
    String userIdx = "100";

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

        focusNode.addListener(onFocusChange);

        groupChatId = '';

        isLoading = false;
        isShowMenu = false;
        imageUrl = '';

        adCondition = startAd(context);

        isFocused = false;
        openedNf = true;
        isLike = false;
        readLocal();

        /// Stomp 초기화
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

    readLocal() async {
        prefs = await SharedPreferences.getInstance();
        id = prefs.getString('id') ?? '';
        if (id.hashCode <= peerId.hashCode) {
            groupChatId = '$id-$peerId';
        } else {
            groupChatId = '$peerId-$id';
        }

        setState(() {});
    }

    Future getImage() async {
        imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

        if (imageFile != null) {
            setState(() {
                isLoading = true;
            });
            uploadFile();
        }
    }

    void getMenu() {
        // Hide keyboard when menu appear
        focusNode.unfocus();
        setState(() {
            isShowMenu = !isShowMenu;
        });
    }

    Future uploadFile() async {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        // TODO: upload Image
    }

    void onSendMessage(String content, int type) {
        // type: 0 = text, 1 = image, 2 = sticker
        if (content.trim() != '') {
            textEditingController.clear();

//            var documentReference = Firestore.instance
//                .collection('messages')
//                .document(groupChatId)
//                .collection(groupChatId)
//                .document(DateTime.now().millisecondsSinceEpoch.toString());
//
//            Firestore.instance.runTransaction((transaction) async {
//                await transaction.set(
//                    documentReference,
//                    {
//                        'idFrom': id,
//                        'idTo': peerId,
//                        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
//                        'content': content,
//                        'type': type
//                    },
//                );
//            });

//            listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        } else {
            Fluttertoast.showToast(msg: 'Nothing to send');
        }
    }

//    Widget buildItem(int index, DocumentSnapshot document) {
    Widget buildItem(int index) {
//        if (document['idFrom'] == id) {
//            // Right (my message)
//            return Row(
//                children: <Widget>[
//                    document['type'] == 0
//                    // Text
//                        ? Container(
//                        child: Text(
//                            document['content'],
//                            style: TextStyle(color: Colors.white),
//                        ),
//                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
//                        width: 200.0,
//                        decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(8.0)),
//                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
//                    )
//                        : document['type'] == 1
//                    // Image
//                        ? Container(
//                        child: FlatButton(
//                            child: Material(
//                                child: CachedNetworkImage(
//                                    placeholder: (context, url) => Container(
//                                        child: CircularProgressIndicator(
//                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                        ),
//                                        width: 200.0,
//                                        height: 200.0,
//                                        padding: EdgeInsets.all(70.0),
//                                        decoration: BoxDecoration(
//                                            color: Colors.blueGrey,
//                                            borderRadius: BorderRadius.all(
//                                                Radius.circular(8.0),
//                                            ),
//                                        ),
//                                    ),
//                                    errorWidget: (context, url, error) => Material(
//                                        child: Image.asset(
//                                            'images/img_not_available.jpeg',
//                                            width: 200.0,
//                                            height: 200.0,
//                                            fit: BoxFit.cover,
//                                        ),
//                                        borderRadius: BorderRadius.all(
//                                            Radius.circular(8.0),
//                                        ),
//                                        clipBehavior: Clip.hardEdge,
//                                    ),
//                                    imageUrl: document['content'],
//                                    width: 200.0,
//                                    height: 200.0,
//                                    fit: BoxFit.cover,
//                                ),
//                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                                clipBehavior: Clip.hardEdge,
//                            ),
//                            onPressed: () {
//                                Navigator.push(
//                                    context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));
//                            },
//                            padding: EdgeInsets.all(0),
//                        ),
//                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
//                    )
//                    // Sticker
//                        : Container(
//                        child: new Image.asset(
//                            'images/${document['content']}.gif',
//                            width: 100.0,
//                            height: 100.0,
//                            fit: BoxFit.cover,
//                        ),
//                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
//                    ),
//                ],
//                mainAxisAlignment: MainAxisAlignment.end,
//            );
//        }
//        else {
//            // Left (peer message)
//            return Container(
//                child: Column(
//                    children: <Widget>[
//                        Row(
//                            children: <Widget>[
//                                isLastMessageLeft(index)
//                                    ? Material(
//                                    child: CachedNetworkImage(
//                                        placeholder: (context, url) => Container(
//                                            child: CircularProgressIndicator(
//                                                strokeWidth: 1.0,
//                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                            ),
//                                            width: 35.0,
//                                            height: 35.0,
//                                            padding: EdgeInsets.all(10.0),
//                                        ),
//                                        imageUrl: peerAvatar,
//                                        width: 35.0,
//                                        height: 35.0,
//                                        fit: BoxFit.cover,
//                                    ),
//                                    borderRadius: BorderRadius.all(
//                                        Radius.circular(18.0),
//                                    ),
//                                    clipBehavior: Clip.hardEdge,
//                                )
//                                    : Container(width: 35.0),
//                                document['type'] == 0
//                                    ? Container(
//                                    child: Text(
//                                        document['content'],
//                                        style: TextStyle(color: Colors.white),
//                                    ),
//                                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
//                                    width: 200.0,
//                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
//                                    margin: EdgeInsets.only(left: 10.0),
//                                )
//                                    : document['type'] == 1
//                                    ? Container(
//                                    child: FlatButton(
//                                        child: Material(
//                                            child: CachedNetworkImage(
//                                                placeholder: (context, url) => Container(
//                                                    child: CircularProgressIndicator(
//                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                                    ),
//                                                    width: 200.0,
//                                                    height: 200.0,
//                                                    padding: EdgeInsets.all(70.0),
//                                                    decoration: BoxDecoration(
//                                                        color: Colors.blueGrey,
//                                                        borderRadius: BorderRadius.all(
//                                                            Radius.circular(8.0),
//                                                        ),
//                                                    ),
//                                                ),
//                                                errorWidget: (context, url, error) => Material(
//                                                    child: Image.asset(
//                                                        'images/img_not_available.jpeg',
//                                                        width: 200.0,
//                                                        height: 200.0,
//                                                        fit: BoxFit.cover,
//                                                    ),
//                                                    borderRadius: BorderRadius.all(
//                                                        Radius.circular(8.0),
//                                                    ),
//                                                    clipBehavior: Clip.hardEdge,
//                                                ),
//                                                imageUrl: document['content'],
//                                                width: 200.0,
//                                                height: 200.0,
//                                                fit: BoxFit.cover,
//                                            ),
//                                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                                            clipBehavior: Clip.hardEdge,
//                                        ),
//                                        onPressed: () {
//                                            Navigator.push(context,
//                                                MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));
//                                        },
//                                        padding: EdgeInsets.all(0),
//                                    ),
//                                    margin: EdgeInsets.only(left: 10.0),
//                                )
//                                    : Container(
//                                    child: new Image.asset(
//                                        'images/${document['content']}.gif',
//                                        width: 100.0,
//                                        height: 100.0,
//                                        fit: BoxFit.cover,
//                                    ),
//                                    margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
//                                ),
//                            ],
//                        ),
//
//                        // Time
//                        isLastMessageLeft(index)
//                            ? Container(
//                            child: Text(
//                                DateFormat('dd MMM kk:mm')
//                                    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),
//                                style: TextStyle(color: Colors.black12, fontSize: 12.0, fontStyle: FontStyle.italic),
//                            ),
//                            margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
//                        )
//                            : Container()
//                    ],
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                ),
//                margin: EdgeInsets.only(bottom: 10.0),
//            );
//        }
    }

    bool isLastMessageLeft(int index) {
        if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] == id) || index == 0) {
            return true;
        } else {
            return false;
        }
    }

    bool isLastMessageRight(int index) {
        if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] != id) || index == 0) {
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
                                        buildListMessage(),

                                        // Input content
                                        buildInput(),

                                        // Menu
                                            (isShowMenu ? buildMenu() : Container()),
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

    Widget stmopTest() {
        return Positioned(
            top: ScreenUtil().setHeight(50),
            right: ScreenUtil().setWidth(20),
            child: GestureDetector(
                child: Container(
                    width: 750,
                    child: Text(
                        _initState + " " ?? " " +
                        _connectionState + " " ?? " " +
                        _subscriberState  + " " ?? " " +
                        _content  + " " ?? " " +
                        _sendContent  + " " ?? " ",
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
                                                            if (count == 0 && _inputHeight == 72.0) {
                                                                return;
                                                            }
                                                            if (count <= 5) {  // use a maximum height of 6 rows
                                                                // height values can be adapted based on the font size
                                                                var newHeight = count == 0 ? 72.0 : 36.0 + (count * 36.0);
                                                                setState(() {
                                                                    _inputHeight = newHeight;
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
                                                decoration: setIcon('assets/images/icon/iconSendMessage.png')
                                            ),
                                            onTap:(){
                                                onSendMessage(textEditingController.text, 0);
                                            }
                                        ),
                                        decoration: BoxDecoration(
                                            color: Color.fromRGBO(245, 245, 245, 1),
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

    Widget buildMenu() {
        return Container(
            width: ScreenUtil().setWidth(750),
            height: ScreenUtil().setHeight(360),
            child: Column(
                children: <Widget>[
                    FlatButton(
                        onPressed: () => {},
                        child: new Image.asset(
                            '',
                            width: ScreenUtil().setWidth(80),
                            height: ScreenUtil().setHeight(140)
                        )
                    )
                ],
            ),
            decoration: BoxDecoration(
                color: Colors.white,
            ),
        );
    }

    void _onTapTextField() {
        print("clicked field");
        isFocused
            ? null
            : setState(() {isFocused = true;});
    }

    Container chatIconClose() {
        return Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(8),
                right: ScreenUtil().setWidth(8),
                bottom: ScreenUtil().setHeight(32),
            ),
            child:
            GestureDetector(
                child: Container(
                    width: ScreenUtil().setWidth(36),
                    height: ScreenUtil().setHeight(36),
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
                                decoration: setIcon('assets/images/icon/iconAttachMore.png')
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

    BoxDecoration setIcon(String iconPath) {
        return BoxDecoration(
            color: Color.fromRGBO(77, 96, 191, 1),
            image: DecorationImage(
                image:AssetImage(iconPath)
            ),
            shape: BoxShape.circle
        );
    }

    //메세지 리스트에 추가
    Widget buildListMessage() {
        return Flexible(
            child: ListView.builder(
                padding: EdgeInsets.only(
                    left: ScreenUtil.getInstance().setWidth(16.0),
                    right: ScreenUtil.getInstance().setWidth(16.0)
                ),
                reverse: true,
                // TODO: message 적용
                itemCount: 0,

                itemBuilder: (BuildContext context, int index) {
                    _message[index];
                },
            )
        );
//        return Flexible(
//            child: groupChatId == ''
//                ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
//                : StreamBuilder(
//                stream: Firestore.instance
//                    .collection('messages')
//                    .document(groupChatId)
//                    .collection(groupChatId)
//                    .orderBy('timestamp', descending: true)
//                    .limit(20)
//                    .snapshots(),
//                builder: (context, snapshot) {
//                    if (!snapshot.hasData) {
//                        return Center(
//                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
//                    } else {
//                        listMessage = snapshot.data.documents;
//                        return ListView.builder(
//                            padding: EdgeInsets.all(10.0),
//                            itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
//                            itemCount: snapshot.data.documents.length,
//                            reverse: true,
//                            controller: listScrollController,
//                        );
//                    }
//                },
//            ),
//        );
    }
}