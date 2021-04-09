import 'package:flutter/material.dart';
import 'package:linuxcrate/routes/pkg_manager/packages.dart';

class PackageManagerRoute extends StatefulWidget {
  PackageManagerRoute({Key key}) : super(key: key);

  @override
  _PackageManagerRouteState createState() => _PackageManagerRouteState();
}

class _PackageManagerRouteState extends State<PackageManagerRoute> {
  String _searchPackageKeyword;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Wrap(
      spacing: 3.0,
      children: [
        // Packages search bar
        TextField(
          onChanged: (value) => _searchPackageKeyword,
          decoration: InputDecoration(
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
              future: Package.getLocalPackages(),
              builder: (context, snapshot) {
                final packages = snapshot.data;
                if (snapshot.hasData)
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: packages.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(packages[index].name),
                      subtitle: Text(packages[index].description),
                      isThreeLine: true,
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
