import 'package:flutter/material.dart';

import 'content.dart';
import 'pkgmgr.dart';

class PackageManagerNavBar extends StatefulWidget {
  PackageManagerNavBar({Key key}) : super(key: key);

  @override
  _PackageManagerNavBarState createState() => _PackageManagerNavBarState();
}

class _PackageManagerNavBarState extends State<PackageManagerNavBar> {
  String _searchPackageKeyword = '';

  final packageManager = PackageManager.getPackageManager();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Wrap(
      spacing: 3.0,
      children: [
        // Packages search bar
        TextField(
          onChanged: (value) => setState(() => _searchPackageKeyword = value),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search packages',
            border: OutlineInputBorder(),
          ),
        ),
        // Locally installed packages list
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: screenSize.height / 1.2,
            child: FutureBuilder<List<Package>>(
              future:
                  packageManager.searchLocalPackages(_searchPackageKeyword),
              builder: (context, snapshot) {
                final packages = snapshot.data;

                if (snapshot.hasData)
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: packages.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await packageManager
                              .removeLocalPackages(packages[index].name);
                          setStateFromContent?.call(() => packageManager);
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.file_upload),
                        onPressed: () => packageManager
                            .updateLocalPackages(packages[index].name),
                      ),
                      title: SizedBox(
                        width: 300,
                        child: Text(
                          packages[index].name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Text(packages[index].description),
                      isThreeLine: false,
                      onTap: () {},
                    ),
                  );

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
