import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:Hwa/data/models/chat_list_item.dart';
import 'package:Hwa/pages/parts/set_chat_list_data.dart';

class TrendPage extends StatefulWidget {
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  bool showSearch;

  @override
  void initState() {
    super.initState();
    showSearch = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Text(
              "실시간 단화 트랜드",
              style: TextStyle(
                  fontFamily: "NotoSans",
                  color: Color.fromRGBO(39, 39, 39, 1),
                  fontSize: ScreenUtil.getInstance().setSp(16)),
            ),
            brightness: Brightness.light,
            leading: IconButton(
              icon: Image.asset("assets/images/icon/navIconPrev.png"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            actions: <Widget>[
              IconButton(
                icon: Image.asset('assets/images/icon/navIconSearch.png'),
                padding: EdgeInsets.only(right: 16),
                onPressed: null,
              )
            ]),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding:
                  EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 50,
                      bottom: 10
                  ),
              child: Column(
                children: <Widget>[
                    // 검색 영역
                    _searchTrend(),

                    // 상단 탭 영역
                    trendHeader(),
                ],
              ),
            )
          ],
        ));
  }

  Widget _searchTrend() {
    return Container(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.grey[200]
        ),
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
            ),
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
            hintText: "단화방 검색",
          ),
        ),
      ),
    );
  }

  Widget trendHeader() {
    return new Container(
        height: ScreenUtil().setHeight(80),
        padding: EdgeInsets.only(
          top: ScreenUtil().setHeight(17),
          bottom: ScreenUtil().setHeight(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[headerTab(1), headerTab(2), Container()],
        ));
  }

  Widget headerTab(int index) {
    Color tabColor = index == 1
        ? Color.fromRGBO(77, 96, 191, 1)
        : Color.fromRGBO(158, 158, 158, 1);
    Color textColor = index == 1
        ? Color.fromRGBO(77, 96, 191, 1)
        : Color.fromRGBO(107, 107, 107, 1);
    double width = index == 1
        ? 74
        : 87;

    return new Container(
      width: ScreenUtil().setWidth(width),
      height: ScreenUtil().setHeight(36),
      margin: EdgeInsets.only(
        left: index == 2 ? ScreenUtil().setWidth(20) : 0,
      ),
      decoration: BoxDecoration(
          border: Border.all(
            width: ScreenUtil().setWidth(1),
            color: tabColor,
          ),
          borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20)))),
      child: Center(
        child: Text(
          index == 1 ? '전체' : '내 주변',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: "NotoSans",
              fontWeight: FontWeight.w500,
              fontSize: ScreenUtil().setSp(14),
              color: textColor
          ),
        ),
      ),
    );
  }

  Widget topChat() {

  }
}
