import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:string_similarity/string_similarity.dart';

import 'pkgmgr.dart';

String stdoutTextWidget = '';
StateSetter setStateFromContent;

class PackageManagerContentSnap extends StatefulWidget {
  PackageManagerContentSnap({Key key}) : super(key: key);

  @override
  _PackageManagerContentSnapState createState() =>
      _PackageManagerContentSnapState();
}

class _PackageManagerContentSnapState extends State<PackageManagerContentSnap> {
  final terminalOutputTextController = TextEditingController();

  List<String> _packagesInfo = [];
  String _searchKeyword = '';

  final packageManager = PackageManager.getPackageManager();

  @override
  void initState() {
    setStateFromContent = setState;
    super.initState();
  }

  @override
  void dispose() {
    terminalOutputTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    terminalOutputTextController
      ..text = stdoutTextWidget
      ..selection = TextSelection.fromPosition(
        TextPosition(
          offset: terminalOutputTextController.text.length,
        ),
      );
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar for online packages
          TextField(
            onChanged: (value) {
              _packagesInfo.clear();
              setState(() => _searchKeyword = value);
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search Packages Online',
              border: OutlineInputBorder(),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  label: Text('Install'),
                  icon: Icon(Icons.download_rounded),
                  onPressed: () async {
                    if (_searchKeyword.isNotEmpty)
                      setState(() => packageManager
                          .installGlobalPackage(_searchKeyword, context)
                          .then((stdout) => stdoutTextWidget = stdout));
                  },
                ),
              ),
            ),
          ),
          const Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              "Terminal Output",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Terminal Output Widget
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: SizedBox(
              height: 200,
              child: TextField(
                readOnly: true,
                maxLines: null,
                expands: true,
                controller: terminalOutputTextController,
                style: TextStyle(color: Colors.white),
                textAlignVertical: TextAlignVertical.top,
                cursorColor: Colors.white,
                showCursor: true,
                cursorWidth: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.black,
                  filled: true,
                ),
              ),
            ),
          ),
          FutureBuilder<List<String>>(
              future: packageManager.searchGlobalPackages(_searchKeyword),
              builder: (context, snapshot) {
                final _packagesInfo = snapshot.data;
                print(_packagesInfo);
                if (snapshot.hasData)
                  return Expanded(
                    child: Scrollbar(
                      child: GridView.builder(
                        itemCount: _packagesInfo.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 4.0,
                        ),
                        itemBuilder: (context, index) {
                          final content = _packagesInfo[index].split(' ');
                          print(content);
                          return ListTile(
                            title: Text(
                              content[0],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(content.skip(3).first),
                            isThreeLine: true,
                            onTap: () async {
                              setState(() => packageManager
                                  .installGlobalPackage(content[0], context)
                                  .then((stdout) => stdoutTextWidget = stdout));
                            },
                          );
                        },
                      ),
                    ),
                  );
                return Center();
              }),
        ],
      ),
    );
  }
}
