import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/data/models/image_data.dart';

/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-24
 * @description : * About cache image function
 *                1. Convert image to base64, base64 to image
 *                2. Save and load image from shared preference
 *                image type - business card image(BCI)
 *                           - my profile image(MPI)
 *                           - common receive image
 */

enum Image_type {
  profile_img,
  common_send_img,
  common_receive_img,
  my_business_card_img,
  business_card_img,
  chat_room_profile_img,
  test_img
}

enum Expire_time {
  one_day,
  one_week,
  one_month,
  two_month,
  three_month,
  six_month
}

class CachedImageUtility{
  static final today = new DateTime.now();

  /*
   * @author : sh
   * @date : 2019-12-26
   * @description : shared preference에서 image를 가져와 decode하여 반환, 만료되었으면 삭제
   */
  static Future<Image> loadImageFromPreferences({@required Image_type imageType, String fileName}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var prefsKey = imageType.toString() + '_' + fileName;
    var imgData = await getImageFromPreferences(prefsKey);
    var jsonImgData = json.decode(imgData);

    DateTime expireDate = DateTime.parse(jsonImgData['expiration']);

    //만료 되면
    if(expireDate.isBefore(today)){
      prefs.remove(prefsKey);
      return null;
    } else {
      return imageFromBase64String(jsonImgData['value']);
    }
  }

  /*
   * @author : sh
   * @date : 2019-12-26
   * @description : FileName, value(base64image), expiretime 설정하여 string으로 변환후 shared preference에 저장
   */
  static Future<bool> saveImageToPreferences({@required Image_type imageType, @required File imageFile, @required String fileName, Expire_time expireSec }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<int> imageBytes = imageFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    var setTime = setExpireTime(imageType, expireSec);

    ImageData imgData = ImageData(
      name: fileName,
      value: base64Image,
      expiration: 'profile' == imageType ? null : today.add(new Duration(seconds: setTime)).toString()
    );

    return prefs.setString(imageType.toString() + '_' + fileName, json.encode(imgData.toJson()));
  }

  /*
   * @author : sh
   * @date : 2019-12-26
   * @description : Expire setting, expireSec null일 경우 default값으로 설정
   */
  static setExpireTime(Image_type imageType, Expire_time expireSec) {
    var oneMonth = 60 * 60 * 24 * 30 * 1;
    var sixMonth = 60 * 60 * 24 * 30 * 6;

    //Default expire time
    if (null == expireSec) {
      if ([
        Image_type.profile_img,
        Image_type.common_send_img,
        Image_type.my_business_card_img,
        Image_type.business_card_img,
        Image_type.chat_room_profile_img
      ].contains(imageType)) {
        return sixMonth;
      } else if(imageType == Image_type.test_img){
        return 10;
      }
      else { //프로필 사진인경우
        return oneMonth;
      }
    //Custom expire time
    } else {
      return expireSec;
    }
  }

  /*
   * @author : sh
   * @date : 2019-12-26
   * @description : Shared preference에서 keyword를 통해 값을 가져옴
   */
  static Future<String> getImageFromPreferences(String prefsKey) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefsKey) ?? null;
  }

  /*
   * @author : sh
   * @date : 2019-12-26
   * @description : base64로 String을 decode하여 image를 반환
   */
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64.decode(base64String),
      width: ScreenUtil().setWidth(500),
      height: ScreenUtil().setHeight(500)
    );
  }

  /*
   * @author : sh
   * @date : 2019-12-26
   * @description : Byte array를 base64로 encode
   */
  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static pickImageFromGallery() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  static pickImageFromCamera() async {
    return await ImagePicker.pickImage(source: ImageSource.camera);
  }

}
