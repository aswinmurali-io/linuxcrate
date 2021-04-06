// Enviroment content layout code

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:linuxcrate/routes/environment/common.dart';
import 'package:linuxcrate/routes/environment/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnvironmentDetailsLayout extends StatefulWidget {
  final String title;
  final String desp;
  final Environments environment;
  final StateSetter setStateFromDashboard;
  final List<EnvironmentListTile> environmentList;

  EnvironmentDetailsLayout({
    Key key,
    this.title,
    this.desp,
    this.environment,
    this.setStateFromDashboard,
    this.environmentList,
  }) : super(key: key);

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
  ];

  List<List<String>> _searchDepsList = [];

  Timer _debounce;

  String get utilsPath => 'lib/utils/pypi.py';

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

  void deleteEnvironment() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.remove(widget.title);
    widget.environmentList.removeWhere((env) => env.title == widget.title);
    widget.setStateFromDashboard(() => contentLayout = Container());
  }

  void saveEnvironment() async {
    final preferences = await SharedPreferences.getInstance();
    if (titleTextFieldController.text.isNotEmpty &&
        despTextFieldController.text.isNotEmpty &&
        envTextFieldController.text.isNotEmpty) {
      
      widget.environmentList.removeWhere((env) => env.title == widget.title);
      preferences.remove(widget.title);
      preferences.setStringList(titleTextFieldController.text, [
        despTextFieldController.text,
        envTextFieldController.text,
      ]);
      widget.environmentList.add(EnvironmentListTile(
        title: titleTextFieldController.text,
        desp: despTextFieldController.text,
        environment: envTextFieldController.text == 'Environments.python'
            ? Environments.python
            : Environments.dart,
        setStateDashboard: widget.setStateFromDashboard,
      ));
      widget.setStateFromDashboard(() {
        contentLayout = EnvironmentDetailsLayout(
          title: titleTextFieldController.text,
          desp: despTextFieldController.text,
          environment: envTextFieldController.text == 'Environments.python'
              ? Environments.python
              : Environments.dart,
          environmentList: widget.environmentList,
          setStateFromDashboard: widget.setStateFromDashboard,
        );
      });
    } else
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Cannot have empty fields!")));
  }

  @override
  void dispose() {
    titleTextFieldController.dispose();
    despTextFieldController.dispose();
    envTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    titleTextFieldController.text = widget?.title;
    despTextFieldController.text = widget?.desp;
    envTextFieldController.text = widget?.environment?.toString();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          detailsTemplate("Name", titleTextFieldController),
          detailsTemplate("Description", despTextFieldController),
          detailsTemplate("Environment", envTextFieldController),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Wrap(
              spacing: 20,
              children: [
                ElevatedButton.icon(
                  onPressed: addDepsDialog,
                  icon: Icon(Icons.add),
                  label: Text('Add'),
                ),
                ElevatedButton.icon(
                  onPressed: saveEnvironment,
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                ),
                ElevatedButton.icon(
                  onPressed: deleteEnvironment,
                  icon: Icon(Icons.delete),
                  label: Text('Delete'),
                ),
                ElevatedButton.icon(
                  onPressed: addDepsDialog,
                  icon: Icon(Icons.open_in_browser),
                  label: Text('Open Folder'),
                ),
              ],
            ),
          ),
          FutureBuilder<List<List<String>>>(
              future: getLocalDeps(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final deps = snapshot.data;
                  return depsListGenerator(deps);
                }
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              })
        ],
      ),
    );
  }

  Widget depsListGenerator(List deps) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: Scrollbar(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: deps.length,
            cacheExtent: 15,
            itemBuilder: (context, index) => GridView.builder(
              key: Key('$index'),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 6, crossAxisCount: 3),
              shrinkWrap: true,
              itemCount: deps[index].length,
              itemBuilder: (context, subindex) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.5, color: Colors.blueGrey),
                  ),
                  child: ListTile(
                    tileColor: index == 0 ? Colors.grey[100] : null,
                    title: subindex == 1 && index != 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                                Text('${deps[index][subindex]}'),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.file_download),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.delete),
                                ),
                              ])
                        : Text('${deps[index][subindex]}'),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // The environment details UI. Things like name, description, etc, _________
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

  Future<List<List<String>>> getLocalDeps() async {
    List<List<String>> _tmpList = [];
    _tmpList.add(['Module name', 'Version', 'Description']);
    await Process.run('python', ['-m', 'pip', 'freeze']).then((result) {
      // stdout.write(result.stdout);
      // stderr.write(result.stderr);
      List<String> _tmp = result.stdout.split('\n');
      for (String line in _tmp) {
        List<String> _o = line.split('==');
        _o.add('');
        _tmpList.add(_o);
      }
    });
    return _tmpList;
  }

  bool isVersion(String input) =>
      RegExp('^([1-9]\\d*)\\.(\\d+)\\.(\\d+)(?:-[br]{1}[0-9]?\\d*)?\$')
          .hasMatch(input);

  Future<List<List<String>>> searchDeps(String searchKeyword) async {
    List<List<String>> _tmpList = [];
    _tmpList.add(['Module name', 'Version', 'Description']);
    await Process.run('python', ['-W', 'ignore', utilsPath, searchKeyword])
        .then((result) {
      // stdout.write(result.stdout);
      // stderr.write(result.stderr);
      List<String> _tmp = result.stdout.split('\n');
      for (String line in _tmp) _tmpList.add(line.split('\t'));
    });
    return _tmpList;
  }
}
