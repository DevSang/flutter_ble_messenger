import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

const easy_localization = "easy_localization \n https://github.com/aissat/easy_localization/blob/master/LICENSE \n MIT LICENSE";
const intl = "intl \n https://github.com/dart-lang/intl/blob/master/LICENSE \n BSD LICENSE";
const configurable_expansion_tile = "configurable_expansion_tile \n https://github.com/matthewstyler/configurable_expansion_tile/blob/master/LICENSE \n BSD LICENSE";
const timeago = "timeago \n ";
const lazy_load_scrollview = "lazy_load_scrollview \n ";
const sticky_headers = "sticky_headers \n ";
const flutter_screenutil = "flutter_screenutil \n ";
const catcher = "catcher \n ";
const json_annotation = "json_annotation \n ";
const dio = "dio \n ";
const http = "http \n ";
const cached_network_image = "cached_network_image \n ";
const firebase_messaging = "firebase_messaging \n ";
const web_socket_channel = "web_socket_channel \n ";
const geolocator = "geolocator \n ";
const image_picker = "image_picker \n ";
const photo_view = "photo_view \n ";
const shared_preferences = "shared_preferences \n ";
const provider = "providerv \n ";
const kvsql = "kvsql \n ";
const sqlcool = "sqlcool \n ";
const flutter_facebook_login = "flutter_facebook_login \n ";
const google_sign_in = "google_sign_in \n ";
const flutter_kakao_login = "flutter_kakao_login \n ";
const kakao_flutter_sdk = "kakao_flutter_sdk \n ";
const alphabet_list_scroll_view = "alphabet_list_scroll_view \n ";
const flutter_slidable = "flutter_slidable \n ";
const expandable = "expandable \n ";
const fluttertoast = "fluttertoast \n ";


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
                              padding: EdgeInsets.only(bottom: 5),
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
                            padding: EdgeInsets.only(bottom: 5),
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
