import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/service/get_time_difference.dart';
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
     * @description : 마지막 보낸 메세지 여부
    */
    bool checkMessage(int index) {
        if ((index > 0 && messageList != null && messageList[index - 1].senderIdx != Constant.USER_IDX) || index == 0) {
            return true;
        } else {
            return false;
        }
    }

    // 메세지 맵핑
    Widget buildChatMessage(int chatIndex, ChatMessage chatMessage) {
        bool isLastSendMessage = checkMessage(chatIndex);
        int userIdx = Constant.USER_IDX;
        // false : Send, true : Received
        bool receivedMsg = (chatMessage.chatType == "TALK" && userIdx != chatMessage.senderIdx) ? true : false;
        // chatType(TALK, ENTER, QUIT)에 따른 화면 처리
        Widget chatElement = chatMessage.chatType == "TALK"
            ? receivedMsg
            ? receivedBubble(chatIndex, chatMessage)
            : sendBubble(chatIndex, chatMessage, isLastSendMessage)
            : chatMessage.chatType == "ENTER"
            ? enterNotice(chatMessage)
            : quitNotice(chatMessage);

        return Container(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                    // 유저 썸네일 노출 여부 (상대방 메세지에만 노출)
                    receivedMsg ? thumbnail : new Container(),
                    Expanded(
                        child: chatElement
                    )
                ],
            )
        );
    }

    // 받은 메세지 유저 프로필 이미지
    Widget thumbnail = new Container(
        margin: EdgeInsets.only(right: ScreenUtil.getInstance().setWidth(7)),
        child: CircleAvatar(
            child: Text(name[0]),

        )
    );

    // 받은 메세지 말풍선 스타일
    Widget receivedBubble(int chatIndex, ChatMessage chatMessage) {
        bool isSelected = clickedMessage == chatIndex
                            ? true
                            : false;
        return Column(
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
                                    margin: EdgeInsets.only(
                                        right: ScreenUtil.getInstance().setWidth(7)
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
                            Container(
                                margin: EdgeInsets.only(
                                    bottom: ScreenUtil.getInstance().setHeight(4)
                                ),
                                child: Text(
                                    GetTimeDifference.timeDifference(chatMessage.chatTime),
                                    style: TextStyle(
                                        height: 1,
                                        fontFamily: "NanumSquare",
                                        fontWeight: FontWeight.w400,
                                        fontSize: ScreenUtil(allowFontScaling: true).setSp(11),
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
    Widget sendBubble(int chatIndex, ChatMessage chatMessage, bool isLastSendMessage) {
        return Column(
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
                            Container(
                                margin: EdgeInsets.only(
                                    right: ScreenUtil.getInstance().setWidth(7),
                                    bottom: ScreenUtil.getInstance().setHeight(4)
                                ),
                                child: Text(
                                    GetTimeDifference.timeDifference(chatMessage.chatTime),
                                    style: TextStyle(
                                        fontFamily: "NanumSquare",
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: ScreenUtil.getInstance().setHeight(-0.28),
                                        fontSize: ScreenUtil(allowFontScaling: true).setSp(11),
                                        color: Color.fromRGBO(39, 39, 39, 0.7)
                                    )
                                ),
                            ),
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
        );
    }

    // 단화방 입장 UI
    Widget enterNotice(ChatMessage chatMessage) {
        return new Container(
            child: Container(
                margin: EdgeInsets.only(
                    top: ScreenUtil.getInstance().setHeight(9),
                    bottom: ScreenUtil.getInstance().setHeight(9)
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
    Widget quitNotice(ChatMessage chatMessage) {
        return new Container(
            child: Container(
                margin: EdgeInsets.only(
                    top: ScreenUtil.getInstance().setHeight(9),
                    bottom: ScreenUtil.getInstance().setHeight(9)
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
}
