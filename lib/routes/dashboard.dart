import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:linuxcrate/routes/environment/common.dart';
import 'package:linuxcrate/routes/environment/navbar.dart';
import 'package:linuxcrate/routes/pkg_manager/content.dart';
import 'package:linuxcrate/routes/pkg_manager/navbar.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

Widget dashboardRoute = Container();

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  final _scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    dashboardRoute = EnvironmentNavBar(setStateDashboard: setState);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldkey,
      drawer: Drawer(),
      body: Container(
        child: Row(
          children: <Widget>[
            Container(
              child: Column(
                children: [
                  Expanded(
                    child: NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (int index) => setState(() {
                        switch (index) {
                          case 0:
                            dashboardRoute =
                                EnvironmentNavBar(setStateDashboard: setState);
                            break;
                          case 1:
                            dashboardRoute = PackageManagerNavBar();
                            contentLayout = PackageManagerContent();
                            break;
                          default:
                        }
                      }),
                      leading: Column(
                        children: [
                          // Container(
                          //   child: IconButton(
                          //     icon: Icon(
                          //       FeatherIcons.menu,
                          //       size: 19,
                          //       color: Colors.grey[800],
                          //     ),
                          //     onPressed: () =>
                          //         _scaffoldkey.currentState.openDrawer(),
                          //   ),
                          //   margin: EdgeInsets.only(bottom: 18),
                          // ),
                        ],
                      ),
                      labelType: NavigationRailLabelType.none,
                      // selectedIconTheme: IconThemeData(size: 19),
                      unselectedIconTheme:
                          IconThemeData(size: 19, color: Colors.grey[500]),
                      selectedIconTheme:
                          IconThemeData(size: 19, color: Colors.grey[500]),
                      destinations: [
                        NavigationRailDestination(
                          icon: Tooltip(
                              message: 'Environment',
                              child: Icon(FeatherIcons.layout)),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          icon: Icon(FeatherIcons.briefcase),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          icon: Icon(FeatherIcons.bell),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          icon: Icon(FeatherIcons.user),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          icon: Icon(FeatherIcons.settings),
                          label: Text(''),
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: Icon(FeatherIcons.info), onPressed: () {})
                ],
              ),
            ),
            Flexible(
                flex: 0,
                child: Container(
                  width: 0.8,
                  color: Colors.grey.withOpacity(.2),
                )),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: dashboardRoute,
              ),
            ),
            Flexible(
                flex: 0,
                child: Container(
                  width: 0.8,
                  color: Colors.grey.withOpacity(.2),
                )),
            Flexible(
              flex: 3,
              child: contentLayout,
            ),
          ],
        ),
      ),
    );
  }
}
