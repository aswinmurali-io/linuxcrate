import 'package:flutter/material.dart';

class BatchEditsNavBar extends StatefulWidget {
  BatchEditsNavBar({Key key}) : super(key: key);

  @override
  createState() => _DesktopSwitchRouteState();
}

class _DesktopSwitchRouteState extends State<BatchEditsNavBar> {
  @override
  build(context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit,
            size: 80.0,
            color: Colors.blueGrey[200],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Batch Edits",
              style: TextStyle(
                color: Colors.blueGrey[200],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
