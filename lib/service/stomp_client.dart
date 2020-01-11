import 'dart:collection';
import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Hwa/constant.dart';


/*
 * @project : HWA - Mobile
 * @author : hk
 * @date : 2019-12-20
 * @description : WebSocket STOMP 연결 지원 - stomp_client 플러그인 수정
 *                TODO 테스트 진행하며 코드 수정, Future 적용할 부분 있는지 검토
 */
class StompClient {
	IOWebSocketChannel channel;
	HashMap<String, int> _topics;
	HashMap<String, StreamController<HashMap>> _streams;
	int _topicsCount;
	StreamController<String> general;

	SharedPreferences prefs;

	static const String NEWLINE = "\n";
	static const String END_CHAR = "\n\x00";

	String urlBackend;
	var onError;
	var onDone;

	/*
	* @author : hk
	* @date : 2019-12-20
	* @description : Constructor
	*/
	StompClient(String urlBackend, Function onError, {onDone}) {
		this.urlBackend = urlBackend;
		this.onError = onError;
		this.onDone = onDone;

		general = StreamController();
		_topics = HashMap();
		_streams = HashMap();
		_topicsCount = 0;
	}

	/*
	* @author : hs
	* @date : 2019-12-28
	* @description : WebSocket 연결
	*/
	Future<void> connectWebSocket() async {
		channel = IOWebSocketChannel.connect(urlBackend, pingInterval: Duration(seconds: 30), headers: Constant.HEADER);

		channel.stream.listen((message) {
		    _messageReceived(message);
		}, onError: onError, onDone: onDone);

		return;
	}

	/*
	* @author : hk
	* @date : 2019-12-20
	* @description : Stomp 접속 및 jwt 인증
	*/
	void connectStomp() {
		channel.sink.add("CONNECT" + NEWLINE +
//          "Authorization:Bearer " + token + NEWLINE +
		    "accept-version:1.1,1.0" + NEWLINE +
		    "heart-beat:30000,0" + NEWLINE +
		    END_CHAR);
	}

	/*
	 * @author : hk
	 * @date : 2019-12-20
	 * @description : WebSocket 접속 끊기
	 */
	void disconnect() {
		channel.sink.add("DISCONNECT" + NEWLINE + END_CHAR);
		channel.sink.close();
	}

	/*
	* @author : hk
	* @date : 2019-12-20
	* @description : topic(채팅방 등) 구독
	*/
	StreamController<HashMap> subscribe({@required String topic, @required String roomIdx, @required String userIdx}) {
		if (!_topics.containsKey(topic)) {
			_topics[topic] = _topicsCount;
			_streams[topic] = new StreamController<HashMap>();

			channel.sink.add("SUBSCRIBE" + NEWLINE +
				"id:" + _topicsCount.toString() + NEWLINE +
				"destination:" + topic + NEWLINE +
				"roomIdx:" + roomIdx + NEWLINE +
				"userIdx:" + userIdx + NEWLINE +
				END_CHAR);

			_topicsCount++;
			return _streams[topic];
		}

		return null;
	}

	/*
	* @author : hk
	* @date : 2019-12-20
	* @description : topic 구독 취소
	*/
	void unsubscribe({@required String topic}) {
		if (_topics.containsKey(topic)) {
			channel.sink.add("UNSUBSCRIBE" + NEWLINE +
				"id:" + _topics[topic].toString() + NEWLINE +
				END_CHAR);
			_topics.remove(topic);
			_streams.remove(topic);
		}
	}

	/*
	* @author : hk
	* @date : 2019-12-20
	* @description : 메시지 전송
	*/
	void send({@required String topic, String message}) {
		channel.sink.add("SEND" + NEWLINE +
			"destination:" + topic + NEWLINE +
			"content-type:application/json" + NEWLINE +
			NEWLINE + message + NEWLINE +
			END_CHAR);
	}

	/*
	* @author : hk
	* @date : 2019-12-20
	* @description : 메시지 수신 후 처리
	*/
	void _messageReceived(String message) {
		if (message.split(NEWLINE)[0] == "MESSAGE") {
			HashMap messageHashMap = _messageToHashMap(message);
			_streams[messageHashMap["destination"]].add(messageHashMap);
		} else {
			general.add(message);
		}
	}

	/*
	* @author : hk
	* @date : 2019-12-20
	* @description : WebSocket Msg => Map
	*/
	HashMap _messageToHashMap(String message) {
		HashMap<String, String> data = HashMap();

		var dataSplitted = message.replaceAll(new RegExp(r'\x00'), "").split("\n");
		data["type"] = dataSplitted[0];
		dataSplitted.removeAt(0);

		while (dataSplitted[0] != "") {
			var lineSplitted = dataSplitted[0].split(":");
			data[lineSplitted[0]] = lineSplitted[1];
			dataSplitted.removeAt(0);
		}

		dataSplitted.removeAt(0);
		data["contents"] = "";

		while (dataSplitted.length > 0 && dataSplitted[0] != "") {
			data["contents"] += dataSplitted[0] + NEWLINE;
			dataSplitted.removeAt(0);
		}

		return data;
	}
}
