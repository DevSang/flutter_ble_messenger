import 'package:Hwa/data/models/chat_notice_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/state/chat_notice_item_provider.dart';
import 'package:Hwa/data/state/user_info_provider.dart';


/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-23
 * @description : 공지사항 리스트
 */
class NoticeWritePage extends StatefulWidget {
    final ChatInfo chatInfo;
    final bool isUpdate;
    final ChatNoticeItem notice;
    NoticeWritePage({Key key, @required this.chatInfo, this.isUpdate, this.notice}) :super(key: key);

    @override
    State createState() => new NoticeWritePageState(chatInfo: chatInfo, isUpdate: isUpdate, notice: notice);
}

class NoticeWritePageState extends State<NoticeWritePage> {
    final ChatInfo chatInfo;
    final bool isUpdate;
    final ChatNoticeItem notice;
    NoticeWritePageState({Key key, @required this.chatInfo, this.isUpdate, this.notice});

    TextEditingController textEditingController = TextEditingController();
    ChatRoomNoticeInfoProvider chatRoomNoticeInfoProvider;
    UserInfoProvider userInfoProvider;

    @override
    void initState() {
        chatRoomNoticeInfoProvider = Provider.of<ChatRoomNoticeInfoProvider>(context, listen: false);
        userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
        if(isUpdate) textEditingController.text = notice.contents;

        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                brightness: Brightness.light,
                title: Column(
                        children: <Widget>[
                            Text(
                                isUpdate ? "공지사항 수정" : "공지사항 작성",
                                style: TextStyle(
                                    height: 1,
                                    color: Color.fromRGBO(39, 39, 39, 1),
                                    fontSize: ScreenUtil().setSp(16),
                                    fontFamily: "NotoSans"
                                ),
                            ),
                            Text(
                                chatInfo.title,
                                style: TextStyle(
                                    height: 1.5,
                                    color: Color.fromRGBO(107, 107, 107, 1),
                                    fontSize: ScreenUtil().setSp(11),
                                    fontFamily: "NotoSans",
                                    fontWeight: FontWeight.w400
                                ),
                            ),
                        ],
                ),
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
                                            '완료',
                                            style: TextStyle(
                                                color: Color.fromRGBO(107, 107, 107, 1),
                                                letterSpacing: ScreenUtil().setWidth(-0.75),
                                                fontSize: ScreenUtil().setSp(15),
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w500
                                            ),
                                        ),
                                        onTap: () {
                                            if (textEditingController.text.length > 0){
                                                if(!isUpdate){
                                                    chatRoomNoticeInfoProvider.writeNotice(textEditingController.text, chatInfo.chatIdx, userInfoProvider);
                                                }
                                            }
                                            Navigator.of(context).pop();
                                        },
                                    )
                                ),
                            ],
                        ),
                    ),
                ],
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color.fromRGBO(250, 250, 250, 1),
            ),
            body: buildNotice(),
        );
    }

    Widget buildNotice() {
        return Container(
            width: ScreenUtil().setWidth(375),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        width: ScreenUtil().setWidth(0.5),
                        color: Color.fromRGBO(178, 178, 178, 0.8)
                    )
                )
            ),
            child:
            Container(
                width: ScreenUtil().setWidth(343),
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(16),
                    right: ScreenUtil().setWidth(16),
                ),
                margin: EdgeInsets.only(
                    top: ScreenUtil().setHeight(20)
                ),
                child: TextField(
                    minLines: 100,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    controller: textEditingController,
                    // 텍스트폼필드에 스타일 적용
                    decoration: InputDecoration(
                        hintText: '단화방에 알리고 싶은 공지를 남겨보세요',
                        hintStyle: TextStyle(
                            fontSize: ScreenUtil().setSp(15),
                            color: Color.fromRGBO(39, 39, 39, 0.4)
                        ),
                        border: InputBorder.none,
                    ),
                ),
            )
        );
    }

}
