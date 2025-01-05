class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final int priority;
  final String userId;
  final String? categoryId;
  final List<String> searchableText;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.userId,
    this.isCompleted = false,
    this.priority = 2,
    this.categoryId,
  }) : searchableText = _generateSearchableText(title, description);

  static List<String> _generateSearchableText(String title, String description) {
    final words = [...title.toLowerCase().split(' '), ...description.toLowerCase().split(' ')]
        .where((word) => word.isNotEmpty)
        .toSet()
        .toList();
    return words;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'userId': userId,
      'categoryId': categoryId,
      'searchableText': searchableText,
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
      categoryId: map['categoryId'],
    );
  }
} 