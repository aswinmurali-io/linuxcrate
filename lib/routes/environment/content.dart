// Enviroment content layout code

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
            onPressed: () {},
            icon: Icon(Icons.add),
            label: Text('Add'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: deps.length,
              itemBuilder: (context, index) => ListTile(
                title: Text('${deps[index][0]} ${deps[index][1]} ${deps[index][2]}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
