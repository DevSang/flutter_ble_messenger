
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:core';

/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-28
 * @description : * 하단 빨간 토스트 띄우기
 */

class RedToast{
    static toast(String message,ToastGravity direction) {
        return Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_LONG,
            gravity: direction,
            timeInSecForIos: 2,
            textColor: Colors.white
        );
    }
}
