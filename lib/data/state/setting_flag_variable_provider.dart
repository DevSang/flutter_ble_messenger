import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/data/models/friend_info.dart';


/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2020-01-15
 * @description : 각종 setting, flag, global 변수 provider
 */

class SettingFlagVariableProvider with ChangeNotifier{
    bool isSetLocate;
    String currentAddress;

    SettingFlagVariableProvider({
        this.isSetLocate
        ,this.currentAddress
    });

    setSettingFlagVariable(dynamic value) {
        notifyListeners();
    }

    /*
     * @author : sh
     * @date : 2020-01-15
     * @description : location 정보 셋팅 flag 변경
     */
    void setLocationFlag() {
        this.isSetLocate = !this.isSetLocate ;
        notifyListeners();
    }
}
