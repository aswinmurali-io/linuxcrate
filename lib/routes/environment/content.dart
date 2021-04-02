// Enviroment content layout code

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:linuxcrate/routes/environment/common.dart';

class EnvironmentDetailsLayout extends StatefulWidget {
  final String title;

  final String desp;
  final Environments environment;
  EnvironmentDetailsLayout({Key key, this.title, this.desp, this.environment})
      : super(key: key);

  @override
  _EnvironmentDetailsLayoutState createState() =>
      _EnvironmentDetailsLayoutState();
}

class _EnvironmentDetailsLayoutState extends State<EnvironmentDetailsLayout> {
  final titleTextFieldController = TextEditingController();
  final despTextFieldController = TextEditingController();
  final envTextFieldController = TextEditingController();

  List<List<String>> deps = [
    ['Module name', 'Version', 'Description'],
    ['pip', '2.1', 'pip is pip!'],
  ];

  Widget detailsTemplate(String name, TextEditingController controller) => Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(name),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: TextField(
                controller: controller,
              ),
            ),
          ),
        ],
      );

  bool isVersion(String input) =>
      RegExp('^([1-9]\\d*)\\.(\\d+)\\.(\\d+)(?:-[br]{1}[0-9]?\\d*)?\$')
          .hasMatch(input);

  String get utilsPath => 'lib/utils/pypi.py';

  List<List<String>> _searchDepsList = [];
  Timer _debounce;

  Future<List<List<String>>> searchDeps(String searchKeyword) async {
    List<List<String>> _tmpList = [];
    _tmpList.add(['Module name', 'Version', 'Description']);
    await Process.run('python', ['-W', 'ignore', utilsPath, searchKeyword])
        .then((result) {
      stdout.write(result.stdout);
      List<String> _tmp = result.stdout.split('\n');
      for (String line in _tmp) _tmpList.add(line.split('\t'));
      stderr.write(result.stderr);
    });
    print(_tmpList);
    return _tmpList;
  }

  Future<dynamic> addDepsDialog() => showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setStateDialog) {
            return AlertDialog(
              title: Text("Add Dependencies"),
              content: SizedBox(
                width: 1000,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (searchKeyword) {
                        if (_debounce?.isActive ?? false) _debounce.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 500), () async {
                          _searchDepsList = await searchDeps(searchKeyword);
                          setStateDialog(() => _searchDepsList);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search packages',
                        border: OutlineInputBorder(),
                        suffix: ElevatedButton.icon(
                          icon: Icon(Icons.search),
                          label: Text('Search'),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    Scrollbar(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          height: 500,
                          child: depsListGenerator(_searchDepsList),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton.icon(
                  label: Text("Cancel"),
                  icon: Icon(Icons.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton.icon(
                  label: Text("Save"),
                  icon: Icon(Icons.save),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          });
        },
      );

  Widget depsListGenerator(List deps) => ListView.builder(
        shrinkWrap: true,
        itemCount: deps.length,
        itemBuilder: (context, index) => GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 6, crossAxisCount: 3),
          shrinkWrap: true,
          itemCount: deps[index].length,
          itemBuilder: (context, subindex) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.blueGrey),
              ),
              child: ListTile(
                tileColor: index == 0 ? Colors.grey[100] : null,
                title: subindex == 1 && index != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text('${deps[index][subindex]}'),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.file_upload),
                            )
                          ])
                    : Text('${deps[index][subindex]}'),
                onTap: () {},
              ),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    titleTextFieldController.text = widget?.title ?? '';
    despTextFieldController.text = widget?.desp ?? '';
    envTextFieldController.text = widget?.environment?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          detailsTemplate("Name", titleTextFieldController),
          detailsTemplate("Description", despTextFieldController),
          detailsTemplate("Environment", envTextFieldController),
          ElevatedButton.icon(
            onPressed: addDepsDialog,
            icon: Icon(Icons.add),
            label: Text('Add'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: depsListGenerator(deps),
            ),
          ),
        ],
      ),
    );
  }
}
