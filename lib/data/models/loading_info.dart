import 'package:flutter/cupertino.dart';

/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2020-01-06
 * @description : Loading
 */
class LoadingInfo with ChangeNotifier {
    bool _isLoading = false;

    bool getLoadingState() => _isLoading;

    void setLoadingState(bool state) {
        _isLoading = state;
        notifyListeners();
    }
}