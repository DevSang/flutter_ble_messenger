import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/service/get_time_difference.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Hwa/package/fullPhoto.dart';
import 'package:Hwa/package/businessCardDetail.dart';

import 'package:Hwa/constant.dart';

const String name = "hwa";

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-23
 * @description : 단화방 채팅 요소 맵핑
 */
class ChatMessageList extends StatefulWidget {
    final List<ChatMessage> messageList;

    ChatMessageList({this.messageList});

    @override
    State createState() => new ChatMessageElementsState(messageList: messageList);
}

class ChatMessageElementsState extends State<ChatMessageList> {
    final List<ChatMessage> messageList;

    ChatMessageElementsState({this.messageList});

    int clickedMessage;

    @override
    Widget build(BuildContext context) {
        return Flexible(
            child: ListView.builder(
                padding: EdgeInsets.only(
                    top: ScreenUtil.getInstance().setHeight(50),
                    left: ScreenUtil.getInstance().setWidth(8),
                    right: ScreenUtil.getInstance().setWidth(8)
                ),
                reverse: true,

                itemCount: messageList.length,

                itemBuilder: (BuildContext context, int index) => buildChatMessage(index, messageList[index]),
            )
        );
    }

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : 마지막 보낸/입장/퇴장 메세지 여부
    */
    bool checkMessage(int index) {
        // 다음 메세지는 보낸 메세지가 아닐경우
        if ((index > 0 && messageList != null && messageList[index - 1].senderIdx != Constant.USER_IDX) || index == 0) {
            return true;
        } // 다음 메세지는 입장/퇴장 메세지가 아닐경우
        else if(index > 0 && messageList != null && (messageList[index - 1].chatType != "ENTER" && messageList[index - 1].chatType != "QUIT")) {
            return true;
        } else {
            return false;
        }
    }

