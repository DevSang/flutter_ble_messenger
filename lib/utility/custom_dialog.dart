import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDialog extends StatelessWidget {
    final String title, leftButtonText, rightButtonText, hintText, value;
    final int type, maxLength;
    final Image image;
    final Function func;
    final Widget bodyWidget;
    TextEditingController _textEditingController = TextEditingController();

    CustomDialog({
        @required this.title,
        @required this.leftButtonText,
        @required this.rightButtonText,
        @required this.type,
        this.hintText,
        this.value,
        this.func,
        this.image,
        this.maxLength,
        this.bodyWidget
    });

    @override
    Widget build(BuildContext context) {
        _textEditingController.text = value ?? "";

        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    ScreenUtil().setWidth(10)
                ),
            ),
            elevation: 10,
            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
            child: dialogContent(context),
        );
    }

    dialogContent(BuildContext context) {
        return Stack(
            children: <Widget>[
                Container(
                    width: ScreenUtil().setWidth(281),
                    child: Column(
                        mainAxisSize: MainAxisSize.min, // To make the card compact
                        children: <Widget>[
                            Container(
                                height: ScreenUtil().setHeight(23.5),
                                margin: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(24),
                                    bottom: ScreenUtil().setHeight(20),
                                ),
                                child: Text(
                                    title,
                                    style: TextStyle(
                                        height: 1,
                                        fontFamily: "NotoSans",
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromRGBO(39, 39, 39, 1),
                                        fontSize: ScreenUtil().setSp(16),
                                        letterSpacing: ScreenUtil().setWidth(-0.8)
                                    )
                                ),
                            ),
                            type == 1 ? inputDialogContent() : bodyWidget,
                            Container(
                                    width: ScreenUtil().setWidth(281),
                                    height: ScreenUtil().setHeight(68.5),
                                    margin: EdgeInsets.only(
                                        top: ScreenUtil().setHeight(24)
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(
                                                color: Color.fromRGBO(39, 39, 39, 0.15),
                                                width: ScreenUtil().setHeight(1)
                                            )
                                        ),
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                            InkWell(
                                                child: Container(
                                                    width: ScreenUtil().setWidth(125),
                                                    height: ScreenUtil().setHeight(36),
                                                    margin: EdgeInsets.only(
                                                        right: ScreenUtil().setWidth(5),
                                                    ),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(
                                                            Radius.circular(ScreenUtil().setWidth(10))
                                                        ),
                                                        color: Color.fromRGBO(235, 235, 235, 1)
                                                    ),
                                                    child: Center (
                                                        child: Text(
                                                            leftButtonText,
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                fontFamily: "NotoSans",
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: ScreenUtil().setSp(13),
                                                                color: Color.fromRGBO(107, 107, 107, 1),
                                                                letterSpacing: ScreenUtil().setWidth(-0.32),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                                onTap: () {
                                                    Navigator.of(context).pop(); // To close the dialog
                                                },
                                            ),
                                            InkWell(
                                                child:
                                                Container(
                                                    width: ScreenUtil().setWidth(125),
                                                    height: ScreenUtil().setHeight(36),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(
                                                            Radius.circular(ScreenUtil().setWidth(10))
                                                        ),
                                                        color: Color.fromRGBO(76, 96, 191, 1)
                                                    ),
                                                    child: Center (
                                                        child: Text(
                                                            rightButtonText,
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                fontFamily: "NotoSans",
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: ScreenUtil().setSp(13),
                                                                color: Color.fromRGBO(255, 255, 255, 1),
                                                                letterSpacing: ScreenUtil().setWidth(-0.32),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                                onTap: () {
                                                    func != null ? func() : Navigator.pop(context, _textEditingController.text);
                                                },
                                            ),
                                        ],
                                    ),
                                ),
                        ],
                    ),
                ),
            ],
        );
    }

    Widget inputDialogContent() {
        return Container(
            width: ScreenUtil().setWidth(255),
            height: ScreenUtil().setHeight(38.5),
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(11),
            ),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Color.fromRGBO(235, 235, 235, 1),
                    width: ScreenUtil().setWidth(1)
                ),
                borderRadius: BorderRadius.all(
                    Radius.circular(ScreenUtil().setWidth(10))
                )
            ),
            child: Row(
                children: <Widget>[
                    Container(
                        width: ScreenUtil().setWidth(211),
                        height: ScreenUtil().setHeight(38.5),
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setHeight(15),
                            right: ScreenUtil().setWidth(9)
                        ),
                        child: new TextField(
                            controller: _textEditingController,
                            style: TextStyle(
                                fontFamily: "NotoSans",
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(107, 107, 107, 1),
                                fontSize: ScreenUtil().setSp(15),
                                letterSpacing: ScreenUtil().setWidth(-0.38),
                            ),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: hintText ?? "",
                                hintStyle: TextStyle(
                                    fontFamily: "NotoSans",
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(39, 39, 39, 0.4),
                                    fontSize: ScreenUtil().setSp(15),
                                    letterSpacing: ScreenUtil().setWidth(-0.38),
                                )
                            ),
                            autofocus: false,
                            onChanged: (String chat){},
                            inputFormatters:[
                                LengthLimitingTextInputFormatter(maxLength ?? 18),
                            ]
                        ),
                    ),
                    // Button send message
                    InkWell(
                        child: Container(
                            width: ScreenUtil().setHeight(15),
                            height: ScreenUtil().setHeight(15),
                            margin: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(11.5),
                                top: ScreenUtil().setHeight(12)
                            ),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:AssetImage('assets/images/icon/iconDeleteSmall.png'),
                                    fit: BoxFit.cover
                                ),
                                shape: BoxShape.circle
                            ),
                        ),
                        onTap: () {
                            _textEditingController.clear();
                        },
                    )
                    ,
                ],
            )
        );
    }
}
