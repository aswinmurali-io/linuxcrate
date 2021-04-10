import 'package:flutter/material.dart';
import 'package:linuxcrate/routes/pkg_manager/packages.dart';

class PackageManagerRoute extends StatefulWidget {
  PackageManagerRoute({Key key}) : super(key: key);

  @override
  _PackageManagerRouteState createState() => _PackageManagerRouteState();
}

class _PackageManagerRouteState extends State<PackageManagerRoute> {
  String _searchPackageKeyword = '';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Wrap(
      spacing: 3.0,
      children: [
        // Packages search bar
        TextField(
          onChanged: (value) => setState(() => _searchPackageKeyword = value),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search packages',
            border: OutlineInputBorder(),
          ),
        ),
        // Locally installed packages list
        Scrollbar(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: screenSize.height / 1.2,
              child: FutureBuilder<List<Package>>(
                future: Package.searchLocalPackages(_searchPackageKeyword),
                builder: (context, snapshot) {
                  final packages = snapshot.data;

                  if (snapshot.hasData)
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: packages.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () =>
                              Package.removeLocalPackages(packages[index].name),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.update),
                          onPressed: () =>
                              Package.updateLocalPackages(packages[index].name),
                        ),
                        title: SizedBox(
                            width: 300, child: Text(packages[index].name)),
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
        ),
      ],
    );
  }
}
