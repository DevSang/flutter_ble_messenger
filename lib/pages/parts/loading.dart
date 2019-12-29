import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Loading extends StatelessWidget {
    Widget build(BuildContext context) {

        return Positioned(
            top: ScreenUtil().setHeight(0),
            right: ScreenUtil().setWidth(0),
            child: Container(
                width: ScreenUtil().setWidth(375),
                height: ScreenUtil().setHeight(530),
                color: Color.fromRGBO(255, 255, 255, 0.2),
                child: Align(
                    child:
                    new Container(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.4),
                            borderRadius: BorderRadius.circular(
                                ScreenUtil().setWidth(10)
                            )
                        ),
                        width: ScreenUtil().setWidth(60.0),
                        height: ScreenUtil().setWidth(60.0),
                        child: new Center(
                            child: SizedBox(
                                child: CircularProgressIndicator(
                                    valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(77, 96, 191, 1)),
                                ),
                                width: ScreenUtil().setWidth(20.0),
                                height: ScreenUtil().setWidth(20.0),
                            ),
                        )
                    ),
                    alignment: Alignment.center,
                )
            )
        );
    }
}