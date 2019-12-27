import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:Hwa/pages/parts/tab_app_bar.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class User {

  final String name;
  final String company;
  final bool favourite;

  User(this.name, this.company, this.favourite);
}

class FriendTab extends StatefulWidget {
  @override
  _FriendTabState createState() => _FriendTabState();
}

class _FriendTabState extends State<FriendTab> {
  List<User> userList = [];
  List<String> strList = [];
  List<Widget> favouriteList = [];
  List<Widget> normalList = [];
  TextEditingController searchController = TextEditingController();
  double sameSize;

  @override
  void initState() {
    sameSize  = GetSameSize().main();

    for (var i = 0; i < 100; i++) {
      var name = faker.person.name();
      userList.add(User(name, faker.company.name(), false));
    }

    for (var i = 0; i < 4; i++) {
      var name = faker.person.name();
      userList.add(User(name, faker.company.name(), true));
    }

    userList
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    filterList();
    searchController.addListener(() {
      filterList();
    });

    super.initState();
  }

  filterList() {
    List<User> users = [];
    users.addAll(userList);
    favouriteList = [];
    normalList = [];
    strList = [];
    if (searchController.text.isNotEmpty) {
      users.retainWhere((user) =>
          user.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()));
    }
    users.forEach((user) {
      if (user.favourite) {
        favouriteList.add(
          Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(
                iconWidget: Icon(Icons.star),
                onTap: () {},
              ),
              IconSlideAction(
                iconWidget: Icon(Icons.more_horiz),
                onTap: () {},
              ),
            ],
            child: ListTile(
              leading: Stack(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage:
                    NetworkImage("http://placeimg.com/200/200/people"),
                  ),
                  Container(
                      height: sameSize*40,
                      width: sameSize*40,
                      child: Center(
                        child: Icon(
                          Icons.star,
                          color: Colors.yellow[100],
                        ),
                      ))
                ],
              ),
              title: Text(user.name),
              subtitle: Text(user.company),
            ),
          ),
        );
      } else {
        normalList.add(
          Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(
                iconWidget: Icon(Icons.star),
                onTap: () {},
              ),
              IconSlideAction(
                iconWidget: Icon(Icons.more_horiz),
                onTap: () {},
              ),
            ],
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                NetworkImage("http://placeimg.com/200/200/people"),
              ),
              title: Text(user.name),
              subtitle: Text(user.company),
            ),
          ),
        );
        strList.add(user.name);
      }
    });

    setState(() {
      strList;
      favouriteList;
      normalList;
      strList;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentStr = "";
    return MaterialApp(
        home: Scaffold(
        appBar: TabAppBar(
          title: '단화 친구',
          leftChild: Container(
            margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(8)
            ),
            child: Row(
              children: <Widget>[
                Text(
                  50.toString(),
                  style: TextStyle(
                    height: 1,
                    fontFamily: "NanumSquare",
                    fontWeight: FontWeight.w500,
                    fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                    color: Color.fromRGBO(107, 107, 107, 1),
                    letterSpacing: ScreenUtil().setWidth(-0.33),
                  ),
                ),
                Text(
                  "명",
                  style: TextStyle(
                    height: 1,
                    fontFamily: "NotoSans",
                    fontWeight: FontWeight.w500,
                    fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                    color: Color.fromRGBO(107, 107, 107, 1),
                    letterSpacing: ScreenUtil().setWidth(-0.33),
                  ),
                ),
              ],
            )
          ),
        ),
          body: AlphabetListScrollView(
            strList: strList,
            highlightTextStyle: TextStyle(
              color: Colors.yellow,
            ),
            showPreview: true,
            itemBuilder: (context, index) {
              return normalList[index];
            },
            indexedHeight: (i) {
              return 80;
            },
            keyboardUsage: true,
            headerWidgetList: <AlphabetScrollListHeader>[



              AlphabetScrollListHeader(widgetList: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffix: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      labelText: "Search",
                    ),
                  ),
                )
              ], icon: Icon(Icons.search), indexedHeaderHeight: (index) => 80),
              AlphabetScrollListHeader(
                  widgetList: favouriteList,
                  icon: Icon(Icons.star),
                  indexedHeaderHeight: (index) {
                    return 80;
                  }),
            ],
          ),
        ));
  }
}