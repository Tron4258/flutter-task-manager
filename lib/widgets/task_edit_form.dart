import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskEditForm extends StatefulWidget {
  final Task task;

  TaskEditForm({required this.task});

  @override
  _TaskEditFormState createState() => _TaskEditFormState();
}

class _TaskEditFormState extends State<TaskEditForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late int _priority;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _isCompleted = widget.task.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _priority,
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 1, child: Text('Low')),
                      DropdownMenuItem(value: 2, child: Text('Medium')),
                      DropdownMenuItem(value: 3, child: Text('High')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _priority = value ?? 2;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _dueDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('Completed'),
              value: _isCompleted,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value ?? false;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _updateTask,
                  child: Text('Save Changes'),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _updateTask() async {
    if (_formKey.currentState!.validate()) {
      final updatedTask = Task(
        id: widget.task.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: _isCompleted,
        userId: widget.task.userId,
      );

      try {
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(updatedTask.id)
            .update(updatedTask.toMap());
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 