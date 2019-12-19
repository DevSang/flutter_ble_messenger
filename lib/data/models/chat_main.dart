//class ChatMain {
//  final String chatName;
//  final String chatImage;
//  final String chatJoinNum;
//  final String chatStatus;
//  final String chatPopular;
//
//  ChatMain({this.chatName,this.chatImage,this.chatJoinNum,this.chatStatus, this.chatPopular});
//  }


class Note {
  String title;
  String text;

  Note(this.title, this.text);

  Note.fromJson(Map<String, dynamic> json){
    title = json['title'];
    text = json['text'];

  }
}
