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
class NoticeDetailPage extends StatefulWidget {
    final int chatIdx;
    NoticeDetailPage({Key key, @required this.chatIdx}) :super(key: key);

    @override
    State createState() => new NoticeDetailPageState();
}

class NoticeDetailPageState extends State<NoticeDetailPage> {
    List<ChatNoticeItem> chatNoticeList = new SetChatNoticeData().main();

    @override
    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 375, height: 667, allowFontScaling: true)..init(context);

        return new Scaffold(
            appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                brightness: Brightness.light,
                title: Text(
                    "코엑스 별마당 도서관",
                    style: TextStyle(
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil.getInstance().setSp(16)
                    ),
                ),
                leading: new IconButton(
                    icon: new Image.asset('assets/images/icon/navIconClose.png'),
                    onPressed: (){
                        Navigator.of(context).pop();
                    }
                ),
                actions:[
                    Builder(
                        builder: (context) => GestureDetector(
                            child: Text(
                                '글목록',
                                style: TextStyle(
                                    color: Color.fromRGBO(107, 107, 107, 1),
                                    letterSpacing: ScreenUtil().setWidth(-0.75),
                                    fontSize: ScreenUtil.getInstance().setSp(15)
                                ),
                            ),
                            onTap: () {
                                Navigator.of(context).pop();
                            },
                        )
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
        return Container();
    }

}
