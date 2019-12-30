import 'package:Hwa/constant.dart';
import 'package:Hwa/data/models/friend_info.dart';
import 'package:Hwa/pages/parts/tab_app_bar.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-30
 * @description : HWA 친구 Tab 화면 
 */
class User {
    final String name;
    final String company;
    final bool favorite;

    User(this.name, this.company, this.favorite);
}

class FriendTab extends StatefulWidget {
    @override
    _FriendTabState createState() => _FriendTabState();
}

class _FriendTabState extends State<FriendTab> {
//    List<FriendInfo> friendList = Constant.FRIEND_LIST ?? <FriendInfo>[];
    List<String> strList = [];
    List<Widget> normalList = [];
//    List<Widget> favouriteList = [];
    TextEditingController searchController = TextEditingController();
    double sameSize;



    ScrollController _scrollController;
    List<User> userList = [];
    List<Widget> favouriteList = [];


    @override
    void initState() {
        _scrollController = new ScrollController()..addListener(_sc);





        sameSize = GetSameSize().main();

            for (var i = 0; i < 10; i++) {
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



//            friendList.sort((a, b) => a.nickname.compareTo(b.nickname));

        //TODO: 추후 적용
        filterList();
        searchController.addListener(() {
            filterList();
        });

        super.initState();
    }

    @override
    void dispose() {


        _scrollController.removeListener(_sc);


        super.dispose();
    }



    void _sc() {
        print(_scrollController.position.extentAfter);
        if (_scrollController.position.extentAfter < 500) {
            setState(() {
                new List.generate(42, (index) => 'Inserted $index');
            });
        }
    }




    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : 친구 리스트
    */
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
            if (user.favorite) {
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




//        List<FriendInfo> constList = [];
//        constList.addAll(friendList);

//        normalList = [];
//        strList = [];
//        if (searchController.text.isNotEmpty) {
//            constList.retainWhere((user) =>
//                user.nickname.toLowerCase().contains(
//                    searchController.text.toLowerCase()));
//        }
//        constList.forEach((user) {
//            normalList.add(
//                Slidable(
//                    actionPane: SlidableDrawerActionPane(),
//                    actionExtentRatio: 0.25,
//                    secondaryActions: <Widget>[
//                        IconSlideAction(
//                            iconWidget: Icon(Icons.star),
//                            onTap: () {},
//                        ),
//                        IconSlideAction(
//                            iconWidget: Icon(Icons.more_horiz),
//                            onTap: () {},
//                        ),
//                    ],
//                    child: ListTile(
//                        leading: CircleAvatar(
//                            backgroundImage:
//                            NetworkImage("http://placeimg.com/200/200/people"),
//                        ),
//                        title: Text(user.nickname),
//                    ),
//                ),
//            );
//            strList.add(user.nickname);
//        });

//        setState(() {
//            strList;
//            normalList;
//        });
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
                appBar: TabAppBar(
                    title: '단화 친구',
                    leftChild: Container(
                        margin: EdgeInsets.only(
                            left: 8
                        ),
                        child: Row(
                            children: <Widget>[
                                Text(
//                                    friendList.length.toString(),
                                5.toString(),
                                    style: TextStyle(
                                        height: 1,
                                        fontFamily: "NanumSquare",
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScreenUtil(
                                            allowFontScaling: true).setSp(13),
                                        color: Color.fromRGBO(107, 107, 107, 1),
                                        letterSpacing: ScreenUtil().setWidth(
                                            -0.33),
                                    ),
                                ),
                                Text(
                                    "명",
                                    style: TextStyle(
                                        height: 1,
                                        fontFamily: "NotoSans",
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScreenUtil(
                                            allowFontScaling: true).setSp(13),
                                        color: Color.fromRGBO(107, 107, 107, 1),
                                        letterSpacing: ScreenUtil().setWidth(
                                            -0.33),
                                    ),
                                ),
                            ],
                        )
                    ),
                ),
//                body: AlphabetListScrollView(
//                    strList: strList,
//                    highlightTextStyle: TextStyle(
//                        color: Colors.yellow,
//                    ),
//                    showPreview: false,
//                    itemBuilder: (context, index) {
//                        return normalList[index];
//                    },
//                    indexedHeight: (i) {
//                        return 62;
//                    },
//                    keyboardUsage: true,
//                    headerWidgetList: <AlphabetScrollListHeader>[
//                        AlphabetScrollListHeader(
//                            widgetList: [
//                                Padding(
//                                    padding: const EdgeInsets.all(16.0),
//                                    child: TextFormField(
//                                        controller: searchController,
//                                        decoration: InputDecoration(
//                                            border: OutlineInputBorder(),
//                                            suffix: Icon(
//                                                Icons.search,
//                                                color: Colors.grey,
//                                            ),
//                                            labelText: "Search",
//                                        ),
//                                    ),
//                                )
//                            ],
//                            icon: Icon(Icons.search),
//                            indexedHeaderHeight: (index) => 80
//                        ),
//                        //                  AlphabetScrollListHeader(
//                        //                      widgetList: favoriteList,
//                        //                      icon: Icon(Icons.star),
//                        //                      indexedHeaderHeight: (index) {
//                        //                          return 80;
//                        //                      }
//                        //                      ),
//                    ],
//                ),


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



                    AlphabetScrollListHeader(
                        widgetList: [
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(16.0),
                                    vertical: ScreenUtil().setHeight(6),
                                ),
                                child: TextField(
                                    controller: searchController,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontFamily: "NotoSans",
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScreenUtil().setSp(15),
                                        letterSpacing: ScreenUtil().setWidth(-0.75),
                                        color: Color.fromRGBO(39, 39, 39, 1),
                                    ),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        fillColor: Color.fromRGBO(0, 0, 0, 0.06),
                                        contentPadding: EdgeInsets.fromLTRB(
                                            ScreenUtil().setWidth(13),
                                            ScreenUtil().setHeight(5.9),
                                            ScreenUtil().setWidth(13),
                                            ScreenUtil().setHeight(7.6)
                                        ),
                                        prefixIcon: Icon(
                                            Icons.search,
                                            color: Color.fromRGBO(39, 39, 39, 0.5),
                                        ),
                                        hintText: "검색",
                                        hintStyle: TextStyle(
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScreenUtil().setSp(15),
                                            letterSpacing: ScreenUtil().setWidth(-0.75),
                                            color: Color.fromRGBO(39, 39, 39, 0.4),
                                        ),
                                    ),
                                ),
                            )
                        ],
                        icon: Icon(Icons.search), indexedHeaderHeight: (index) => ScreenUtil().setWidth(46),
                    ),
                    AlphabetScrollListHeader(
                        widgetList: favouriteList,
                        icon: Icon(Icons.star),
                        indexedHeaderHeight: (index) {
                            return 80;
                        }),
                    ],
                ),
            )
        );
    }
}