import 'package:flutter/cupertino.dart';

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2020-01-06
 * @description : GPS 정보 공유
 */
class GPSInfo with ChangeNotifier {
    String _currentAddress = '위치 검색 중..';

    String getGPS() => _currentAddress;

    void setGPS(String gpsString) {
        _currentAddress = gpsString;
        notifyListeners();
    }
}