import 'package:flutter/material.dart';
import 'package:linuxcrate/routes/batch_edits/batch_edits.dart';

class BatchEditsContent extends StatefulWidget {
  BatchEditsContent({Key key}) : super(key: key);

  @override
  createState() => _DesktopSwitchRouteState();
}

class _DesktopSwitchRouteState extends State<BatchEditsContent> {
  String sourceRegex = '';
  String desRegex = '';
  String delRegex = '';

  @override
  build(context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Directory Batch copy",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: const Text(
                "Supports regex",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: TextField(
                onChanged: (value) => setState(() => sourceRegex = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Enter path to copy.',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            TextField(
              onChanged: (value) => setState(() => desRegex = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Enter new path.',
                border: OutlineInputBorder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: ElevatedButton.icon(
                label: Text("Copy"),
                icon: Icon(Icons.copy),
                onPressed: () {
                  DesktopManager.batchCopy(sourceRegex, desRegex, context);
                },
              ),
            ),

            // Directory Move
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: const Text(
                "Directory Batch move",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            const Text(
              "Supports regex",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: TextField(
                onChanged: (value) => setState(() => sourceRegex = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Enter path to move.',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            TextField(
              onChanged: (value) => setState(() => desRegex = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Enter new path.',
                border: OutlineInputBorder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: ElevatedButton.icon(
                label: Text("Move"),
                icon: Icon(Icons.copy),
                onPressed: () {
                  DesktopManager.batchMove(sourceRegex, desRegex, context);
                },
              ),
            ),

            // Directory Delete
            const Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: const Text(
                "Directory Batch delete",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            TextField(
              onChanged: (value) => setState(() => delRegex = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Enter directory path with regex expression.',
                border: OutlineInputBorder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: ElevatedButton.icon(
                label: Text("Delete"),
                icon: Icon(Icons.delete),
                onPressed: () {
                  DesktopManager.batchDelete(delRegex, context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
