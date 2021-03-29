import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linuxcrate/routes/dashboard.dart';

enum Environments { python, dart }

class EnvironmentNavBar extends StatefulWidget {
  EnvironmentNavBar({Key key, this.setStateDashboard}) : super(key: key);

  final dynamic setStateDashboard;

  @override
  _EnvironmentNavBarState createState() => _EnvironmentNavBarState();
}

class _EnvironmentNavBarState extends State<EnvironmentNavBar> {
  List<Widget> _environmentList = [];

  @override
  Widget build(BuildContext context) {

    return ListView(
      controller: ScrollController(),
      padding: EdgeInsets.all(0),
      children: [
            Text(
              'Linux Crate',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
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
                    onSelected: (Environments selectedEnvironment) {
                      setState(() => _environmentList.add(EnvironmentListTile(
                            environment: selectedEnvironment,
                            setStateDashboard: widget.setStateDashboard,
                          )));
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<Environments>>[
                      PopupMenuItem<Environments>(
                        value: Environments.python,
                        child: Row(
                          children: [
                            Expanded(flex: 1, child: Icon(Icons.code)),
                            Expanded(
                                flex: 10,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Text(
                                      'Create new python environment with virtualenv.'),
                                )),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<Environments>(
                          value: Environments.dart,
                          child: Row(
                            children: [
                              Expanded(flex: 1, child: Icon(Icons.code)),
                              Expanded(
                                  flex: 10,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                    child: Text(
                                        'Create new dart environment using pubspec.'),
                                  )),
                            ],
                          )),
                    ],
                    child: Align(
                        alignment: Alignment.center,
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              WidgetSpan(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 10, 0),
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
            ),
            const Padding(padding: const EdgeInsets.fromLTRB(0, 30, 0, 0)),
            EnvironmentListTile()
          ] +
          _environmentList,
    );
  }
}

class EnvironmentListTile extends StatefulWidget {
  const EnvironmentListTile(
      {Key key,
      this.title,
      this.desp,
      this.environment,
      this.setStateDashboard})
      : super(key: key);

  final String title;
  final String desp;
  final Environments environment;
  final dynamic setStateDashboard;

  @override
  _EnvironmentListTileState createState() => _EnvironmentListTileState();
}

class _EnvironmentListTileState extends State<EnvironmentListTile> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() => _selected = !_selected);
        widget.setStateDashboard(
          () => contentLayout = EnvironmentDetailsLayout(
            title: widget.title,
            desp: widget.desp,
            environment: widget.environment,
          ),
        );
      },
      child: Container(
        color: _selected ? Colors.grey.withOpacity(0.1) : null,
        child: Row(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      widget?.title ?? 'Title',
                      style: TextStyle(
                          color: Colors.grey.withOpacity(_selected ? 1 : 0.5),
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        widget?.desp ?? 'Description',
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
                        widget?.environment.toString() ?? 'Unknown environment',
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
                    color: Color(0xff5d71e1),
                  ))
          ],
        ),
      ),
    );
  }
}

class EnvironmentDetailsLayout extends StatefulWidget {
  EnvironmentDetailsLayout({Key key, this.title, this.desp, this.environment})
      : super(key: key);

  final String title;
  final String desp;
  final Environments environment;

  @override
  _EnvironmentDetailsLayoutState createState() =>
      _EnvironmentDetailsLayoutState();
}

class _EnvironmentDetailsLayoutState extends State<EnvironmentDetailsLayout> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget?.title ?? ''),
        Text(widget?.desp ?? ''),
        Text(widget?.environment?.toString() ?? ''),
      ],
    );
  }
}