    // 메세지 맵핑
    Widget buildChatMessage(int chatIndex, ChatMessage chatMessage) {
        bool isLastMessage = checkMessage(chatIndex);
        int userIdx = Constant.USER_IDX;

        // false : Send, true : Received
        bool receivedMsg = (userIdx != chatMessage.senderIdx)
                            ? true
                            : false;

        // chatType(TALK, ENTER, QUIT)에 따른 화면 처리
        Widget chatElement = chatMessage.chatType == "ENTER"
            ? enterNotice(chatMessage, isLastMessage)                           // 입장 메세지
            : chatMessage.chatType == "QUIT"
                ? quitNotice(chatMessage, isLastMessage)                        // 퇴장 메세지
                : receivedMsg
                    ? receivedLayout(chatIndex, chatMessage)                    // 받은 메세지 - 모든 타입 메세지
                    : chatMessage.chatType == "TALK"
                        ? sendText(chatIndex, chatMessage, isLastMessage)   // 보낸 메세지 - 텍스트 메세지
                        : chatMessage.chatType == "IMAGE"
                            ? imageBubble(chatMessage, receivedMsg)       // 보낸 메세지 - 이미지 메세지
                            : businessCardBubble(chatMessage, receivedMsg);       // 보낸 메세지 - 서비스 메세지 (현재는 명함 서비스만)

        return Container(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Expanded(
                        child: chatElement
                    )
                ],
            )
        );
    }

    // 받은 메세지 레이아웃 (프로필이미지, 이름, 시간)
    Widget receivedLayout(int chatIndex, ChatMessage chatMessage) {

        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                thumbnail,
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Text(
                                name,
                                style: TextStyle(
                                    fontFamily: "NotoSans",
                                    fontWeight: FontWeight.w400,
                                    fontSize: ScreenUtil(allowFontScaling: true).setSp(11),
                                    color: Color.fromRGBO(39, 39, 39, 0.7),
                                    letterSpacing: ScreenUtil.getInstance().setHeight(-0.28),
                                )
                            ),
                            chatMessage.chatType == "TALK"
                                ? receivedText(chatIndex, chatMessage)
                                : chatMessage.chatType == "IMAGE"
                                    ? imageBubble(chatMessage, true)
                                    : businessCardBubble(chatMessage, true)
                            ,
                        ],
                    )
                )
            ],
        );
    }

    // 받은 메세지 유저 프로필 이미지
    Widget thumbnail = new Container(
        margin: EdgeInsets.only(right: ScreenUtil.getInstance().setWidth(7)),
        child: CircleAvatar(
            child: Text(name[0]),

        )
    );

    // 메세지 시간 레이아웃
    Widget msgTime(int chatTime, bool receivedMsg) {
        return Container(
            margin:
            receivedMsg
                ? EdgeInsets.only(
                    bottom: ScreenUtil.getInstance().setHeight(4),
                    left: ScreenUtil.getInstance().setWidth(7))
                : EdgeInsets.only(
                    bottom: ScreenUtil.getInstance().setHeight(4),
                    right: ScreenUtil.getInstance().setWidth(7))
            ,
            child: Text(
                GetTimeDifference.timeDifference(chatTime),
                style: TextStyle(
                    height: 1,
                    fontFamily: "NanumSquare",
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenUtil(allowFontScaling: true).setSp(11),
                    color: Color.fromRGBO(39, 39, 39, 0.7)
                )
            ),
        );
    }

    // 받은 메세지 말풍선 스타일
    Widget receivedText(int chatIndex, ChatMessage chatMessage) {
        bool isSelected = clickedMessage == chatIndex
                            ? true
                            : false;
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                // Triangle on the bubble
                Container(
                    color: isSelected
                            ? Color.fromRGBO(173, 173, 173, 1)
                            : Color.fromRGBO(255, 255, 255, 1)
                    ,
                    alignment: AlignmentDirectional(0.0, 0.0),
                    width: ScreenUtil.getInstance().setWidth(15),
                    height: ScreenUtil.getInstance().setHeight(5),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                    ScreenUtil().setWidth(10)
                                )
                            ),
                            color: Color.fromRGBO(210, 217, 250, 1)
                        )
                    ),
                ),
                // Bubble
                Container(
                    margin: EdgeInsets.only(
                        bottom: ScreenUtil.getInstance().setHeight(14)
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                            GestureDetector(
                                child: Container(
                                    constraints: BoxConstraints(maxWidth: 115),
                                    padding: EdgeInsets.only(
                                        top: ScreenUtil().setHeight(10.5),
                                        bottom: ScreenUtil().setHeight(10.5),
                                        left: ScreenUtil().setWidth(14.5),
                                        right: ScreenUtil().setWidth(14.5),
                                    ),
                                    child: Text(
                                        chatMessage.message,
                                        style: TextStyle(
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScreenUtil(allowFontScaling: true).setSp(15),
                                            color: Color.fromRGBO(39, 39, 39, 0.96)
                                        )
                                    ),
                                    decoration: BoxDecoration(
                                        color: isSelected
                                            ? Color.fromRGBO(173, 173, 173, 1)
                                            : Color.fromRGBO(255, 255, 255, 1)
                                        ,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(ScreenUtil().setWidth(10)),
                                            bottomLeft: Radius.circular(ScreenUtil().setWidth(10)),
                                            bottomRight: Radius.circular(ScreenUtil().setWidth(10)),
                                        )
                                    ),
                                ),
                                onLongPress: (){
                                    setState(() {
                                        clickedMessage = chatIndex;
                                    });
                                },
                            ),
                            msgTime(chatMessage.chatTime, true)
                        ],
                    )
                ),
            ],
        );
    }

    // 보낸 메세지 말풍선 스타일
    Widget sendText(int chatIndex, ChatMessage chatMessage, bool isLastSendMessage) {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                            Container(
                                color: Color.fromRGBO(166, 181, 255, 1),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                width: ScreenUtil.getInstance().setWidth(15),
                                height: ScreenUtil.getInstance().setHeight(5),
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(
                                                ScreenUtil().setWidth(10)
                                            )
                                        ),
                                        color: Color.fromRGBO(210, 217, 250, 1)
                                    )
                                ),
                            ),
                            Container(
                                margin: EdgeInsets.only(
                                    bottom:
                                    isLastSendMessage
                                        ? ScreenUtil.getInstance().setHeight(14)
                                        : ScreenUtil.getInstance().setHeight(0)
                                ),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                        // 시간 레이아웃
                                        msgTime(chatMessage.chatTime, false),

                                        Container(
                                            constraints: BoxConstraints(maxWidth: 115),
                                            padding: EdgeInsets.only(
                                                top: ScreenUtil().setHeight(10.5),
                                                bottom: ScreenUtil().setHeight(10.5),
                                                left: ScreenUtil().setWidth(14.5),
                                                right: ScreenUtil().setWidth(14.5),
                                            ),
                                            child: Text(
                                                chatMessage.message,
                                                style: TextStyle(
                                                    fontFamily: "NotoSans",
                                                    fontWeight: FontWeight.w500,
                                                ),
                                            ),
                                            decoration: BoxDecoration(
                                                color: Color.fromRGBO(166, 181, 255, 1),
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(ScreenUtil().setWidth(10)),
                                                    bottomLeft: Radius.circular(ScreenUtil().setWidth(10)),
                                                    bottomRight: Radius.circular(ScreenUtil().setWidth(10)),
                                                )
                                            ),
                                        )
                                    ],
                                ),
                            )
                        ],
                    )

                )
            ]
        );
    }

    // 단화방 입장 UI
    Widget enterNotice(ChatMessage chatMessage, bool isLastMessage) {
        return new Container(
            child: Container(
                margin: EdgeInsets.only(
                    top: ScreenUtil.getInstance().setHeight(9),
                    bottom: isLastMessage
                        ? ScreenUtil.getInstance().setHeight(18)
                        : ScreenUtil.getInstance().setHeight(0)
                ),
                width: ScreenUtil().setWidth(359),
                height: ScreenUtil().setHeight(24),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.16),
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil.getInstance().setWidth(4))
                    )
                ),
                child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text(
                            chatMessage.senderIdx.toString(),
                            style: TextStyle(
                                fontFamily: "NotoSans",
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenUtil(allowFontScaling: true).setSp(11),
                                color: Colors.white
                            ),
                        ),
                        Text(
                            "님이 입장하였습니다.",
                            style: TextStyle(
                                fontFamily: "NotoSans",
                                fontWeight: FontWeight.w400,
                                fontSize: ScreenUtil(allowFontScaling: true).setSp(11),
                                color: Colors.white
                            ),
                        )
                    ],
                )
            )
        );
    }

    // 단화방 퇴장 UI
    Widget quitNotice(ChatMessage chatMessage, bool isLastMessage) {
        return new Container(
            child: Container(
                margin: EdgeInsets.only(
                    top: ScreenUtil.getInstance().setHeight(9),
                    bottom: isLastMessage
                        ? ScreenUtil.getInstance().setHeight(18)
                        : ScreenUtil.getInstance().setHeight(0)
                ),
                width: ScreenUtil().setWidth(359),
                height: ScreenUtil().setHeight(24),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.16),
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil.getInstance().setWidth(4))
                    )
                ),
                child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text(
                            chatMessage.senderIdx.toString() + "님이 단화방을 떠났습니다.",
                            style: TextStyle(
                                fontSize: ScreenUtil(allowFontScaling: true).setSp(11),
                                color: Colors.white
                            ),
                        )
                    ],
                )
            )
        );
    }

    // 이미지 메세지 말풍선 스타일
    Widget imageBubble(ChatMessage chatMessage, bool isReceived) {
        return Container(
            margin: EdgeInsets.only(
                bottom: ScreenUtil.getInstance().setHeight(14)
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                    // 시간 레이아웃 (보낸 메세지)
                    isReceived
                        ? Container()
                        : msgTime(chatMessage.chatTime, isReceived)
                    ,
                    GestureDetector(
                        child: Container(
                            child: ClipRRect(
                                borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(10)),
                                child: Image.asset(
//                                chatMessage.message,
                                    "assets/images/profile_img.png",
                                    width: ScreenUtil().setWidth(230),
                                )
                            ),
                        ),
                        onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => FullPhoto(url: "assets/images/profile_img.png")));
                        },
                    ),

                    // 시간 레이아웃 (받은 메세지)
                    isReceived
                        ? msgTime(chatMessage.chatTime, isReceived)
                        : Container()
                    ,
                ],
            ),
        );
    }

    // 명함 메세지 말풍선 스타일
    Widget businessCardBubble(ChatMessage chatMessage, bool isReceived) {
        return Container(
            margin: EdgeInsets.only(
                bottom: ScreenUtil.getInstance().setHeight(14)
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                    // 시간 레이아웃 (보낸 메세지)
                    isReceived
                        ? Container()
                        : msgTime(chatMessage.chatTime, isReceived)
                    ,
                    GestureDetector(
                        child: Container(
                            width: ScreenUtil().setWidth(230),
                            height: ScreenUtil.getInstance().setHeight(163),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    width: ScreenUtil().setWidth(1),
                                    color: Color.fromRGBO(219, 219, 219, 1)
                                ),
                                borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(8)),
                            ),
                            child: Column(
                                children: <Widget>[
                                    Container(
                                        width: ScreenUtil().setWidth(230),
                                        height: ScreenUtil().setHeight(43),
                                        padding: EdgeInsets.only(
                                            left: ScreenUtil().setWidth(12.5),
                                            right: ScreenUtil().setWidth(10),
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
                                            children: <Widget>[
                                                Container(
                                                    width: ScreenUtil().setWidth(183.5),
                                                    child: Row(
                                                        children: <Widget>[
                                                            Container(
                                                                child: Text(
                                                                    chatMessage.senderIdx.toString(),
                                                                    style: TextStyle(
                                                                        fontFamily: "NotoSans",
                                                                        fontWeight: FontWeight.w600,
                                                                        fontSize: ScreenUtil(allowFontScaling: true).setSp(15),
                                                                        color: Color.fromRGBO(39, 39, 39, 1),
                                                                        letterSpacing: ScreenUtil().setWidth(-0.75)
                                                                    ),
                                                                ),
                                                            ),
                                                            Container(
                                                                child: Text(
                                                                    '님의 명함 공유',
                                                                    style: TextStyle(
                                                                        fontFamily: "NotoSans",
                                                                        fontWeight: FontWeight.w400,
                                                                        fontSize: ScreenUtil(allowFontScaling: true).setSp(15),
                                                                        color: Color.fromRGBO(39, 39, 39, 1),
                                                                        letterSpacing: ScreenUtil().setWidth(-0.75)
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    )
                                                ),
                                                Container(
                                                    width: ScreenUtil().setWidth(22),
                                                    child: InkWell(
                                                        child: Image.asset(
                                                            "assets/images/icon/navIconDown.png"
                                                        ),
                                                        onTap: (){
                                                            /// 명함 다운로드
                                                            print("명함");
                                                        },
                                                    ),
                                                )
                                            ],
                                        )
                                    ),
                                    Container(
                                        width: ScreenUtil().setWidth(164),
                                        height: ScreenUtil().setHeight(91),
                                        margin: EdgeInsets.only(
                                            top: ScreenUtil().setHeight(12),
                                            bottom: ScreenUtil().setHeight(14),
                                        ),
                                        child: Image.asset(
                                            chatMessage.message,
                                            fit:BoxFit.fitWidth
                                        ),
                                    )
                                ],
                            )
                        ),
                        onTap: () {
                            Navigator.push(
                                /// Parameter 맵핑
                                context, MaterialPageRoute(builder: (context) => BusinessCardDetail(userNick: chatMessage.senderIdx.toString(),url: chatMessage.message)));
                        },
                    ),

                    // 시간 레이아웃 (받은 메세지)
                    isReceived
                        ? msgTime(chatMessage.chatTime, isReceived)
                        : Container()
                    ,
                ],
            ),
        );
    }
}

