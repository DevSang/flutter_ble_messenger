    import 'package:Hwa/utility/red_toast.dart';
    import 'package:fluttertoast/fluttertoast.dart';

/*
 * @project : HWA - Mobile
 * @author : JH
 * @date : 2020-01-13
 * @description : 닉네임 Validator
    */

    class Validator{
        static String pattern = '[\s|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|(\₩;\-=+,_#\/\?:^\$.@*\"※~&%ㆍ!』\\‘|\(\)\[\]\<\>`\'…》)|(ㄱ-ㅎ)]';
    String validateName(String value) {
      RegExp regExp =  RegExp(pattern);
       if (value.length == 0) {
        RedToast.toast("이름을 입력하세요", ToastGravity.TOP);
      return "이름을 입력하세요";
    } else if (!regExp.hasMatch(value)) {
        RedToast.toast("Name must be a-z and A-Z", ToastGravity.TOP);
      return "Name must be a-z and A-Z";
    }
    return null;
  }
}