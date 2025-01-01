import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'task_card.dart';

class TaskSearchDelegate extends SearchDelegate {
  final String userId;

  TaskSearchDelegate({required this.userId});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildTaskList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildTaskList();
  }

  Widget _buildTaskList() {
    print('Building task list for user: $userId');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        print('Snapshot has data: ${snapshot.hasData}');
        print('Documents count: ${snapshot.data?.docs.length}');

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No tasks found'),
                ElevatedButton(
                  onPressed: () async {
                    final task = Task(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: 'Test Task',
                      description: 'Test Description',
                      dueDate: DateTime.now(),
                      userId: userId,
                      priority: 1,
                    );

                    try {
                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(task.id)
                          .set(task.toMap());
                      print('Test task added successfully');
                    } catch (e) {
                      print('Error adding test task: $e');
                    }
                  },
                  child: Text('Add Test Task'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            print('Document data: ${doc.data()}');

            final task = Task.fromMap({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            });

            return TaskCard(
              task: task,
              onTap: () => _showTaskDetails(context, task),
              onComplete: () {
                _updateTaskStatus(task.id, !task.isCompleted);
              },
            );
          },
        );
      },
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TaskCard(
                task: task,
                onTap: () {},
                onComplete: () {
                  _updateTaskStatus(task.id, !task.isCompleted);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showEditDialog(context, task),
                    child: Text('Edit Task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    var dueDate = task.dueDate;
    var priority = task.priority;
    var isCompleted = task.isCompleted;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              DropdownButton<int>(
                value: priority,
                items: [
                  DropdownMenuItem(value: 1, child: Text('Low')),
                  DropdownMenuItem(value: 2, child: Text('Medium')),
                  DropdownMenuItem(value: 3, child: Text('High')),
                ],
                onChanged: (value) {
                  priority = value ?? priority;
                },
              ),
              ListTile(
                title: Text('Due Date: ${dueDate.day}/${dueDate.month}/${dueDate.year}'),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      dueDate = date;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedTask = Task(
                id: task.id,
                title: titleController.text,
                description: descriptionController.text,
                dueDate: dueDate,
                priority: priority,
                isCompleted: isCompleted,
                userId: task.userId,
              );

              await FirebaseFirestore.instance
                  .collection('tasks')
                  .doc(task.id)
                  .update(updatedTask.toMap());

              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTaskStatus(String taskId, bool isCompleted) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': isCompleted});
      print('Task status updated successfully');
    } catch (e) {
      print('Error updating task status: $e');
    }
  }
} 