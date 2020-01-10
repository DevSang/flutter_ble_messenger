import 'package:Hwa/utility/red_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Validator{
  String validateName(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp =  RegExp(patttern);
    if (value.length == 0) {
      RedToast.toast("입력하세요", ToastGravity.TOP);
      return "이름을 입력하세요";
    } else if (!regExp.hasMatch(value)) {
      RedToast.toast("Name must be a-z and A-Z", ToastGravity.TOP);
      return "Name must be a-z and A-Z";
    }
    return null;
  }
}