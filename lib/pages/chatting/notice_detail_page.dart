import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/models/chat_notice_item.dart';
import 'package:Hwa/data/models/chat_notice_reply.dart';
import 'package:Hwa/data/state/chat_notice_reply_provider.dart';
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:Hwa/utility/convert_time.dart';
import 'package:Hwa/constant.dart';

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-23
 * @description : 공지사항 리스트
 */
class NoticeDetailPage extends StatefulWidget {
    final ChatNoticeItem notice;
    final ChatInfo chatInfo;
    NoticeDetailPage({Key key, @required this.notice, this.chatInfo}) :super(key: key);

    @override
    State createState() => new NoticeDetailPageState(notice: notice, chatInfo: chatInfo);
}

class NoticeDetailPageState extends State<NoticeDetailPage> {
    final ChatNoticeItem notice;
    final ChatInfo chatInfo;

    NoticeDetailPageState({Key key, this.notice, this.chatInfo});
    ChatRoomNoticeReplyProvider chatRoomNoticeReplyProvider;
    UserInfoProvider userInfoProvider;

    bool isEmpty;           // 채팅 입력 여부
    int inputLineCount;     // 채팅 입력 줄 수
    int _inputHeight;       // 입력칸 높이
    TextEditingController textEditingController = TextEditingController();

    @override
    void initState() {
        chatRoomNoticeReplyProvider = Provider.of<ChatRoomNoticeReplyProvider>(context, listen: false);
        userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
        _initState();


        super.initState();
        isEmpty = true;
        inputLineCount = 1;
        _inputHeight = 36;
    }

