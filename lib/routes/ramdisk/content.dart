import 'package:flutter/material.dart';

class RamDiskContent extends StatefulWidget {
  @override
  createState() => _RamDiskContentState();
}

class _RamDiskContentState extends State<RamDiskContent> {
  @override
  build(context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.close_rounded,
            size: 80.0,
            color: Colors.blueGrey[200],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Nothing here for Ram disk!",
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
