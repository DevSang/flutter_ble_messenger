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
       if (value.isEmpty) {
        RedToast.toast("이름을 입력하세요.", ToastGravity.TOP);
        if (value.length < 2) {
          RedToast.toast("이름을 한 글자 이상 입력하세요.", ToastGravity.TOP);
        }
    } else if (!regExp.hasMatch(value)) {
        RedToast.toast("사용할 수 있는 닉네임입니다.", ToastGravity.TOP);
    }
    return null;
  }
}