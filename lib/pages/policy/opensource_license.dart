import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

const easy_localization = "easy_localization \n https://github.com/aissat/easy_localization/blob/master/LICENSE \n MIT LICENSE";
const intl = "intl \n https://github.com/dart-lang/intl/blob/master/LICENSE \n BSD LICENSE";
const configurable_expansion_tile = "configurable_expansion_tile \n https://github.com/matthewstyler/configurable_expansion_tile/blob/master/LICENSE \n BSD LICENSE";
const timeago = "timea go \n https://github.com/andresaraujo/timeago.dart/blob/master/timeago/LICENSE \n MIT LICENSE";
const lazy_load_scrollview = "lazy_load_scrollview \n https://github.com/QuirijnGB/lazy-load-scrollview/blob/master/LICENSE \n BSD LICENSE";
const sticky_headers = "sticky_headers \n https://github.com/fluttercommunity/flutter_sticky_headers/blob/master/LICENSE \n MIT LICENSE";
const flutter_screenutil = "flutter_screenutil \n https://github.com/OpenFlutter/flutter_screenutil/blob/master/LICENSE \n Apache 2.0 LICENSE";
const catcher = "catcher \n https://github.com/jhomlala/catcher/blob/master/LICENSE \n Apache 2.0 LICENSE";
const json_annotation = "json_annotation \n https://github.com/dart-lang/json_serializable/blob/master/LICENSE \n BSD LICENSE";
const dio = "dio \n https://github.com/flutterchina/dio/blob/master/LICENSE \n  MIT LICENSE";
const http = "http \n https://github.com/dart-lang/http/blob/master/LICENSE \n BSD LICENSE";
const cached_network_image = "cached_network_image \n https://github.com/renefloor/flutter_cached_network_image/blob/master/LICENSE.md \n MIT LICENSE";
const firebase_messaging = "firebase_messaging \n https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_messaging/LICENSE \n BSD LICENSE";
const web_socket_channel = "web_socket_channel \n https://github.com/dart-lang/web_socket_channel/blob/master/LICENSE \n BSD LICENSE";
const geolocator = "geolocator \n https://github.com/Baseflow/flutter-geolocator/blob/master/LICENSE \n MIT LICENSE";
const image_picker = "image_picker \n https://github.com/flutter/plugins/blob/master/packages/image_picker/LICENSE \n Apache 2.0 LICENSE";
const photo_view = "photo_view \n https://github.com/renancaraujo/photo_view/blob/master/LICENSE \n MIT LICENSE";
const shared_preferences = "shared_preferences \n https://github.com/flutter/plugins/blob/master/packages/shared_preferences/shared_preferences/LICENSE \n BSD LICENSE";
const provider = "provider \n https://github.com/rrousselGit/provider/blob/master/packages/provider/LICENSE \n MIT LICENSE";
const kvsql = "kvsql \n https://github.com/synw/kvsql/blob/master/LICENSE \n MIT LICENSE";
const sqlcool = "sqlcool \n https://github.com/synw/sqlcool/blob/master/LICENSE \n MIT LICENSE";
const flutter_facebook_login = "flutter_facebook_login \n https://github.com/roughike/flutter_facebook_login/blob/master/LICENSE \n BSD LICENSE";
const google_sign_in = "google_sign_in \n https://github.com/flutter/plugins/blob/master/packages/google_sign_in/google_sign_in/LICENSE \n BSD LICENSE";
const flutter_kakao_login = "flutter_kakao_login \n https://github.com/JosephNK/flutter_kakao_login/blob/master/LICENSE \n BSD LICENSE";
const kakao_flutter_sdk = "kakao_flutter_sdk \n https://github.com/CoderSpinoza/kakao_flutter_sdk/blob/master/LICENSE \n BSD LICENSE";
const alphabet_list_scroll_view = "alphabet_list_scroll_view \n https://github.com/LiewJunTung/alphabet_list_scroll_view/blob/master/LICENSE \n MIT LICENSE";
const flutter_slidable = "flutter_slidable \n https://github.com/letsar/flutter_slidable/blob/master/LICENSE \n MIT LICENSE";
const expandable = "expandable \n https://github.com/aryzhov/flutter-expandable/blob/master/LICENSE \n MIT LICENSE";
const fluttertoast = "fluttertoast \n https://github.com/PonnamKarthik/FlutterToast/blob/master/LICENSE \n MIT LICENSE";


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






















