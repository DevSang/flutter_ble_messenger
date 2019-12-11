import 'package:flutter/material.dart';
import 'package:Hwa/api_config.dart';

class Injector extends InheritedWidget {
  final ApiConfig apiConfig = new ApiConfig();

  Injector({
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  static Injector of(BuildContext context) => context.inheritFromWidgetOfExactType(Injector);

  @override
  bool updateShouldNotify(Injector oldWidget) => false;

  ApiConfig getApiSetting() {
    return apiConfig;
  }
}
