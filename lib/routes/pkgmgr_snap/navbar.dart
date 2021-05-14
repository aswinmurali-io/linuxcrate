import 'package:flutter/material.dart';

import 'content.dart';
import 'pkgmgr.dart';

class PackageManagerSnapNavBar extends StatefulWidget {
  PackageManagerSnapNavBar({Key key}) : super(key: key);

  @override
  _PackageManagerSnapNavBarState createState() => _PackageManagerSnapNavBarState();
}

class _PackageManagerSnapNavBarState extends State<PackageManagerSnapNavBar> {
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
                              .removeLocalPackages(packages[index].name, context);
                          setStateFromContent?.call(() => packageManager);
                          setState(() {});
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.file_upload),
                        onPressed: () => packageManager
                            .updateLocalPackages(packages[index].name, context),
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
