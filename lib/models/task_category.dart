import 'package:flutter/material.dart';

class TaskCategory {
  final String id;
  final String name;
  final Color color;

  TaskCategory({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
    };
  }

  factory TaskCategory.fromMap(Map<String, dynamic> map) {
    return TaskCategory(
      id: map['id'],
      name: map['name'],
      color: Color(map['color']),
    );
  }
} 