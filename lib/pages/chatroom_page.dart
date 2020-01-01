import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:collection';

import 'package:Hwa/data/models/chat_join_info.dart';
import 'package:Hwa/pages/parts/loading.dart';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hwa_beacon/hwa_beacon.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:Hwa/constant.dart';
import 'package:Hwa/service/stomp_client.dart';
import 'package:Hwa/utility/call_api.dart';

import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/data/models/chat_count_user.dart';
import 'package:Hwa/data/models/chat_info.dart';

import 'package:Hwa/pages/notice_page.dart';
import 'package:Hwa/pages/parts/chat_side_menu.dart';
import 'package:Hwa/pages/parts/chat_message_list.dart';

import 'package:dio/dio.dart';



/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-22
 * @description : 채팅 페이지
 */
class ChatroomPage extends StatefulWidget {
    final ChatInfo chatInfo;
    final bool isLiked;
    final int likeCount;
    final List<ChatJoinInfo> joinInfo;
    final String from;      // HwaTab, ChatTab, Trend
    final bool disable;

    ChatroomPage({Key key, this.chatInfo, this.isLiked, this.likeCount, this.joinInfo, this.from, this.disable}) : super(key: key);


    @override
    State createState() => new ChatScreenState(chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount, joinInfo: joinInfo);
}

class ChatScreenState extends State<ChatroomPage> {
    final ChatInfo chatInfo;
    final bool isLiked;
    final int likeCount;
    final List<ChatJoinInfo> joinInfo;

    ChatScreenState({Key key, this.chatInfo, this.isLiked, this.likeCount, this.joinInfo});

    SharedPreferences prefs;

    File imageFile;
    bool isLoading;
    bool isShowMenu;
    String imageUrl;
    bool disable;

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
    int _inputHeight;

    // Stomp 관련
    StompClient s;
    bool isReceived;

    // BLE 관련
    bool _activateBeacon = false;
    int _ttl = 1;
    bool advertising;

    @override
    void initState() {
        super.initState();
        checkAd();
        /// Stomp 초기화
        connectStomp();

        disable = widget.disable ?? false;

        isReceived = false;

        focusNode.addListener(onFocusChange);

        isLoading = false;
        isShowMenu = false;
        imageUrl = '';

        advertising = true;

        isFocused = false;
        openedNf = true;
        isLike = false;
        isEmpty = true;
        inputLineCount = 1;
        _inputHeight = 36;

        print("***************" + joinInfo.length.toString());

        getMessageList();
    }

