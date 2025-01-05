import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';
import '../models/task_category.dart';



class TaskCard extends StatelessWidget {

  final Task task;

  final VoidCallback onTap;

  final VoidCallback? onDelete;



  const TaskCard({

    super.key,

    required this.task,

    required this.onTap,

    this.onDelete,

  });



  @override

  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          if (task.categoryId != null)

            StreamBuilder<DocumentSnapshot>(

              stream: FirebaseFirestore.instance

                  .collection('categories')

                  .doc(task.categoryId)

                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) return SizedBox();

                

                final category = TaskCategory.fromMap({

                  ...snapshot.data!.data() as Map<String, dynamic>,

                  'id': snapshot.data!.id,

                });



                return Container(

                  color: category.color.withOpacity(0.1),

                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),

                  child: Row(

                    children: [

                      Container(

                        width: 12,

                        height: 12,

                        decoration: BoxDecoration(

                          color: category.color,

                          shape: BoxShape.circle,

                        ),

                      ),

                      SizedBox(width: 8),

                      Text(

                        category.name,

                        style: TextStyle(

                          color: category.color,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                    ],

                  ),

                );

              },

            ),

          ListTile(

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

                _buildPriorityChip(),

                const SizedBox(width: 8),

                Text(

                  _formatDate(task.dueDate),

                  style: Theme.of(context).textTheme.bodySmall,

                ),

                if (onDelete != null) ...[

                  const SizedBox(width: 8),

                  IconButton(

                    icon: Icon(Icons.delete, color: Colors.red),

                    onPressed: onDelete,

                  ),

                ],

              ],

            ),

            onTap: onTap,

          ),

          if (_isOverdue())

            Container(

              color: Colors.red.withOpacity(0.1),

              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),

              child: Row(

                children: [

                  Icon(Icons.warning, color: Colors.red, size: 16),

                  SizedBox(width: 8),

                  Text(

                    'Overdue',

                    style: TextStyle(color: Colors.red),

                  ),

                ],

              ),

            ),

        ],

      ),

    );

  }



  Widget _buildPriorityChip() {

    Color color;

    String label;

    

    switch (task.priority) {

      case 1:

        color = Colors.green;

        label = 'Low';

        break;

      case 2:

        color = Colors.orange;

        label = 'Medium';

        break;

      case 3:

        color = Colors.red;

        label = 'High';

        break;

      default:

        color = Colors.grey;

        label = 'None';

    }



    return Chip(

      label: Text(

        label,

        style: TextStyle(color: Colors.white, fontSize: 12),

      ),

      backgroundColor: color,

      padding: EdgeInsets.zero,

      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

    );

  }



  bool _isOverdue() {

    return !task.isCompleted && task.dueDate.isBefore(DateTime.now());

  }



  String _formatDate(DateTime date) {

    return '${date.day}/${date.month}/${date.year}';

  }

} 
