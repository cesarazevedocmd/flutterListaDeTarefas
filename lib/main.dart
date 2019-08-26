import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];

  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _readData().then((value) {
      setState(() {
        _toDoList = json.decode(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getAppBar(),
      body: getBodyApp(),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      title: Center(
        child: Text("Lista de Tarefas"),
      ),
      backgroundColor: Colors.blue,
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return "";
    }
  }

  Widget getBodyApp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(5.0, 2.0, 2.0, 2.0),
          child: Row(
            children: <Widget>[
              _getTextfieldNewTask(),
              _getRaisedButtonAdd(),
            ],
          ),
        ),
        _getListView(),
      ],
    );
  }

  RaisedButton _getRaisedButtonAdd() {
    return RaisedButton(
      color: Colors.blueAccent,
      child: Text("ADD"),
      textColor: Colors.white,
      onPressed: _addTask,
    );
  }

  Expanded _getTextfieldNewTask() {
    return Expanded(
      child: TextField(
        controller: _textController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: "Nova Tarefa",
          labelStyle: TextStyle(
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _getListView() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 10.0),
        itemCount: _toDoList.length,
        itemBuilder: _getListViewItemBuilder,
      ),
    );
  }

  Widget _getListViewItemBuilder(context, index) {
    final item = _toDoList[index];

    return Dismissible(
      key: Key(DateTime.now().millisecond.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(item["title"]),
        value: item["ok"],
        secondary: CircleAvatar(
          foregroundColor: Colors.white,
          child: Icon(
            item["ok"] ? Icons.check : Icons.info,
          ),
        ),
        onChanged: (check) {
          setState(() {
            item["ok"] = check;
          });
          _saveData();
        },
      ),
    );
  }

  void _addTask() {
    String newTask = _textController.text;
    if (newTask.isNotEmpty) {
      setState(() {
        _toDoList.add(_getNewTask(newTask));
      });
      _saveData();
      _textController.text = "";
    }
  }

  dynamic _getNewTask(String task) {
    return {"title": "$task", "ok": false};
  }
}
