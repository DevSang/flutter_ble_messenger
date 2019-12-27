import 'package:Hwa/data/models/chat_count_user.dart';
import 'dart:collection';

class ImageData {
    final String name;
    final String value;
    final String expiration;
    ImageData({this.name, this.value, this.expiration});

    ImageData.fromJson(Map<String, dynamic> json)
        :   name = json['name'],
            value = json['value'],
            expiration = json['expiration'];

    Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'expiration': expiration
    };
}