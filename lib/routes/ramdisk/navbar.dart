import 'package:flutter/material.dart';

import 'ramdisk.dart';

class RamDiskNavBar extends StatefulWidget {
  @override
  createState() => _RamDiskNavBarState();
}

class _RamDiskNavBarState extends State<RamDiskNavBar> {
  final ramDiskMgr = RamDiskManager.getRamDiskManager();
  RamDiskUI ramDiskUI;

  _RamDiskNavBarState() {
    ramDiskUI = RamDiskUI(ramDiskMgr);
  }

  @override
  build(context) {
    return FutureBuilder<List<RamDisk>>(
      future: ramDiskMgr.list(),
      builder: (context, snapshot) {
        final ramdisks = snapshot.data;
        if (snapshot.hasData)
          return ListView(children: [
            OutlinedButton.icon(
              label: Text("New Ram Disk"),
              icon: Icon(Icons.add),
              onPressed: () async {
                await ramDiskUI.askConfig(context);
                await ramDiskMgr.save(ramdisks);
                setState(() => ramdisks);
              },
            ),
            for (var ramdisk in ramdisks)
              ListTile(
                  title: Text(ramdisk.name),
                  subtitle: Text('${ramdisk.sizeInMegaBytes}MB'),
                  onTap: () {},
                  trailing: Wrap(
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await ramDiskMgr.remove(ramdisk);
                          await ramDiskMgr.save(ramdisks);
                          setState(() => ramdisks);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.eject),
                        onPressed: () async {
                          await ramDiskMgr.eject(ramdisk);
                          await ramDiskMgr.save(ramdisks);
                          setState(() => ramdisks);
                        },
                      ),
                    ],
                  )),
          ]);
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
