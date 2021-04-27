import 'package:flutter/material.dart';

String stdoutTextWidget = '';
StateSetter setStateFromContent;

class PreConfigRouteContent extends StatefulWidget {
  PreConfigRouteContent({Key key}) : super(key: key);

  @override
  _PreConfigRouteContentState createState() => _PreConfigRouteContentState();
}

class _PreConfigRouteContentState extends State<PreConfigRouteContent> {
  final terminalOutputTextController = TextEditingController();

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
          const Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
            child: Text(
              "Terminal Output",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Terminal Output Widget
          SizedBox(
            height: 400,
            child: TextField(
              readOnly: true,
              maxLines: null,
              expands: true,
              controller: terminalOutputTextController,
              style: const TextStyle(
                color: Colors.white,
              ),
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
        ],
      ),
    );
  }
}
