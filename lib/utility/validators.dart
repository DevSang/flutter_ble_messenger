import 'package:Hwa/utility/red_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Validator{
  String validateUserName(String userName) {
    if (userName.length >= 7) {

      RedToast.toast("사용 가능한 이름입니다", ToastGravity.TOP);
    }
    else{
      RedToast.toast("사용 불가능한 이름입니다", ToastGravity.TOP);

    }
    }
  }

