import 'package:flutter/material.dart';

import '../models/task.dart';



class TaskCard extends StatelessWidget {

  final Task task;

  final VoidCallback onTap;

  final VoidCallback onComplete;



  const TaskCard({

    super.key,

    required this.task,

    required this.onTap,

    required this.onComplete,

  });



  @override

  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),

      child: ListTile(

        leading: Checkbox(

          value: task.isCompleted,

          onChanged: (_) => onComplete(),

        ),

        title: Text(

          task.title,

          style: TextStyle(

            decoration: task.isCompleted ? TextDecoration.lineThrough : null,

          ),

        ),

        subtitle: Text(task.description),

        trailing: Row(

          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(

              Icons.flag,

              color: _getPriorityColor(task.priority),

            ),

            const SizedBox(width: 8),

            Text(

              _formatDate(task.dueDate),

              style: Theme.of(context).textTheme.bodySmall,

            ),

          ],

        ),

        onTap: onTap,

      ),

    );

  }



  Color _getPriorityColor(int priority) {

    switch (priority) {

      case 1:

        return Colors.green;

      case 2:

        return Colors.orange;

      case 3:

        return Colors.red;

      default:

        return Colors.grey;

    }

  }



  String _formatDate(DateTime date) {

    return '${date.day}/${date.month}/${date.year}';

  }

} 
