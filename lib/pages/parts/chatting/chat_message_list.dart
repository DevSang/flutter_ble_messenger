import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';

import 'package:Hwa/pages/parts/chatting/full_photo.dart';
import 'package:Hwa/pages/parts/chatting/full_video_player.dart';
import 'package:Hwa/utility/gauge_animate.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/service/get_time_difference.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/pages/chatting/youtube_page.dart';
import 'package:Hwa/data/state/user_info_provider.dart';


/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-23
 * @description : 단화방 채팅 요소 맵핑
 */
class ChatMessageList extends StatefulWidget {
    final List<ChatMessage> messageList;    // 단화방 메세지 리스트

    ChatMessageList({this.messageList});

    @override
    State createState() => new ChatMessageListState(messageList: messageList);
}

class ChatMessageListState extends State<ChatMessageList> {
    final List<ChatMessage> messageList;

    ChatMessageListState({this.messageList});

    int clickedMessage;
    double sameSize;

    @override
    Widget build(BuildContext context) {
        return Flexible(
            child: ListView.builder(
                padding: EdgeInsets.only(
                    top: ScreenUtil().setHeight(50),
                    left: ScreenUtil().setWidth(13),
                    right: ScreenUtil().setWidth(13)
                ),
                reverse: true,

                itemCount: messageList.length,

                itemBuilder: (BuildContext context, int index) => buildChatMessage(index, messageList[index]),
            )
        );
    }

    @override
    void initState() {
        sameSize = GetSameSize().main();
    	super.initState();
    }

    /*
     * @author : hk
     * @date : 2019-12-31
     * @description : 썸네일 호출 파라미터 제거
     */
    String getOriginImgUri(String uri){
    	String processedUrl;

	    if(uri.contains("&")){
		    String lastParam = uri.substring(uri.lastIndexOf("&"), uri.length);
		    if("&type=SMALL" == lastParam) processedUrl = uri.substring(0, uri.lastIndexOf("&"));
	    }else{
		    processedUrl = uri;
	    }

	    return processedUrl;
    }

    /*
     * @author : hs
     * @date : 2019-12-22
     * @description : 마지막 보낸 메세지 여부
    */
    bool checkMessage(int index) {
        if (index == 0) { return true; }
        else if (index > 0 && messageList != null) {

            if (((messageList[index].chatType == "TALK") && (messageList[index - 1].senderIdx != Constant.USER_IDX))
                || ((messageList[index].chatType == "TALK") && (messageList[index - 1].chatType != "TALK"))
                || ((messageList[index].chatType == "ENTER" || messageList[index].chatType == "QUIT") && (messageList[index - 1].chatType != "ENTER") && (messageList[index - 1].chatType != "QUIT"))) {
                return true;
            }
            else { return false; }
        } else { return false; }
    }

