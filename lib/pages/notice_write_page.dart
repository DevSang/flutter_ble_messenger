import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/data/models/chat_notice_item.dart';
import 'package:Hwa/pages/parts/set_chat_notice_data.dart';
import 'package:intl/intl.dart';

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-23
 * @description : 공지사항 리스트
 */
class NoticeWritePage extends StatefulWidget {
    final int chatIdx;
    NoticeWritePage({Key key, @required this.chatIdx}) :super(key: key);

    @override
    State createState() => new NoticeWritePageState();
}

class NoticeWritePageState extends State<NoticeWritePage> {
    List<ChatNoticeItem> chatNoticeList = new SetChatNoticeData().main();
    TextEditingController textEditingController;

    @override
    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 375, height: 667, allowFontScaling: true)..init(context);

        return new Scaffold(
            appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                brightness: Brightness.light,
                title: Column(
                        children: <Widget>[
                            Text(
                                "공지 작성",
                                style: TextStyle(
                                    height: 1,
                                    color: Color.fromRGBO(39, 39, 39, 1),
                                    fontSize: ScreenUtil.getInstance().setSp(16),
                                    fontFamily: "NotoSans"
                                ),
                            ),
                            Text(
                                "코엑스 별마당 도서관",
                                style: TextStyle(
                                    height: 1.5,
                                    color: Color.fromRGBO(107, 107, 107, 1),
                                    fontSize: ScreenUtil.getInstance().setSp(11),
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
                                                fontSize: ScreenUtil.getInstance().setSp(15),
                                                fontFamily: "NotoSans",
                                                fontWeight: FontWeight.w500
                                            ),
                                        ),
                                        onTap: () {},
                                    )
                                ),
                            ],
                        ),
                    ),
                ],
                centerTitle: true,
                elevation: 6.0,
                backgroundColor: Colors.white,
            ),
            body: buildNotice(),
        );
    }

    Widget buildNotice() {
        return Container(
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
        );
    }

}
