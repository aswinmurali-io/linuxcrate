import 'package:flutter/material.dart';

import 'precfg.dart';

class PreConfigRouteNavBar extends StatefulWidget {
  PreConfigRouteNavBar({Key key}) : super(key: key);

  @override
  _PreConfigRouteNavBarState createState() => _PreConfigRouteNavBarState();
}

class _PreConfigRouteNavBarState extends State<PreConfigRouteNavBar> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: PreConfig.loadPacks(),
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
                    onPressed: () async =>
                        await PreConfig.installPack(packs[pack]),
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
