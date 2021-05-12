import 'package:flutter/material.dart';

import 'ramdisk.dart';

class RamDiskNavBar extends StatefulWidget {
  @override
  createState() => _RamDiskNavBarState();
}

class _RamDiskNavBarState extends State<RamDiskNavBar> {
  RamDiskManager ramDiskMgr;
  RamDiskUI ramDiskUI;

  @override
  initState() {
    super.initState();
    ramDiskMgr = RamDiskManager.get();
    ramDiskUI = RamDiskUI(ramDiskMgr);
  }

  @override
  build(context) {
    return FutureBuilder<List<RamDisk>>(
      future: ramDiskMgr.list(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var ramDisks = snapshot.data;
          return RefreshIndicator(
            onRefresh: () async {
              ramDisks = await ramDiskMgr.checkMounts(ramDisks);
              setState(() => ramDisks);
            },
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                OutlinedButton.icon(
                  label: Text("New Ram Disk"),
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    await ramDiskUI.askConfig(ramDisks, context);
                    await ramDiskMgr.save(ramDisks);
                    setState(() => ramDisks);
                  },
                ),
                for (var ramDisk in ramDisks)
                  ListTile(
                    title: Text(ramDisk.name),
                    subtitle: Text('${ramDisk.sizeInMegaBytes}MB'),
                    onTap: () {},
                    leading: Container(
                      width: 10,
                      color: ramDisk.mounted ? Colors.green : Colors.grey,
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await ramDiskMgr.remove(ramDisks, ramDisk);
                              setState(() => ramDisks);
                            }),
                        IconButton(
                            icon: Icon(Icons.eject),
                            onPressed: () async {
                              await ramDiskMgr.eject(ramDisks, ramDisk);
                              setState(() => ramDisks);
                            }),
                        IconButton(
                            icon: Icon(Icons.usb),
                            onPressed: () async {
                              await ramDiskMgr.mount(ramDisks, ramDisk);
                              setState(() => ramDisks);
                            }),
                        IconButton(
                          icon: Icon(Icons.folder),
                          onPressed: () async => ramDiskMgr.open(ramDisk),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
