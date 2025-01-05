import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onStatusChanged;

  TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText() {
    switch (task.priority) {
      case 3:
        return 'High';
      case 2:
        return 'Medium';
      case 1:
        return 'Low';
      default:
        return 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = !task.isCompleted && task.dueDate.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          border: isOverdue
              ? Border(
                  left: BorderSide(
                    color: Colors.red,
                    width: 4,
                  ),
                )
              : null,
        ),
        child: InkWell(
          onTap: task.isCompleted ? null : onEdit,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted ? Colors.grey : null,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPriorityColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getPriorityText(),
                              style: TextStyle(
                                color: _getPriorityColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!task.isCompleted)
                          IconButton(
                            icon: Icon(Icons.check_circle_outline),
                            onPressed: () => onStatusChanged(true),
                            tooltip: 'Mark as completed',
                          ),
                        if (task.isCompleted)
                          IconButton(
                            icon: Icon(
                              Icons.undo,
                              color: Colors.blue,
                            ),
                            onPressed: () => onStatusChanged(false),
                            tooltip: 'Mark as active',
                          ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: onDelete,
                          tooltip: 'Delete task',
                        ),
                      ],
                    ),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    task.description,
                    style: TextStyle(
                      color: task.isCompleted ? Colors.grey : null,
                    ),
                  ),
                ],
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isOverdue ? Colors.red : Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('MMM d, y').format(task.dueDate)}',
                      style: TextStyle(
                        color: task.isCompleted 
                          ? Colors.grey 
                          : isOverdue
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                    if (isOverdue) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'OVERDUE',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
