
import 'dart:js';

/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-24
 * @description : To use Javascript eval
 */

class Eval {
  static JsObject eval(String json)
  {
    return context.callMethod('eval',['(${json})']);
  }
}
