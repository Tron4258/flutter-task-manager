class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final int priority;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 2,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'userId': userId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] ?? false,
      priority: map['priority'] ?? 2,
      userId: map['userId'],
    );
  }
} 