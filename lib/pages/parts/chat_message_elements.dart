import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/service/get_time_difference.dart';
import 'package:Hwa/constant.dart';

const String name = "hwa";

//  ListView에 추가될 메세지 위젯
class ChatMessageElements extends StatelessWidget {
    final ChatMessage chatMessage;
    final AnimationController animationController; // 등록 시 보여질 효과

    ChatMessageElements({this.chatMessage, this.animationController});

    @override
    Widget build(BuildContext context) {
        int userIdx = Constant.USER_IDX;
        // false : Send, true : Received
        bool receivedMsg = (chatMessage.chatType == "TALK" && userIdx != chatMessage.senderIdx) ? true : false;
        // chatType(TALK, ENTER, QUIT)에 따른 화면 처리
        Widget chatElement = chatMessage.chatType == "TALK"
                            ? receivedMsg
                                ? receivedBubble(context)
                                : sendBubble(context)
                            : chatMessage.chatType == "ENTER"
                                ? enterNotice(context)
                                : Container();

        // 위젯에 애니메이션을 발생하기 위해 SizeTransition을 추가
        return SizeTransition(
            sizeFactor: CurvedAnimation(parent: animationController, curve: Curves.easeOut),
            axisAlignment: 0.0,
            child: Container(
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
            ),
        );

    }

    Widget thumbnail = new Container(
        margin: EdgeInsets.only(right: ScreenUtil.getInstance().setWidth(14)),
        child: CircleAvatar(
            child: Text(name[0]),

        )
    );

    // 받은 메세지 말풍선 스타일
    Widget receivedBubble(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                Text(
                    name,
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
                                    chatMessage.message,
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
                                    GetTimeDifference.timeDifference(chatMessage.chatTime),
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
    Widget sendBubble(BuildContext context) {
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
                    child: Text(chatMessage.message),
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

    Widget enterNotice(BuildContext context) {
        return new Container(
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
                            chatMessage.senderIdx.toString() + "님이 입장하였습니다.",
                            style: TextStyle(
                                fontSize: ScreenUtil(allowFontScaling: true).setSp(22),
                                color: Colors.white
                            ),
                        )
                    ],
                )
            )
        );
    }
}