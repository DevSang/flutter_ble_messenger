import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoticePage extends StatefulWidget {
    final int chatIdx;
    NoticePage({Key key, @required this.chatIdx}) :super(key: key);

    @override
    State createState() => new NoticePageState();
}

class NoticePageState extends State<NoticePage> {

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
                    Builder(
                        builder: (context) => IconButton(
                            icon: new Image.asset('assets/images/icon/navIconMenu.png'),
                            onPressed: () {
                                // TODO: Write Notice
                            },
                        ),
                    ),
                ],
                centerTitle: true,
                elevation: 6.0,
                backgroundColor: Colors.white,
            ),
            body: noticeHeader(),
        );
    }

    Widget noticeHeader() {
        return new Container(
            height: ScreenUtil().setHeight(160),
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(40),
                bottom: ScreenUtil().setHeight(40),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    headerTab(1),
                    headerTab(2),
                    Container()
                ],
            )
        );
    }

    Widget headerTab(int index) {
        Color tabColor = index == 1 ? Color.fromRGBO(77, 96, 191, 1) : Colors.black26;

        return new Container(
            width: ScreenUtil().setWidth(150),
            height: ScreenUtil().setHeight(80),
            margin: EdgeInsets.only(
                left: index == 2 ? ScreenUtil().setWidth(20) : 0,
            ),
            decoration: BoxDecoration(
                border: Border.all(
                    width: ScreenUtil().setWidth(1),
                    color: tabColor,
                ),
                borderRadius: BorderRadius.all(
                    Radius.circular(ScreenUtil().setWidth(40))
                )
            ),
            child: Center (
                child: Text(
                    index == 1 ? '공지' : '투표',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: tabColor
                    ),
                ),
            ),
        );
    }

}
