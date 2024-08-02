import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/color.dart';
import 'package:todo_app/todo.dart';


class ToDoItem extends StatelessWidget {
  final ToDo todo;
  final Function(ToDo) onToDoChanged;
  final Function(String) onDeleteItem;
  final Function(ToDo) onEditItem;

  const ToDoItem({
    Key? key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
    required this.onEditItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: ListTile(
        onTap: () {
          onToDoChanged(todo);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
        tileColor: Colors.white,
        leading: Icon(
          todo.isDone! ? Icons.check_box : Icons.check_box_outline_blank,
          color: tdBlue,
        ),
        title: Text(
          todo.todoText!,
          style: TextStyle(
            fontSize: 16,
            color: tdBlack,
            decoration: todo.isDone! ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(todo.description!),
            Text(
              'Due Date: ${DateFormat('dd/MM/yyyy').format(todo.dueDate!)}',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              'Priority: ${todo.priority}',
              style: TextStyle(
                color: todo.priority == 'High'
                    ? Colors.red
                    : todo.priority == 'Medium'
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Colors.green,
              onPressed: () {
                onEditItem(todo);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: tdRed,
              onPressed: () {
                onDeleteItem(todo.id!);
              },
            ),
          ],
        ),
      ),
    );
  }
}