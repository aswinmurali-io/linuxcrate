import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'env/navbar.dart';
import 'pkgmgr/content.dart';
import 'pkgmgr/navbar.dart';
import 'precfg/content.dart';
import 'precfg/navbar.dart';


Widget navbar = Container();
Widget contentLayout = Container();

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Widget get border => Flexible(
        flex: 0,
        child: Container(
          width: 0.8,
          color: Colors.grey.withOpacity(.2),
        ),
      );

  void navigate(int index) {
    setState(() {
      switch (index) {
        case 0:
          navbar = EnvironmentNavBar(setStateDashboard: setState);
          contentLayout = Container();
          break;
        case 1:
          navbar = PackageManagerNavBar();
          contentLayout = PackageManagerContent();
          break;
        case 2:
          navbar = PreConfigRouteNavBar();
          contentLayout = PreConfigRouteContent();
          break;
        default:
          navbar = Container();
          contentLayout = Container();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Row(
          children: [
            Container(
              child: Column(
                children: [
                  Expanded(
                    child: NavigationRail(
                      selectedIndex: 0,
                      onDestinationSelected: navigate,
                      labelType: NavigationRailLabelType.none,
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
                          icon: Tooltip(
                              message: 'Packages',
                              child: Icon(FeatherIcons.package)),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          icon: Tooltip(
                              message: 'Pre Configuration',
                              child: Icon(FeatherIcons.book)),
                          label: Text(''),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(FeatherIcons.info),
                    onPressed: () {},
                  )
                ],
              ),
            ),
            border,
            // Nav Bar Layout
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: navbar,
              ),
            ),
            border,
            // Content Layout
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
