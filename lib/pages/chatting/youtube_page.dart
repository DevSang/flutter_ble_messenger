import 'package:flutter/material.dart';
import 'package:Hwa/data/models/chat_message.dart';


/*
 * @project : HWA - Mobile
 * @author : hk
 * @date : 2020-01-08
 * @description : 유튜브 보기
 */
class YoutubePage extends StatefulWidget {

	final ChatMessage chatMessage;

	YoutubePage({Key key, this.chatMessage}) : super(key: key);

	@override
	State createState() => new YoutubePageState(chatMessage: chatMessage);
}

class YoutubePageState extends State<YoutubePage> {
	ChatMessage chatMessage;

	YoutubePageState({this.chatMessage});

	@override
	Widget build(BuildContext context) {
		return chatMessage.youtubePlayer;
	}
}