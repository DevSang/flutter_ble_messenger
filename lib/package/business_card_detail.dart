import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-26
 * @description : 명함 상세보기
 */
class BusinessCardDetail extends StatelessWidget {
    final String userNick;
    final String url;

    BusinessCardDetail({Key key, @required this.userNick, this.url}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return CardDetailScreen(userNick: userNick, url: url);
    }
}

class CardDetailScreen extends StatefulWidget {
    final String userNick;
    final String url;

    CardDetailScreen({Key key, @required this.userNick, this.url}) : super(key: key);

    @override
    State createState() => new CardDetailScreenState(userNick: userNick, url: url);
}

class CardDetailScreenState extends State<CardDetailScreen> {
    final String userNick;
    final String url;

    CardDetailScreenState({Key key, @required this.userNick, this.url});

    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Dismissible(
            direction: DismissDirection.vertical,
            key: Key('key'),
            onDismissed: (direction) {
                Navigator.of(context).pop();
            },
            child: new Scaffold(
                appBar: new AppBar(
                    iconTheme: IconThemeData(
                        color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                    ),
                    title: Text(
                        userNick + "님의 명함",
                        style: TextStyle(
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil.getInstance().setSp(16),
                            letterSpacing: ScreenUtil().setWidth(-0.8)
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
                            builder: (context) => IconButton(
                                icon: new Image.asset('assets/images/icon/navIconDown.png'),
                                onPressed: () => {
                                    /// 명함 다운로드
                                    print("명함")
                                },
                            ),
                        ),
                    ],
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                ),
                backgroundColor: Colors.transparent,
                body: Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(210, 217, 250, 1),
                        border: Border(
                            top: BorderSide(
                                width: ScreenUtil().setWidth(0.5),
                                color: Color.fromRGBO(178, 178, 178, 0.8)
                            )
                        )
                    ),
                    child: PhotoView(
                        backgroundDecoration: BoxDecoration(
                            color: Colors.white
                        )
                        ,imageProvider: AssetImage(url)
                    )

                    /// 추후 서버에 이미지 등록시 교체
//              child: PhotoView(imageProvider: NetworkImage(url))
                )
            )

        );
    }

}