    void _initState() async {
        await chatRoomNoticeReplyProvider.getNoticeReplyList(chatInfo.chatIdx, notice.idx);
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                brightness: Brightness.light,
                title: Text(
                    chatInfo.title,
                    style: TextStyle(
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil().setSp(16),
                        fontFamily: "NotoSans"
                    ),
                ),
                elevation: 0.0,
                leading: new IconButton(
                    icon: new Image.asset('assets/images/icon/navIconClose.png'),
                    onPressed: (){
                        chatRoomNoticeReplyProvider.noticeReplyList = <ChatNoticeReply>[];
                        Navigator.of(context).pop();
                    }
                ),
                centerTitle: true,
                backgroundColor: Color.fromRGBO(250, 250, 250, 1),
            ),
            body: new GestureDetector(
                child: buildNotice(),
                onTap: (){
                    FocusScope.of(context).requestFocus(new FocusNode());
                },
            ),
        );
    }

    Widget buildNotice() {
        chatRoomNoticeReplyProvider = Provider.of<ChatRoomNoticeReplyProvider>(context, listen: true);
        return Container(
            color: Color.fromRGBO(235, 235, 235, 1),
            child: Column(
                children: <Widget>[
                    // 공지 본문 영역
                    buildNoticeBody(),

                    // 공지 댓글 영역
                    Flexible(
                        child: ListView.builder(
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(16.0),
                                right: ScreenUtil().setWidth(16.0)
                            ),

                            itemCount: chatRoomNoticeReplyProvider.noticeReplyList.length,
                            itemBuilder: (BuildContext context, int index) => buildNoticeReply(chatRoomNoticeReplyProvider.noticeReplyList[index]),
                        )
                    ),

                    // 댓글 입력 영역
                    inputReply(),
                ],
            ),
        );
    }

    /// 공지 본문
    Widget buildNoticeBody() {
        return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(
                        width: ScreenUtil().setWidth(0.5),
                        color: Color.fromRGBO(178, 178, 178, 0.8)
                    )
                )
            ),
            child: Column (
                children: <Widget>[
                    /// 공지 작성자 정보
                    Container(
                        padding: EdgeInsets.only(
                            top: ScreenUtil().setHeight(13),
                            bottom: ScreenUtil().setHeight(12),
                            left: ScreenUtil().setWidth(16),
                            right: ScreenUtil().setWidth(16),
                        ),
                        margin: EdgeInsets.only(
                            bottom: ScreenUtil().setHeight(10)
                        ),
                        color: Colors.white,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(
                                        right: ScreenUtil().setWidth(11)
                                    ),
                                    child: FadeInImage(
                                        width: ScreenUtil().setHeight(40),
                                        height: ScreenUtil().setHeight(40),
                                        placeholder: AssetImage("assets/images/icon/profile.png"),
                                        image: widget.notice.profile_picture_idx == null ? Image.asset("assets/images/icon/profile.png")
                                            : CachedNetworkImageProvider(Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + widget.notice.user_idx.toString() + "&type=SMALL", headers: Constant.HEADER),
                                        fit: BoxFit.cover,
                                        fadeInDuration: Duration(milliseconds: 1)
                                    )
                                ),
                                Container(
                                    margin: EdgeInsets.only(
                                        top: ScreenUtil().setHeight(5)
                                    ),
                                    child: Column (
                                        children: <Widget>[
                                            Container(
                                                width: ScreenUtil().setWidth(245),
                                                margin: EdgeInsets.only(
                                                    bottom: ScreenUtil().setWidth(5)
                                                ),
                                                child: Text(
                                                    notice.nickname.toString(),
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil().setSp(13),
                                                        fontFamily: "NotoSans",
                                                        fontWeight: FontWeight.w500,
                                                        color: Color.fromRGBO(39, 39, 39, 1),
                                                        letterSpacing: ScreenUtil().setWidth(-0.65),
                                                        height: 1,
                                                    ),
                                                )
                                            ),
                                            Container(
                                                width: ScreenUtil().setWidth(245),
                                                height: ScreenUtil().setHeight(13.5),
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: <Widget>[
                                                        Container(
                                                            margin: EdgeInsets.only(
                                                                right: ScreenUtil().setWidth(13.5)
                                                            ),
                                                            child: Text(
                                                                DateFormat("yyyy-MM-DD HH:mm:ss").format(DateTime.parse(notice.reg_ts)).toString(),
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(13),
                                                                    fontFamily: "NanumSquare",
                                                                    fontWeight: FontWeight.w400,
                                                                    height: 1.1,
                                                                    color: Color.fromRGBO(107, 107, 107, 1)
                                                                ),
                                                            ),
                                                        ),
                                                        Container(
                                                            margin: EdgeInsets.only(
                                                                right: ScreenUtil().setWidth(5.5)
                                                            ),
                                                            child: Text(
                                                                '댓글',
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(13),
                                                                    height: 1.1,
                                                                    color: Color.fromRGBO(107, 107, 107, 1)
                                                                ),
                                                            ),
                                                        ),
                                                        Container(
                                                            child: Text(
                                                                notice.reply_cnt.toString(),
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(13),
                                                                    fontFamily: "NanumSquare",
                                                                    fontWeight: FontWeight.w400,
                                                                    height: 1.1,
                                                                    color: Color.fromRGBO(107, 107, 107, 1)
                                                                ),
                                                            ),
                                                        )
                                                    ],
                                                )
                                            )
                                        ],
                                    )
                                )
                            ],
                        )
                    ),
                    /// 공지 내용
                    Row(
                        children: <Widget>[
                            Container(
                                margin: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(4.75),
                                    bottom: ScreenUtil().setHeight(17.75),
                                ),
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(16),
                                    right: ScreenUtil().setWidth(16),
                                ),
                                child: Text(
                                    widget.notice.contents,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(15),
                                        fontFamily: "NotoSans",
                                        fontWeight: FontWeight.w400,
                                        height: 1.6,
                                        letterSpacing: ScreenUtil().setWidth(-0.75),
                                        color: Color.fromRGBO(39, 39, 39, 1)
                                    ),
                                ),
                            )
                        ],
                    )
                ],
            )
        );
    }

    /// 댓글 영역
    Widget buildNoticeReply(ChatNoticeReply noticeReply) {
        return Container(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(12),
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setHeight(1),
                            right: ScreenUtil().setWidth(16)
                        ),
                        child: ClipRRect(
                            borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(45)),
                            child: noticeReply.profile_picture_idx == 0 ? Image.asset("assets/images/icon/profile.png")
                                : CachedNetworkImageProvider(Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + noticeReply.user_idx.toString() + "&type=SMALL", headers: Constant.HEADER),
                        )
                    ),
                    Container(
                        width: ScreenUtil().setWidth(277),
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setHeight(5)
                        ),
                        padding: EdgeInsets.only(
                            bottom: ScreenUtil().setHeight(18),
                        ),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: ScreenUtil().setWidth(0.5),
                                    color: Color.fromRGBO(39, 39, 39, 0.15)
                                )
                            )
                        ),
                        child: Column (
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                        Container(
                                            child: Row(
                                                children: <Widget>[
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            right: ScreenUtil().setWidth(7.5)
                                                        ),
                                                        child: Text(
                                                            noticeReply.nickname,
                                                            style: TextStyle(
                                                                fontSize: ScreenUtil().setSp(13),
                                                                fontFamily: "NotoSans",
                                                                fontWeight: FontWeight.w500,
                                                                color: Color.fromRGBO(39, 39, 39, 1),
                                                                letterSpacing: ScreenUtil().setWidth(-0.65),
                                                                height: 1,
                                                            ),
                                                        )
                                                    ),
                                                    Container(
                                                        child: Text(
                                                            DateFormat("yyyy-MM-DD HH:mm:ss").format(DateTime.parse(noticeReply.reg_ts)).toString(),
                                                            style: TextStyle(
                                                                fontSize: ScreenUtil().setSp(11),
                                                                fontFamily: "NanumSquare",
                                                                fontWeight: FontWeight.w400,
                                                                height: 1.1,
                                                                color: Color.fromRGBO(107, 107, 107, 1)
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        notice.user_idx == userInfoProvider.idx || noticeReply.user_idx == userInfoProvider.idx ? Container(
                                            child: GestureDetector(
                                                child: Container(
                                                    width: ScreenUtil().setWidth(20),
                                                    height: ScreenUtil().setHeight(20),
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image:AssetImage("assets/images/icon/iconDeleteSmall.png")
                                                        ),
                                                    )
                                                ),
                                                onTap:(){
                                                    chatRoomNoticeReplyProvider.deleteNoticeReply(noticeReply.idx);
                                                }
                                            ),
                                        ) : Container()
                                    ],
                                ),
                                Row(
                                    children: <Widget>[
                                        Container(
                                            width: ScreenUtil().setWidth(277),
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setWidth(12)
                                            ),
                                            child: Text(
                                                noticeReply.contents,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil().setSp(15),
                                                    fontFamily: "NotoSans",
                                                    fontWeight: FontWeight.w400,
                                                    height: 1,
                                                    letterSpacing: ScreenUtil().setWidth(-0.75),
                                                    color: Color.fromRGBO(39, 39, 39, 1)
                                                ),
                                            ),
                                        )
                                    ],
                                )
                            ],
                        )
                    )
                ],
            )
        );
    }

    /// 댓글 입력 영역
    Widget inputReply() {
        return Container(
            width: ScreenUtil().setWidth(375),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(8),
                right: ScreenUtil().setWidth(8),
                top: ScreenUtil().setHeight(6),
                bottom: ScreenUtil().setHeight(6)
            ),
            decoration: BoxDecoration(
                color: Colors.white,
            ),
            child: Container(
                width: ScreenUtil().setWidth(359),
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
                        /// 입력 영역
                        Expanded (
                            child: Container(
                                width: ScreenUtil().setWidth(359),
                                height: ScreenUtil().setHeight(_inputHeight),
                                margin: EdgeInsets.only(
                                    right: ScreenUtil().setWidth(8)
                                ),

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
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromRGBO(39, 39, 39, 1),
                                                fontSize: ScreenUtil().setSp(15),
                                                letterSpacing: ScreenUtil().setWidth(-0.75),
                                            ),
                                            decoration: InputDecoration(
                                                hintText: '댓글을 남겨보세요',
                                                hintStyle: TextStyle(
                                                    fontSize: ScreenUtil().setSp(15),
                                                    color: Color.fromRGBO(39, 39, 39, 0.4),
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.only(
                                                    bottom: ScreenUtil().setHeight(10.5),
                                                    left: ScreenUtil().setWidth(13),
                                                    right: ScreenUtil().setWidth(9)
                                                )
                                            ),
                                            autofocus: false,
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
                        /// 등록 버튼
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
                                    chatRoomNoticeReplyProvider.writeNoticeReply(textEditingController.text, chatInfo.chatIdx, notice.idx, userInfoProvider);
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
            )
        );
    }
}