    @override
    void dispose() {
        HwaBeacon().stopAdvertising();

        s.unsubscribe(topic: "/sub/danhwa/" + chatInfo.chatIdx.toString());
        s.disconnect();
        super.dispose();
    }

    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : 입장 시 기존 Advertising Stop
    */
    void checkAd() async {
        bool advertising = await HwaBeacon().isAdvertising();

        if (advertising) {
            await HwaBeacon().stopAdvertising();
            await HwaBeacon().startAdvertising(chatInfo.chatIdx, _ttl);
        }
        else
            await HwaBeacon().startAdvertising(chatInfo.chatIdx, _ttl);
    }

    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : Advertising Stop/Start
    */
    void advertiseChange() async {
        if (advertising) {
            await HwaBeacon().stopAdvertising();
            setState(() {advertising = false;});
            print('##BLE STOP!!!');
        } else {
            await HwaBeacon().startAdvertising(chatInfo.chatIdx, _ttl);
            setState(() {advertising = true;});
            print('##BLE START!!!');
        }
    }

    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : Focus 감지에 따른 화면
    */
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
    void connectStomp() async {
        // connect to MsgServer
        s = StompClient(urlBackend: Constant.CHAT_SERVER_WS);
        await s.connectWebSocket();
        s.connectStomp();

        // subscribe topic
        s.subscribe(topic: "/sub/danhwa/" + chatInfo.chatIdx.toString(), roomIdx: chatInfo.chatIdx.toString(), userIdx: Constant.USER_IDX.toString()).stream.listen((HashMap data) =>
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

        developer.log("# messageReceieved : " + json.decode(data['contents']).toString());

        ChatMessage cmb = ChatMessage(
            chatType: message.chatType,
            roomIdx: message.roomIdx,
            senderIdx: message.senderIdx,
            nickName: message.nickName,
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
     * @description : 화면 입장 후 메세지 리스트 받아오기
    */
    getMessageList() async {
        setState(() {});
    }

    /*
     * @author : hs
     * @date : 2019-12-24
     * @description : Image 받아오기
    */
    Future getImage() async {
        imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
        if (imageFile != null) {

        	// 파일 이외의 추가 파라미터 셋팅
	        Map<String, dynamic> param = {
	        	"chat_idx" : chatInfo.chatIdx
	        };

	        // 파일 업로드 API 호출
	        Response response = await CallApi.fileUploadCall(url: "/api/v2/chat/share/file", filePath: imageFile.path, paramMap: param, onSendProgress: (int sent, int total){
		        print("$sent : $total");
	        });

	        if(response.statusCode == 200){
		        onSendMessage("https://api.hwaya.net/api/v2/chat/share/file?file_idx=" + response.data["data"].toString() + "&type=SMALL", 1);
	        }
        }
    }

    /*
     * @author : hs
     * @date : 2019-12-25
     * @description :
    */
    Future getCamera() async {
        imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
        if (imageFile != null) {
            // 파일 이외의 추가 파라미터 셋팅
            Map<String, dynamic> param = {
	            "chat_idx" : chatInfo.chatIdx
            };

            // 파일 업로드 API 호출
            Response response = await CallApi.fileUploadCall(url: "/api/v2/chat/share/file", filePath: imageFile.path, paramMap: param, onSendProgress: (int sent, int total){
	            print("$sent : $total");
            });

            if(response.statusCode == 200){
            	// 썸네일 URI 전송
	            onSendMessage("https://api.hwaya.net/api/v2/chat/share/file?file_idx=" + response.data["data"].toString() + "&type=SMALL", 1);
            }
        }
    }
    /*
     * @author : hs
     * @date : 2019-12-24
     * @description : 하단 Menu 처리 Show <-> Hide
    */
    void getMenu() {
        // Hide keyboard when menu appear
        focusNode.unfocus();
        setState(() {
            isShowMenu = !isShowMenu;
        });
    }

    void onSendMessage(dynamic content, int type) {
        String message;
        String sendType;

        if (content.runtimeType == String) {
            if (content.trim() != '') {
                textEditingController.clear();
                sendType = type == 0
                    ? "TALK"
                    : type == 1
                    ? "IMAGE"
                    : "SERVICE";
            }
        } else {
            sendType = "IMAGE";
        }

        final int now = new DateTime.now().microsecondsSinceEpoch ~/ 1000;
        message = '{"type": "'+ sendType +'","roomIdx":' + chatInfo.chatIdx.toString() + ',"senderIdx":' + Constant.USER_IDX.toString() + ',"message": "' + content.toString() + '","userCountObj":null,"createTs":' + now.toString() + '}';

        /// MESSAGE SEND
        s.send(
            topic: "/pub/danhwa",
            message: message
        );
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

    void popPage() async {
        setState(() {
            isLoading = true;
        });

	    advertising = false;
	    await HwaBeacon().stopAdvertising();

        setState(() {
            isLoading = false;
        });

	    Navigator.of(context).pop();
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                title: Text(
                    chatInfo.title ?? " ",
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil.getInstance().setSp(16)
                    ),
                ),
                leading: new IconButton(
                    icon: new Image.asset('assets/images/icon/navIconPrev.png'),
                    onPressed: (){
                        popPage();
                    }
                ),
                actions:[
                    chatInfo.createUser.userIdx == Constant.USER_IDX
                        ? GestureDetector(
                            child: Container(
                                margin: EdgeInsets.only(right: ScreenUtil().setWidth(5)),
                                width: ScreenUtil().setWidth(27),
                                height: ScreenUtil().setHeight(27),
                                decoration: advertising ? startAd(context) : stopAd(context)
                            ),
                            onTap:(){
                                advertiseChange();
                            }
                        )
                        : Container()
                    ,
                    Builder(
                        builder: (context) => IconButton(
                            icon: new Image.asset('assets/images/icon/navIconMenu.png'),
                            onPressed: () => Scaffold.of(context).openEndDrawer(),
                        ),
                    ),
                ],
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.white,
                brightness: Brightness.light,
            ),
            endDrawer: SafeArea(
                child: new ChatSideMenu(
                    chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount, chatJoinInfoList: joinInfo, sc: s, from: widget.from
                )
            ),
            body: GestureDetector(
                child: WillPopScope(
                    child: Stack(
                        children: <Widget>[
                            Container(
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(210, 217, 250, 1),
                                    border: Border(
                                        top: BorderSide(
                                            width: ScreenUtil().setWidth(0.5),
                                            color: Color.fromRGBO(178, 178, 178, 0.8)
                                        )
                                    )
                                ),
                                child: Column(
                                    children: <Widget>[
                                        // List of messages
                                        ChatMessageList(messageList: messageList),

                                        // Input content
                                        disable ? Container() : buildInput(),

                                        /// 하단 메뉴 서비스 추가 시 코드 교체
                                        // Menu
//                                            (isShowMenu && !isFocused ? buildMenu() : Container()),
                                    ],
                                ),
                            ),

                            // Notification
                            openedNf ? buildNoticeOpen() : buildNotice(),

                            // Loading
                            isLoading ? Loading() : Container()
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

    BoxDecoration startAd(BuildContext context) {
        return BoxDecoration(
            color: Color.fromRGBO(77, 96, 191, 1),
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconUnlock.png")
            ),
            shape: BoxShape.circle
        );

    }

    BoxDecoration stopAd(BuildContext context) {
        return BoxDecoration(
            color: Color.fromRGBO(153, 153, 153, 1),
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconLock.png")
            ),
            shape: BoxShape.circle
        );

    }

    Widget buildNotice() {
        return Positioned(
            top: ScreenUtil().setHeight(10),
            right: ScreenUtil().setWidth(10),
            child: GestureDetector(
                child: Container(
                    width: ScreenUtil().setWidth(33),
                    height: ScreenUtil().setHeight(33),
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
            top: ScreenUtil().setHeight(8),
            left: ScreenUtil().setWidth(8),
            child: Container(
                width: ScreenUtil().setWidth(359),
                height: ScreenUtil().setHeight(37),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(4)),
                    ),
                    boxShadow: [
                        new BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: ScreenUtil().setWidth(2), // has the effect of softening the shadow
                            spreadRadius: ScreenUtil().setWidth(0),
                            offset: new Offset(0, ScreenUtil().setWidth(2))
                        )
                    ]
                ),
                child: Row(
                    children: <Widget>[
                        GestureDetector(
                            child: Row(
                                children: <Widget> [
                                    Container(
                                        width: ScreenUtil().setWidth(20),
                                        height: ScreenUtil().setHeight(20),
                                        margin: EdgeInsets.only(
                                            left: ScreenUtil().setHeight(11)
                                        ),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            image: DecorationImage(
                                                image:AssetImage("assets/images/icon/iconBell.png")
                                            )
                                        )
                                    ),
                                    Container(
                                        width: ScreenUtil().setWidth(282),
                                        margin: EdgeInsets.only(
                                            left: ScreenUtil().setHeight(8.5),
                                            right: ScreenUtil().setHeight(8.5)
                                        ),
                                        child: Text(
                                            '타인을 향한 비방시 강퇴 조치를 취합니다.',
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: ScreenUtil.getInstance().setWidth(-0.65),
                                                fontSize: ScreenUtil().setSp(13),
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
                            width: ScreenUtil().setWidth(20),
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

    Container chatIconClose() {
        return Container(
            child:
            GestureDetector(
                child: Container(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(4),
                        right: ScreenUtil().setWidth(4),
                        bottom: ScreenUtil().setHeight(16),
                    ),
                    width: ScreenUtil().setWidth(26),
                    height: ScreenUtil().setHeight(50),
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
                        width: isFocused ? ScreenUtil().setWidth(343) :ScreenUtil().setWidth(230),
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setHeight(6),
                            bottom: ScreenUtil().setHeight(6)
                        ),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(245, 245, 245, 1),
                            border: Border.all(
                                color: Color.fromRGBO(214, 214, 214, 1),
                                width: ScreenUtil().setWidth(1)
                            ),
                            borderRadius: BorderRadius.all(
                                Radius.circular(ScreenUtil().setWidth(18))
                            )
                        ),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                                Expanded (
                                    child: Container(
                                        width: isFocused ? ScreenUtil().setWidth(301) : ScreenUtil().setWidth(188),
                                        height: ScreenUtil().setHeight(_inputHeight),
                                        margin: EdgeInsets.only(right: ScreenUtil().setWidth(8)),

                                        child: new ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minHeight: ScreenUtil().setHeight(36),
                                                maxHeight: ScreenUtil().setHeight(106)
                                            ),


                                            child: new SingleChildScrollView(
                                                scrollDirection: Axis.vertical,

                                                // here's the actual text box
                                                child: new TextField(
                                                    keyboardType: TextInputType.multiline,
                                                    controller: textEditingController,
                                                    minLines: 1,
                                                    maxLines: null,
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(39, 39, 39, 1),
                                                        fontSize: ScreenUtil().setSp(15),
                                                        letterSpacing: ScreenUtil().setWidth(-1.15),
                                                    ),
                                                    decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        contentPadding: EdgeInsets.only(
                                                            left: ScreenUtil().setWidth(13),
                                                            right: ScreenUtil().setWidth(9),
                                                            bottom: ScreenUtil().setHeight(8)
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
                                                            var inputHeight = 18 + (count * 18);

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
                                        right: ScreenUtil().setWidth(4),
                                        bottom: ScreenUtil().setWidth(4),
                                        top: ScreenUtil().setWidth(4)
                                    ),
                                    child:
                                    GestureDetector(
                                        child: Container(
                                            width: ScreenUtil().setWidth(28),
                                            height: ScreenUtil().setHeight(28),
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
                                            Radius.circular(ScreenUtil().setWidth(18))
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
            width: ScreenUtil().setWidth(139),
            child: Row(
                children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(
                            left: ScreenUtil().setWidth(8),
                            right: ScreenUtil().setWidth(12),
                            bottom: ScreenUtil().setWidth(8),
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                margin: EdgeInsets.only(right: ScreenUtil().setWidth(0)),
                                width: ScreenUtil().setWidth(32),
                                height: ScreenUtil().setHeight(32),
                                decoration: setIcon(
                                    /// 하단 메뉴 서비스 추가 시 코드 교체
//                                    isShowMenu
//                                        ? 'assets/images/icon/iconAttachClose.png'
//                                        : 'assets/images/icon/iconAttachMore.png'
                                    'assets/images/icon/iconAttachCard.png'
                                )
                            ),
                            onTap:(){
                                /// 하단 메뉴 서비스 추가 시 코드 교체
//                                getMenu();
                                FocusScope.of(context).unfocus();
                                dialogBC(context);
                            }
                        ),
                        color: Colors.white,
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            right: ScreenUtil().setWidth(12),
                            bottom: ScreenUtil().setWidth(8),
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                width: ScreenUtil().setWidth(32),
                                height: ScreenUtil().setHeight(32),
                                decoration: setIcon('assets/images/icon/iconAttachCamera.png')
                            ),
                            onTap:(){
                                getCamera();
                            }
                        ),
                        color: Colors.white,
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            right: ScreenUtil().setWidth(11),
                            bottom: ScreenUtil().setWidth(8),
                        ),
                        child:
                        GestureDetector(
                            child: Container(
                                width: ScreenUtil().setWidth(32),
                                height: ScreenUtil().setHeight(32),
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

    Future dialogBC(BuildContext context) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(10)))
                    ),
                    contentPadding: EdgeInsets.all(0),
                    content: Container(
                        width: ScreenUtil().setWidth(281),
                        height: ScreenUtil().setHeight(291),
                        padding: EdgeInsets.all(0),
                        child: Column(
                            children: <Widget>[
                                Container(
                                    width: ScreenUtil().setWidth(281),
                                    height: ScreenUtil().setHeight(42),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: ScreenUtil().setWidth(1),
                                                color: Color.fromRGBO(39, 39, 39, 0.15)
                                            )
                                        )
                                    ),
                                    child: Center(
                                        child: Text(
                                            '명함 공유',
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w500,
                                                fontSize: ScreenUtil(allowFontScaling: true).setSp(16),
                                                color: Color.fromRGBO(39, 39, 39, 1),
                                                letterSpacing: ScreenUtil().setWidth(-0.8),
                                            ),
                                        ),
                                    ),
                                ),
                                Container(
                                    width: ScreenUtil().setWidth(200),
                                    height: ScreenUtil().setHeight(111),
                                    margin: EdgeInsets.only(
                                        top: ScreenUtil().setHeight(14),
                                        bottom: ScreenUtil().setHeight(14),
                                    ),
                                    child: Image.asset(
                                        'assets/images/businesscard.png',
                                        fit:BoxFit.fitWidth
                                    ),
                                ),
                                Container(
                                    width: ScreenUtil().setWidth(281),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(
                                                width: ScreenUtil().setWidth(1),
                                                color: Color.fromRGBO(39, 39, 39, 0.15)
                                            )
                                        )
                                    ),
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            top: ScreenUtil().setHeight(21),
                                        ),
                                        child: Text(
                                            '현재 단화방에 명함을 공유하시겠습니까?',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                height: 1,
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: ScreenUtil.getInstance().setHeight(-0.33),
                                                fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                                                color: Color.fromRGBO(107, 107, 107, 1)
                                            )
                                        )
                                    )
                                ),
                                Container(
                                    margin: EdgeInsets.only(
                                        top: ScreenUtil().setHeight(21),
                                        bottom: ScreenUtil().setHeight(17),
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                            cardShareButton(1, (){
                                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                            }),
                                            cardShareButton(2, (){
                                                /// FileUpload 명함
                                                onSendMessage('assets/images/businesscard.png',2);
                                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                            }),
                                        ],
                                    )
                                )
                            ],
                        ),
                    )
                );
            }
        );
    }

    Widget cardShareButton(int index, Function fn) {
        String title = index == 1 ? '취소' : '공유하기';
        Color tabColor = index == 1 ? Color.fromRGBO(255, 255, 255, 1) : Color.fromRGBO(77, 96, 191, 1);
        Color borderColor = index == 1 ? Color.fromRGBO(158, 158, 158, 1) : Color.fromRGBO(77, 96, 191, 1);
        Color textColor = index == 1 ? Color.fromRGBO(107, 107, 107, 1) : Color.fromRGBO(255, 255, 255, 1);

        return InkWell(
            child: Container(
                width: ScreenUtil().setWidth(125),
                height: ScreenUtil().setHeight(36),
                margin: EdgeInsets.only(
                    left: index == 2 ? ScreenUtil().setWidth(5) : 0,
                ),
                decoration: BoxDecoration(
                    color: tabColor,
                    border: Border.all(
                        width: ScreenUtil().setWidth(1),
                        color: borderColor,
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(20))
                    )
                ),
                child: Center (
                    child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            letterSpacing: ScreenUtil.getInstance().setHeight(-0.33),
                            fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                            color: textColor
                        ),
                    ),
                ),
            ),
            onTap: () {
                fn();
            },
        );
    }

    ///
    /// 하단 메뉴 서비스 추가 시 코드 활용-------------------
    ///
    Widget buildMenu() {

        return Container(
            width: ScreenUtil().setWidth(375),
            height: ScreenUtil().setHeight(216),
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(21.5),
                bottom: ScreenUtil().setHeight(21.5),
                left: ScreenUtil().setHeight(8),
                right: ScreenUtil().setHeight(8),
            ),
            child: Column(
                children: <Widget>[
                    Container(
                        child: Row(
                            children: <Widget>[
                                buildMenuItem("assets/images/icon/iconViewCard.png", "명함", dialogBC),
                                buildMenuItem("assets/images/icon/iconWallet.png", "거래", null),
                                buildMenuItem("assets/images/icon/iconCar.png", "합승/카풀", null)
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

    Widget buildMenuItem(String imgSrc, String name, dynamic widget) {
        return
            Container(
                width: ScreenUtil().setWidth(88),
                height: ScreenUtil().setHeight(86.5),
                child: Column(
                    children: <Widget>[
                        Container(
                            width: ScreenUtil().setWidth(50),
                            height: ScreenUtil().setHeight(50),
                            margin: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(9.5)
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
                                onPressed: () => {
                                    name == "명함"
                                        ? widget(context)
                                        : Container()
                                },
                            )
                        ),
                        Container(
                            child: Text(
                                name,
                                style: TextStyle(
                                    height: 1,
                                    fontSize: ScreenUtil().setSp(13)
                                ),
                            )
                        )
                    ],
                ),
            );
    }

}