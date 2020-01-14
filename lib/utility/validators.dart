import 'package:Hwa/utility/red_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';


/*
 * @project : HWA - Mobile
 * @author : JH
 * @date : 2020-01-13
 * @description : 닉네임 Validator
 */
class Validator {
    // 정규표현식 (한글 완성, 특수문자, 공백)
//    static String pattern = '[\s|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|(\₩;\-=+,_#\/\?:^\$.@*\"※~&%ㆍ!』\\‘|\(\)\[\]\<\>`\'…》)|(ㄱ-ㅎ)]';


    bool validateName(String value) {
        RegExp regExp =  RegExp(r'^[a-zA-Z0-9]+$');
        if (regExp.hasMatch(value)) {
            return true;
        } else {
            return false;
        }
    }
}