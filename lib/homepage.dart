import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/color.dart';
import 'package:todo_app/todo.dart';
import 'package:todo_app/todo_item.dart';


class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> todosList = [];
  List<ToDo> _foundToDo = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  String _priority = 'High';
  ToDo? _editingToDo;

  @override
  void initState() {
    super.initState();
    _loadToDoList();
  }

  Future<void> _loadToDoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todoListString = prefs.getString('todoList');
    if (todoListString != null) {
      List<dynamic> todoListJson = jsonDecode(todoListString);
      todosList = todoListJson.map((json) => ToDo.fromJson(json)).toList();
    } else {
      todosList = ToDo.todoList();
    }
    setState(() {
      _foundToDo = todosList;
    });
  }

  Future<void> _saveToDoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> todoListJson = todosList.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setString('todoList', jsonEncode(todoListJson));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 50,
                          bottom: 20,
                        ),
                        child: Text(
                          'All ToDos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (ToDo todo in _foundToDo.reversed)
                        ToDoItem(
                          todo: todo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                          onEditItem: _showEditTodoDialog,
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                    left: 20,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                  right: 20,
                ),
                child: ElevatedButton(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  onPressed: () {
                    _showAddTodoDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tdBlue,
                    minimumSize: Size(60, 60),
                    elevation: 10,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone!;
    });
    _saveToDoList();
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
    });
    _saveToDoList();
  }

  void _addToDoItem(String title, String description, String priority, DateTime dueDate) {
    setState(() {
      todosList.add(ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      ));
      _foundToDo = todosList;
    });
    _saveToDoList();
  }

  void _editToDoItem(String id, String title, String description, String priority, DateTime dueDate) {
    setState(() {
      final todo = todosList.firstWhere((item) => item.id == id);
      todo.todoText = title;
      todo.description = description;
      todo.priority = priority;
      todo.dueDate = dueDate;
      _foundToDo = todosList;
    });
    _saveToDoList();
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
          .toLowerCase()
          .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  void _showAddTodoDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _dateController.clear();
    _priority = 'High';
    _editingToDo = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New ToDo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(hintText: 'Description'),
              ),
              DropdownButton<String>(
                value: _priority,
                items: <String>['High', 'Medium', 'Low']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(hintText: 'Due Date (DD/MM/YYYY)'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    String formattedDate =
                    DateFormat('dd/MM/yyyy').format(pickedDate);
                    _dateController.text = formattedDate;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                final title = _titleController.text;
                final description = _descriptionController.text;
                final priority = _priority;
                final dueDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);

                if (_editingToDo == null) {
                  _addToDoItem(title, description, priority, dueDate);
                } else {
                  _editToDoItem(_editingToDo!.id!, title, description, priority, dueDate);
                }

                _titleController.clear();
                _descriptionController.clear();
                _dateController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditTodoDialog(ToDo todo) {
    _titleController.text = todo.todoText!;
    _descriptionController.text = todo.description!;
    _priority = todo.priority!;
    _dateController.text = DateFormat('dd/MM/yyyy').format(todo.dueDate!);
    _editingToDo = todo;

    _showAddTodoDialog();
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size

                : 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }
}