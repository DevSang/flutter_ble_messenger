import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

const easy_localization = "https://github.com/aissat/easy_localization/blob/master/LICENSE \n \nMIT LICENSE";
const intl = "https://github.com/dart-lang/intl/blob/master/LICENSE \n \nBSD LICENSE ";
const configurable_expansion_tile = "https://github.com/matthewstyler/configurable_expansion_tile/blob/master/LICENSE \n \nBSD LICENSE";
const timeago = "https://github.com/andresaraujo/timeago.dart/blob/master/timeago/LICENSE \n \nMIT LICENSE";
const lazy_load_scrollview = "lhttps://github.com/QuirijnGB/lazy-load-scrollview/blob/master/LICENSE \n \nBSD LICENSE";
const sticky_headers = "https://github.com/fluttercommunity/flutter_sticky_headers/blob/master/LICENSE \n \nMIT LICENSE";
const flutter_screenutil = "https://github.com/OpenFlutter/flutter_screenutil/blob/master/LICENSE \n \nApache 2.0 LICENSE";
const catcher = "https://github.com/jhomlala/catcher/blob/master/LICENSE \n \nApache 2.0 LICENSE";
const json_annotation = "https://github.com/dart-lang/json_serializable/blob/master/LICENSE \n \nBSD LICENSE";
const dio = "https://github.com/flutterchina/dio/blob/master/LICENSE \n \nMIT LICENSE";
const http = "https://github.com/dart-lang/http/blob/master/LICENSE \n \nBSD LICENSE";
const cached_network_image = "https://github.com/renefloor/flutter_cached_network_image/blob/master/LICENSE.md \n \nMIT LICENSE";
const firebase_messaging = "https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_messaging/LICENSE \n \nBSD LICENSE";
const web_socket_channel = "https://github.com/dart-lang/web_socket_channel/blob/master/LICENSE \n \nBSD LICENSE";
const geolocator = "https://github.com/Baseflow/flutter-geolocator/blob/master/LICENSE \n \nMIT LICENSE";
const image_picker = "https://github.com/flutter/plugins/blob/master/packages/image_picker/LICENSE \n \nApache 2.0 LICENSE";
const photo_view = "https://github.com/renancaraujo/photo_view/blob/master/LICENSE \n \nMIT LICENSE";
const shared_preferences = "https://github.com/flutter/plugins/blob/master/packages/shared_preferences/shared_preferences/LICENSE \n \nBSD LICENSE";
const provider = "https://github.com/rrousselGit/provider/blob/master/packages/provider/LICENSE \n \nMIT LICENSE";
const kvsql = "https://github.com/synw/kvsql/blob/master/LICENSE \n \nMIT LICENSE";
const sqlcool = "https://github.com/synw/sqlcool/blob/master/LICENSE \n \nMIT LICENSE";
const flutter_facebook_login = "https://github.com/roughike/flutter_facebook_login/blob/master/LICENSE \n \nBSD LICENSE";
const google_sign_in = "https://github.com/flutter/plugins/blob/master/packages/google_sign_in/google_sign_in/LICENSE \n \nBSD LICENSE";
const flutter_kakao_login = "https://github.com/JosephNK/flutter_kakao_login/blob/master/LICENSE \n \nBSD LICENSE";
const kakao_flutter_sdk = "https://github.com/CoderSpinoza/kakao_flutter_sdk/blob/master/LICENSE \n \nBSD LICENSE";
const alphabet_list_scroll_view = "https://github.com/LiewJunTung/alphabet_list_scroll_view/blob/master/LICENSE \n \nMIT LICENSE";
const flutter_slidable = "https://github.com/letsar/flutter_slidable/blob/master/LICENSE \n \nMIT LICENSE";
const expandable = "https://github.com/aryzhov/flutter-expandable/blob/master/LICENSE \n \nMIT LICENSE";
const fluttertoast = "https://github.com/PonnamKarthik/FlutterToast/blob/master/LICENSE \n \nMIT LICENSE";


class EasyLocalization extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("easy_localization",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(easy_localization, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(easy_localization, softWrap: true, overflow: TextOverflow.fade,)
                          ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class Intl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("intl",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(intl, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(intl, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class ConfigurableExpansionTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("configurable_expansion_tile",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(configurable_expansion_tile, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(configurable_expansion_tile, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class TimeAgo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("timeago",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(timeago, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(timeago, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class LazyLoadScrollView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("lazy_load_scrollview",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(lazy_load_scrollview, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(lazy_load_scrollview, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class StickyHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("sticky_headers",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(sticky_headers, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(sticky_headers, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class FlutterScreenutil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("flutter_screenutil",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(flutter_screenutil, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(flutter_screenutil, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}


class Catcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("catcher",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(catcher, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(catcher, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class JsonAnnotation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("json_annotation",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(json_annotation, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(json_annotation, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class Dio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("dio",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(dio, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(dio, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class Http extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("http",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(http, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(http, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
class CachedNetworkImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("cached_network_image",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(cached_network_image, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(cached_network_image, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
class FirebaseMessaging extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("firebase_messaging",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(firebase_messaging, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(firebase_messaging, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
class WebSocketChannel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("web_socket_channel",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(web_socket_channel, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(web_socket_channel, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class GeoLocator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("geolocator",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(geolocator, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(geolocator, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
class ImagePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("image_picker",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(image_picker, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(image_picker, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
class PhotoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("photo_view",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(photo_view, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(photo_view, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class SharedPreferences extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("shared_preferences",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(shared_preferences, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(shared_preferences, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class Provider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("provider",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(provider, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(provider, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}


class Kvsql extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("kvsql",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(kvsql, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(kvsql, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}




class Sqlcool extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("sqlcool",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(sqlcool, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(sqlcool, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}





class FlutterFacebookLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("flutter_facebook_login",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(flutter_facebook_login, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(flutter_facebook_login, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}




class GoogleSignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("google_sign_in",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(google_sign_in, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(google_sign_in, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}




class FlutterKakaoLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("flutter_kakao_login",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(flutter_kakao_login, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(flutter_kakao_login, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}




class KakaoFlutterSdk extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("kakao_flutter_sdk",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(kakao_flutter_sdk, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(kakao_flutter_sdk, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}




class AlphabetListScrollView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("alphabet_list_scroll_view",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(alphabet_list_scroll_view, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(alphabet_list_scroll_view, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class FlutterSlidable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("flutter_slidable",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(flutter_slidable, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(flutter_slidable, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}


class ExpandableLibrary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("expandable",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(expandable, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(expandable, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}


class FlutterToast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    tapHeaderToExpand: true,
                    tapBodyToCollapse: true,
                    theme: ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("fluttertoast",
                          style: Theme.of(context).textTheme.body2,
                        )
                    ),
                    collapsed: Text(fluttertoast, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(fluttertoast, softWrap: true, overflow: TextOverflow.fade,)
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}






















