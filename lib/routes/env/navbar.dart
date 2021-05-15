// Enviroment navigation bar code

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dashboard.dart';
import 'content.dart';
import 'env.dart';

StateSetter envNavBarSetState;

List<EnvironmentListTile> environmentList = [];

// Environment list tile UI for navbar
class EnvironmentListTile extends StatefulWidget {
  final String title;
  final String desp;
  final Environments environment;
  final dynamic setStateDashboard;

  const EnvironmentListTile({
    Key key,
    this.title,
    this.desp,
    this.environment,
    this.setStateDashboard,
  }) : super(key: key);

  @override
  _EnvironmentListTileState createState() => _EnvironmentListTileState();
}

// Environment navbar UI
class EnvironmentNavBar extends StatefulWidget {
  final dynamic setStateDashboard;

  EnvironmentNavBar({Key key, this.setStateDashboard}) : super(key: key);

  @override
  EnvironmentNavBarState createState() => EnvironmentNavBarState();
}

class _EnvironmentListTileState extends State<EnvironmentListTile> {
  bool _selected = false;

  void onEnvironmentSelected() {
    widget.setStateDashboard(() {
      _selected = !_selected;
      contentLayout = EnvironmentDetailsLayout(
        title: widget.title,
        desp: widget.desp,
        environment: widget.environment,
        setStateFromDashboard: widget.setStateDashboard,
        environmentList: environmentList,
      );
    });
  }

  Future<void> onEnvironmentDeleted() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.remove(widget.title);
    environmentList.removeWhere((env) => env.title == widget.title);
    widget.setStateDashboard(() {
      contentLayout = Container();
      navbar = EnvironmentNavBar(
        setStateDashboard: widget.setStateDashboard,
      );
    });
    await Process.run('sudo', ['rm', '-rf', widget.title]);
  }

  @override
  void initState() {
    // environmentList.clear();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    envNavBarSetState = setState;
    return InkWell(
      onTap: onEnvironmentSelected,
      child: Container(
          color: _selected ? Colors.grey.withOpacity(0.1) : null,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            widget?.title ?? 'Untitled',
                            style: TextStyle(
                                color: Colors.grey
                                    .withOpacity(_selected ? 1 : 0.5),
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              widget?.desp ?? 'No Description',
                              style: GoogleFonts.ubuntu(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              widget?.environment.toString() ??
                                  'Unknown environment',
                              style: GoogleFonts.ubuntu(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  if (_selected)
                    Flexible(
                      flex: 0,
                      child: Container(
                        width: 3,
                        color: Color(
                          0xff5d71e1,
                        ),
                      ),
                    )
                ],
              ),
              IconButton(
                onPressed: onEnvironmentDeleted,
                icon: Icon(Icons.delete),
              ),
            ],
          )),
    );
  }
}

class EnvironmentNavBarState extends State<EnvironmentNavBar> {
  String _title = '';
  String _description = '';

  Future<void> loadEnvironmentListDetails() async {
    final preferences = await SharedPreferences.getInstance();
    Set<String> keys = preferences.getKeys();
    print(keys);
    keys.forEach((key) {
      List<String> content = preferences.getStringList(key);
      setState(() {
        environmentList.add(EnvironmentListTile(
          title: key,
          desp: content[0],
          // TODO: provide a custom toString() and toEnvironment() implementation.
          environment: content[1] == 'Environments.python'
              ? Environments.python
              : Environments.dart,
          setStateDashboard: widget.setStateDashboard,
        ));
      });
    });
  }

  Future<void> onEnvironmentMade(Environments selectedEnvironment) async {
    if (_title.isNotEmpty && _description.isNotEmpty) {
      setState(() {
        environmentList.add(EnvironmentListTile(
          title: _title,
          desp: _description,
          environment: selectedEnvironment,
          setStateDashboard: widget.setStateDashboard,
        ));
      });
      final preferences = await SharedPreferences.getInstance();
      preferences.setStringList(_title, [
        _description,
        selectedEnvironment.toString(),
      ]);
      // python3 -m venv <env_title>
      await Process.run('sudo', [python, '-m', 'venv', _title]).then((result) {
        stdout.write(result.stdout);
        stderr.write(result.stderr);
        print(true);
      });
    } else
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill the details!")));
  }

  @override
  void initState() {
    envNavBarSetState = setState;
    environmentList.clear();
    loadEnvironmentListDetails();
    super.initState();
  }

  Widget get environmentCreateMenu => Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blueGrey[400],
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(9.0),
            ),
          ),
          child: SizedBox(
            height: 40,
            child: PopupMenuButton<Environments>(
              onCanceled: null,
              onSelected: onEnvironmentMade,
              itemBuilder: (BuildContext context) {
                _title = '';
                _description = '';
                return <PopupMenuEntry<Environments>>[
                  PopupMenuItem<Environments>(
                    child: TextField(
                      maxLength: 30,
                      onChanged: (value) => _title = value,
                      decoration: InputDecoration(
                          hintText: 'Enter name for the environment'),
                    ),
                  ),
                  PopupMenuItem<Environments>(
                    child: TextField(
                      maxLength: 50,
                      onChanged: (value) => _description = value,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter keyword for reference'),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<Environments>(
                    value: Environments.python,
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Icon(Icons.code)),
                        Expanded(
                          flex: 10,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Text(
                              'Create new python environment with virtualenv.',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const PopupMenuDivider(),
                  // PopupMenuItem<Environments>(
                  //     value: Environments.dart,
                  //     child: Row(
                  //       children: [
                  //         Expanded(flex: 1, child: Icon(Icons.code)),
                  //         Expanded(
                  //           flex: 10,
                  //           child: Padding(
                  //             padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  //             child: Text(
                  //               'Create new dart environment using pubspec.',
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     )),
                ];
              },
              child: Align(
                  alignment: Alignment.center,
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Icon(
                              Icons.add,
                              size: 15.0,
                              color: Colors.blueGrey[400],
                            ),
                          ),
                        ),
                        TextSpan(
                          text: 'New Environment',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.blueGrey[400],
                          ),
                        ),
                      ]))),
            ),
          ),
        ),
      );

  bool lock = false;

  @override
  Widget build(BuildContext context) {
    if (!lock) {
      
      lock = true;
    }
    return ListView(
      children: [
        Text(
          'Linux Crate',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        environmentCreateMenu,
        const Padding(padding: const EdgeInsets.fromLTRB(0, 30, 0, 0)),
        ...environmentList
      ],
    );
  }
}
