class ToDo {
  String? id;
  String? todoText;
  String? description;
  String? priority;
  bool? isDone;
  DateTime? dueDate;

  ToDo({
    required this.id,
    required this.todoText,
    required this.description,
    required this.priority,
    this.isDone = false,
    this.dueDate,
  });

  static List<ToDo> todoList() {
    return [];
  }

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
      description: json['description'],
      priority: json['priority'],
      isDone: json['isDone'],
      dueDate: DateTime.parse(json['dueDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'description': description,
      'priority': priority,
      'isDone': isDone,
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}