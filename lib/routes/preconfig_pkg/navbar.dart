import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class PreConfigRouteNavBar extends StatefulWidget {
  PreConfigRouteNavBar({Key key}) : super(key: key);

  @override
  _PreConfigRouteNavBarState createState() => _PreConfigRouteNavBarState();
}

class _PreConfigRouteNavBarState extends State<PreConfigRouteNavBar> {
  get url => 'lib/utils/preconfig/packs.json';

  Future<Map<String, dynamic>> loadPacks() async =>
      jsonDecode(await File(url).readAsString());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadPacks(),
      builder: (context, snapshot) {
        final packs = snapshot.data;
        if (snapshot.hasData)
          return ListView(
            children: [
              for (String pack in packs.keys)
                ListTile(
                  title: Text(pack),
                  subtitle: Text(packs[pack]['description']),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () {},
                  ),
                  onTap: () {},
                ),
            ],
          );
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
