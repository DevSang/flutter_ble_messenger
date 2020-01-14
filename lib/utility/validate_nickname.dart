import 'dart:convert';
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:Hwa/pages/policy/opensource_license.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/utility/validators.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;



/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2020-01-14
 * @description : 닉네임 체크 공통 함수
 */
class ValidateNickname {
    /*
     * @author : hs
     * @date : 2020-01-14
     * @description : 닉네임 모든 요소 체크
    */
    Future<bool> nickAllFactCheck(String nick, String myNick) async {
        if (checkLength(nick)) {
            if (await checkAlreadyUsed(nick, myNick)) {
                // TODO Validator 적용
                if (Validator.validateName(nick)) {
                    return true;
                } else {
                    RedToast.toast("사용할 수 없는 문자가 포함되어 있습니다.", ToastGravity.TOP);
                    return false;
                }
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    /*
     * @author : hs
     * @date : 2020-01-14
     * @description : 닉네임 이미 사용 여부 체크
    */
    Future<bool> checkAlreadyUsed(String nick, String myNick) async {

        if (nick != myNick) {
            final response = await http.get("https://api.hwaya.net/api/v2/auth/A03-Nickname?nickname=$nick");
            String jsonResult = jsonDecode(response.body).toString();

            if(jsonResult.indexOf("사용 가능한 닉네임입니다") > -1){
                developer.log("# Vaild nickname");
                return true;
            } else {
                RedToast.toast("이미 사용중인 닉네임입니다.", ToastGravity.TOP);
                developer.log("# Invalid nickname");
                return false;
            }
        } else {
            return true;
        }
    }

    /*
     * @author : hs
     * @date : 2020-01-14
     * @description : 닉네임 길이 체크
    */
    bool checkLength(String nick)  {
        if (nick.length > 1) {
            return true;
        } else {
            RedToast.toast("닉네임을 한 글자 이상 입력하세요.", ToastGravity.TOP);
            return false;
        }
    }
}