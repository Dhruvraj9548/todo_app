class ToDo {
  String? id;
  String? todoText;
  String? description;
  String? priority;
  DateTime? dueDate;
  bool? isDone;

  ToDo({
    required this.id,
    required this.todoText,
    this.description,
    this.priority,
    this.dueDate,
    this.isDone = false,
  });

  static List<ToDo> todoList() {
    return [];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'todoText': todoText,
    'description': description,
    'priority': priority,
    'dueDate': dueDate?.toIso8601String(),
    'isDone': isDone,
  };

  factory ToDo.fromJson(Map<String, dynamic> json) => ToDo(
    id: json['id'],
    todoText: json['todoText'],
    description: json['description'],
    priority: json['priority'],
    dueDate: DateTime.parse(json['dueDate']),
    isDone: json['isDone'],
  );
}