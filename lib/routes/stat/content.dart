import 'package:flutter/material.dart';

class StatMonitor extends StatefulWidget {
  StatMonitor({Key key}) : super(key: key);

  @override
  _StatMonitorState createState() => _StatMonitorState();
}

class _StatMonitorState extends State<StatMonitor> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Text("Hi"),
    );
  }
}