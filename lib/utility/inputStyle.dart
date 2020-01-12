import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputStyle {

    Color getBackgroundColor(FocusNode _focusNode) {
        return _focusNode.hasFocus ? Color.fromRGBO(255, 255, 255, 1) : Color.fromRGBO(245, 245, 245, 1);
    }

    OutlineInputBorder getEnableBorder = OutlineInputBorder(
        borderRadius:  BorderRadius.circular(
            ScreenUtil().setHeight(10.0),
        ),
        borderSide: BorderSide(
            color: Color.fromRGBO(245, 245, 245, 1),
            width: ScreenUtil().setWidth(1)
        ),
    );

    OutlineInputBorder getFocusBorder = OutlineInputBorder(
        borderSide: BorderSide(
            color: Color.fromRGBO(214, 214, 214, 1),
            width: ScreenUtil().setWidth(1)
        ),
        borderRadius: BorderRadius.circular(
            ScreenUtil().setHeight(10.0)
        ),
    );

    OutlineInputBorder getErrorBorder = OutlineInputBorder(
        borderSide: BorderSide(
            color: Color.fromRGBO(244, 67, 54, 1),
            width: ScreenUtil().setWidth(1)
        ),
        borderRadius: BorderRadius.circular(
            ScreenUtil().setHeight(10.0)
        ),
    );

    TextStyle inputHintText = TextStyle(
        color: Color.fromRGBO(39, 39, 39, 0.4),
        fontSize: ScreenUtil().setSp(15),
        fontFamily: 'NotoSans',
        fontWeight: FontWeight.w500,
        letterSpacing: ScreenUtil().setWidth(-0.75),
    );

    TextStyle inputValue = TextStyle(
        color: Color.fromRGBO(39, 39, 39, 1),
        fontSize: ScreenUtil().setSp(15),
        fontFamily: 'NanumSquare',
        fontWeight: FontWeight.w500,
        letterSpacing: ScreenUtil().setWidth(-0.38),
    );
}