    // 메세지 맵핑
    Widget buildChatMessage(int chatIndex, ChatMessage chatMessage) {
        bool isLastSendMessage = checkMessage(chatIndex);
        int userIdx = Constant.USER_IDX;

        // false : Send, true : Received
        bool receivedMsg = (userIdx != chatMessage.senderIdx)
                            ? true
                            : false;

        // chatType(TALK, ENTER, QUIT)에 따른 화면 처리
        Widget chatElement = chatMessage.chatType == "ENTER"
            ? eqNotice(chatMessage, true, isLastSendMessage)                 // 입장 메세지
            : chatMessage.chatType == "QUIT"
                ? eqNotice(chatMessage, false, isLastSendMessage)            // 퇴장 메세지
                : receivedMsg
                    ? receivedLayout(chatIndex, chatMessage, isLastSendMessage) // 받은 메세지
                    : sendLayout(chatIndex, chatMessage, isLastSendMessage);    // 보낸 메세지

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

    _playYoutube(ChatMessage chatMessage){
    	// youtube 객체가 있으면 반응
		if(chatMessage.youtubePlayer != null){
			GlobalKey key = GlobalKey();

			Navigator.push(context,
					MaterialPageRoute(builder: (context) {
						return YoutubePage(chatMessage: chatMessage, key: key);
					})
			);
		}
    }

    // 받은 메세지 레이아웃 (프로필이미지, 이름, 시간)
    Widget receivedLayout(int chatIndex, ChatMessage chatMessage, bool isLastSendMessage) {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                thumbnail(chatMessage),

                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Text(
                                chatMessage.nickName,
                                style: TextStyle(
                                    fontFamily: "NotoSans",
                                    fontWeight: FontWeight.w400,
                                    fontSize: ScreenUtil().setSp(11),
                                    color: Color.fromRGBO(39, 39, 39, 0.7),
                                    letterSpacing: ScreenUtil().setHeight(-0.28),
                                )
                            ),
                            chatMessage.chatType == "TALK"
                                ? receivedText(chatIndex, chatMessage, true)
                                : chatMessage.chatType == "IMAGE"
                                ? imageBubble(chatMessage, isLastSendMessage, true)
                                : chatMessage.chatType == "VIDEO"
                                ? videoBubble(chatMessage, isLastSendMessage, true)
                                : businessCardBubble(chatMessage, isLastSendMessage, true)
                        ],
                    )
                )
            ],
        );
    }

    // 보낸 메세지 레이아웃 (프로필이미지, 이름, 시간)
    Widget sendLayout(int chatIndex, ChatMessage chatMessage, bool isLastSendMessage) {

        return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                            chatMessage.chatType == "TALK"
                                ? sendText(chatIndex, chatMessage, isLastSendMessage, false)
                                : chatMessage.chatType == "IMAGE"
                                    ? imageBubble(chatMessage, isLastSendMessage, false)
                                    : chatMessage.chatType == "VIDEO"
                                        ? videoBubble(chatMessage, isLastSendMessage, false)
                                        : chatMessage.chatType == "UPLOADING_IMG"
                                            ? uploadingImageBubble(chatMessage, isLastSendMessage)
                                            : businessCardBubble(chatMessage, isLastSendMessage, false)
                        ],
                    )
                )
            ],
        );
    }

    // 받은 메세지 유저 프로필 이미지
    Widget thumbnail(ChatMessage chatMessage) {
        return new Container(
            margin: EdgeInsets.only(
                right: ScreenUtil().setWidth(7)),
            child: CircleAvatar(
                child: chatMessage.profileImgUri != null ? getProfileImg(chatMessage) : getTextProfile(chatMessage),
                backgroundColor: Color.fromRGBO(77, 96, 191, 1),
            )
        );
    }

    // 사용자 프로필 이미지 캐시 return
    Widget getProfileImg(ChatMessage chatMessage){
    	return ClipOval(
		    child: CachedNetworkImage(
				    imageUrl: chatMessage.profileImgUri,
				    placeholder: (context, url) => CircularProgressIndicator(),
				    errorWidget: (context, url, error) => Image.asset('assets/images/icon/profile.png',fit: BoxFit.cover),
				    httpHeaders: Constant.HEADER
		    ),
	    );
    }

    // 사용자 텍스트 프로필 이미지 return
    Widget getTextProfile(ChatMessage chatMessage){
    	try {
		    return Text(
			        chatMessage.nickName[0],
			        style: TextStyle(
					        fontFamily: "NotoSans",
					        fontWeight: FontWeight.w400,
					        color: Color.fromRGBO(255, 255, 255, 1)
			        )
	        );
	    } catch (e) {
		    return Image.asset('assets/images/icon/profile.png',fit: BoxFit.cover);
	    }
    }

    // 메세지 시간 레이아웃
    Widget msgTime(int chatTime, bool receivedMsg) {
        return Container(
            margin:
            receivedMsg
                ? EdgeInsets.only(
                    bottom: ScreenUtil().setHeight(4),
                    left: ScreenUtil().setWidth(7))
                : EdgeInsets.only(
                    bottom: ScreenUtil().setHeight(4),
                    right: ScreenUtil().setWidth(7))
            ,
            child: Text(
                GetTimeDifference.timeDifference(chatTime),
                style: TextStyle(
                    height: 1,
                    fontFamily: "NanumSquare",
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenUtil().setSp(11),
                    letterSpacing: ScreenUtil().setWidth(-0.28),
                    color: Color.fromRGBO(39, 39, 39, 0.7)
                )
            ),
        );
    }

    // 받은 메세지 말풍선 스타일
    Widget receivedText(int chatIndex, ChatMessage chatMessage, bool receivedMsg) {
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
                    width: ScreenUtil().setWidth(15),
                    height: ScreenUtil().setHeight(5),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                    ScreenUtil().setWidth(10)
                                )
                            ),
                            color: Color.fromRGBO(250, 250, 251, 1)
                        )
                    ),
                ),
                // Bubble
                Container(
                    margin: EdgeInsets.only(
                        bottom: sameSize*14
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                            GestureDetector(
                                child: Container(
                                    constraints: BoxConstraints(maxWidth: 230),
                                    padding: EdgeInsets.only(
                                        top: sameSize*10.5,
                                        bottom: sameSize*10.5,
                                        left: sameSize*14.5,
                                        right: sameSize*14.5,
                                    ),

                                    child: textLayout(chatMessage, receivedMsg),
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
    Widget sendText(int chatIndex, ChatMessage chatMessage, bool isLastSendMessage, bool receivedMsg) {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                            Container(
                                color: Color.fromRGBO(76, 96, 191, 1),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                width: ScreenUtil().setWidth(15),
                                height: ScreenUtil().setHeight(5),
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(
                                                ScreenUtil().setWidth(10)
                                            )
                                        ),
                                        color: Color.fromRGBO(250, 250, 251, 1)
                                    )
                                ),
                            ),
                            Container(
                                margin: EdgeInsets.only(
                                    bottom:
                                    isLastSendMessage
                                        ? ScreenUtil().setHeight(14)
                                        : ScreenUtil().setHeight(0)
                                ),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                        msgTime(chatMessage.chatTime, false),
                                        Container(
                                            constraints: BoxConstraints(maxWidth: 230),
                                            padding: EdgeInsets.only(
                                                top: sameSize*10.5,
                                                bottom: sameSize*10.5,
                                                left: sameSize*14.5,
                                                right: sameSize*14.5,
                                            ),
                                            child: textLayout(chatMessage, receivedMsg),
                                            decoration: BoxDecoration(
                                                color: Color.fromRGBO(76, 96, 191, 1),
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

    // 단화방 입장/퇴장 UI
    Widget eqNotice(ChatMessage chatMessage, bool isEnter, bool isLastMessage) {
        print(isLastMessage);
        return new Container(
            margin: EdgeInsets.only(
                top: sameSize*9,
                bottom: isLastMessage ? sameSize*20 : 0
            ),
            width: ScreenUtil().setWidth(359),
            height: sameSize*24,
            decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                borderRadius: BorderRadius.all(
                    Radius.circular(ScreenUtil().setWidth(4))
                )
            ),
            child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    Text(
                        chatMessage.nickName.toString(),
                        style: TextStyle(
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w700,
                            fontSize: ScreenUtil().setSp(11),
                            color: Colors.white
                        ),
                    ),
                    Text(
                        isEnter ? "님이 입장하였습니다." : "님이 단화방을 떠났습니다.",
                        style: TextStyle(
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenUtil().setSp(11),
                            color: Colors.white
                        ),
                    )
                ],
            )
        );
    }

    // 이미지 메세지 스타일
    Widget imageBubble(ChatMessage chatMessage, bool isLastSendMessage, bool receivedMsg) {
        return Container(
            margin: EdgeInsets.only(
                top:
                receivedMsg
                    ? ScreenUtil().setHeight(9)
                    : ScreenUtil().setHeight(0),
                bottom: ScreenUtil().setHeight(14)
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: receivedMsg ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: <Widget>[
                    !receivedMsg ? msgTime(chatMessage.chatTime, receivedMsg) : Container() ,
                    InkWell(
                        child: Container(
                            width: ScreenUtil().setWidth(230),
                            height: ScreenUtil().setWidth(230),
                            child: ClipRRect(
                                borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(10)),
                                child: CachedNetworkImage(
                                    width: ScreenUtil().setWidth(230),
                                    imageUrl: chatMessage.message,
                                    fadeInDuration: const Duration(milliseconds: 0),
                                    placeholder: (context, url) =>
                                        Container(
                                            width: ScreenUtil().setWidth(230),
                                            height: ScreenUtil().setWidth(230),
                                            color: Colors.transparent,
                                            child: Center(
                                                child: Container(
                                                    width: ScreenUtil().setWidth(30),
                                                    height: ScreenUtil().setWidth(30),
                                                    child: const CircularProgressIndicator(
                                                        valueColor: AlwaysStoppedAnimation<Color>(
                                                            Color.fromRGBO(76, 96, 191, 1),
                                                        )
                                                    ),
                                                ),
                                            ),
                                        ),
                                    httpHeaders: Constant.HEADER,
                                    fit: BoxFit.cover,
                                )
                            ),
                        ),
                        onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(
                                builder: (context) =>
                                    FullPhoto(photoUrl: getOriginImgUri(chatMessage.message))
                            ));
                        },
                    ),
                    receivedMsg ? msgTime(chatMessage.chatTime, receivedMsg) : Container()
                ],
            ),
        );
    }

    // 텍스트 레이아웃
    Widget textLayout(ChatMessage chatMessage, bool receivedMsg) {
        return InkWell(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Text(
                        chatMessage.message,
                        style: chatMessage.youtubePlayer != null
                            ? TextStyle(
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            fontSize: ScreenUtil().setSp(13),
                            letterSpacing: ScreenUtil().setWidth(-0.75),
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                            height: 1.14
                        )
                            : TextStyle(
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            fontSize: ScreenUtil().setSp(15),
                            color: receivedMsg ? Color.fromRGBO(39, 39, 39, 1) : Color.fromRGBO(255, 255, 255, 1),
                            letterSpacing: ScreenUtil().setWidth(-0.75),
                            height: 1.14
                        ),
                    ),
                    chatMessage.youtubePlayer != null
                        ? linkLayout(chatMessage.youtubePlayer)
                        : Container(
                        width: 0
                    ),
                    chatMessage.youtubePlayer != null
                        ? Text(
                        "유튜브 제목제목",
                        style: TextStyle(
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            fontSize: ScreenUtil().setSp(15),
                            color: receivedMsg ? Color.fromRGBO(39, 39, 39, 1) : Color.fromRGBO(255, 255, 255, 1),
                            height: 1.14
                        ),
                    )
                        : Container(
                        width: 0
                    )
                ],
            ),
            onTap: (){
                _playYoutube(chatMessage);
            },
        );
    }

    // 링크 형 레이아웃
    Widget linkLayout(YoutubePlayer youtubePlayer) {
        return Container(
            margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(8),
                bottom: ScreenUtil().setHeight(6)
            ),
            child: Stack(
                children: <Widget>[
                    Container(
                        child: Image.network(
                            youtubePlayer.thumbnailUrl
                        ),
                    ),
                    Positioned.fill(
                        child: Align(
                            alignment: Alignment.center,
                            child: Container(
                                width: ScreenUtil().setWidth(38),
                                height: ScreenUtil().setWidth(38),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image:AssetImage("assets/images/icon/iconVideoPlay.png")
                                    ),
                                )
                            ),
                        )
                    )
                ],
            ),
        );
    }

    // 비디오 메세지 스타일
    Widget videoBubble(ChatMessage chatMessage, bool isLastSendMessage, bool receivedMsg) {
        return Container(
            margin: EdgeInsets.only(
                top:
                receivedMsg
                    ? ScreenUtil().setHeight(9)
                    : ScreenUtil().setHeight(0),
                bottom: ScreenUtil().setHeight(14)
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: receivedMsg ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: <Widget>[
                    !receivedMsg ? msgTime(chatMessage.chatTime, receivedMsg) : Container() ,
                    InkWell(
                        child: Container(
                            width: ScreenUtil().setWidth(230),
                            child: Stack(
                                children: <Widget>[
                                    ClipRRect(
                                        borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(10)),
                                        child: CachedNetworkImage(
                                            imageUrl: chatMessage.message,
                                            fadeInDuration: const Duration(milliseconds: 0),
                                            placeholder: (context, url) =>
                                                Container(
                                                    width: ScreenUtil().setWidth(230),
                                                    color: Colors.transparent,
                                                    child: Center(
                                                        child: Container(
                                                            width: ScreenUtil().setWidth(30),
                                                            height: ScreenUtil().setWidth(30),
                                                            child: const CircularProgressIndicator(
                                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                                    Color.fromRGBO(76, 96, 191, 1),
                                                                )
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            httpHeaders: Constant.HEADER,
                                            fit: BoxFit.cover,
                                        )
                                    ),
                                    Positioned.fill(
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                                width: ScreenUtil().setWidth(38),
                                                height: ScreenUtil().setWidth(38),
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image:AssetImage("assets/images/icon/iconVideoPlay.png")
                                                    ),
                                                )
                                            ),
                                        )
                                    )
                                ],
                            )
                        ),
                        onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => FullVideoPlayer(videoUrl: getOriginImgUri(chatMessage.message), chatMessage: chatMessage))
                            );
                        },
                    ),
                    receivedMsg ? msgTime(chatMessage.chatTime, receivedMsg) : Container()
                ],
            ),
        );
    }

    // 업로드 중 썸네일 스타일
    Widget uploadingImageBubble(ChatMessage chatMessage, bool isLastSendMessage) {
        bool isFile;
        if (chatMessage.thumbnailFile.runtimeType.toString() == '_File') {
            isFile = true;
        } else {
            isFile = false;
        }

        return Container(
            margin: EdgeInsets.only(
                bottom: ScreenUtil().setHeight(14)
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                    msgTime(chatMessage.chatTime, false) ,
                    Container(
                        width: ScreenUtil().setWidth(230),
                        height: ScreenUtil().setWidth(230),
                        child: Stack(
                            children: <Widget>[
                                ClipRRect(
                                    borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(10)),
                                    child:
                                    isFile
                                        ? Image.file(
                                            chatMessage.thumbnailFile,
                                            gaplessPlayback: true,
                                            fit: BoxFit.cover,
                                            width: ScreenUtil().setWidth(230),
                                            height: ScreenUtil().setWidth(230),
                                        )
                                        : Image.memory(
                                            chatMessage.thumbnailFile,
                                            gaplessPlayback: true,
                                            fit: BoxFit.cover,
                                            width: ScreenUtil().setWidth(230),
                                            height: ScreenUtil().setWidth(230),
                                        )
                                ),
                                Positioned.fill(
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: GaugeAnimate(driver: chatMessage.gaugeDriver)
                                    )
                                )
                            ],
                        )
                    )
                ],
            ),
        );
    }

    // 명함 메세지 말풍선 스타일
    Widget businessCardBubble(ChatMessage chatMessage, bool isLastSendMessage, bool receivedMsg) {
        return Container(
            margin: EdgeInsets.only(
                top:
                receivedMsg
                    ? ScreenUtil().setHeight(9)
                    : ScreenUtil().setHeight(0),
                bottom: ScreenUtil().setHeight(14)
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: receivedMsg ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: <Widget>[
                    // 시간 레이아웃 (보낸 메세지)
                    !receivedMsg
                        ? msgTime(chatMessage.chatTime, receivedMsg)
                        : Container()
                    ,
                    GestureDetector(
                        child: Container(
                            width: ScreenUtil().setWidth(230),
                            height: ScreenUtil().setHeight(163),
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
                                                                    chatMessage.nickName.toString(),
                                                                    style: TextStyle(
                                                                        fontFamily: "NotoSans",
                                                                        fontWeight: FontWeight.w700,
                                                                        fontSize: ScreenUtil().setSp(15),
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
                                                                        fontSize: ScreenUtil().setSp(15),
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
                                                    height: ScreenUtil().setWidth(22),
                                                    child: InkWell(
                                                        child: Image.asset(
                                                            "assets/images/icon/navIconDown.png"
                                                        ),
                                                        onTap: (){
                                                            /// 명함 다운로드
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
                            if(Provider.of<UserInfoProvider>(context, listen: false).cacheProfileImg.errorWidget == null) {
                                Navigator.push(
                                    context, MaterialPageRoute(
                                    builder: (context) => FullPhoto(photoUrl: getOriginImgUri(chatMessage.message)))
                                );
                            };
                        }
                    ),

                    // 시간 레이아웃 (받은 메세지)
                    receivedMsg
                        ? msgTime(chatMessage.chatTime, receivedMsg)
                        : Container()
                    ,
                ],
            ),
        );
    }
}

