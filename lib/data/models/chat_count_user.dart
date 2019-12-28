class ChatCountUser {
    final int chatIdx;
    final int bleJoin;
    final int bleOut;
    final int online;
    final int total;
    ChatCountUser({this.chatIdx, this.bleJoin,this.bleOut,this.online,this.total});

    factory ChatCountUser.fromJSON (Map json) {
        return ChatCountUser (
            chatIdx : json['roomIdx'],
            bleJoin : json['bleJoin'],
            bleOut : json['bleOut'],
            online : json['online'],
            total : json['totalCount']
        );
    }
}