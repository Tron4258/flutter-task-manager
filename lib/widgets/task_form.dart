import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'task_card.dart';

class TaskForm extends StatefulWidget {
  final String userId;

  TaskForm({required this.userId});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  int _priority = 2;

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
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Add Task'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: false,
        userId: widget.userId,
      );

      try {
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(task.id)
            .set(task.toMap());
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $e')),
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