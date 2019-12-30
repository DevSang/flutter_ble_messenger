import 'dart:convert';

import 'package:Hwa/data/models/chat_count_user.dart';
import 'package:Hwa/data/models/chat_message.dart';
import 'package:Hwa/data/models/chat_user_info.dart';

class ChatJoinInfo {
    /// 추후 교체
    String joinType;				// User Join Type
    int userIdx;			    // User Idx
//    int userNick;			    // User Nick

    ChatJoinInfo({
        this.joinType
        , this.userIdx
//        , this.userNick
    });


    factory ChatJoinInfo.fromJSON (Map<String, dynamic> jsonData) {
        return ChatJoinInfo (
            joinType : jsonData['join_type'],
            userIdx : jsonData['user_idx'],
//            masterUserIdx : jsonData['masterUserIdx'] ?? jsonData['createUserIdx'],
        );
    }
}