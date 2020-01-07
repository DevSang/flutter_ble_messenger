import 'package:flutter/cupertino.dart';

class FriendCount with ChangeNotifier {
	int _count = 0;

	getCounter() => _count;

	setCount(int count) {
		_count = count;
		notifyListeners();
	}
}