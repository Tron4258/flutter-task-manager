import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'task_card.dart';
import '../services/notification_service.dart';

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
                  child: _buildPriorityField(),
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
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
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
        
        await NotificationService.instance.scheduleTaskReminder(task);
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPriorityField() {
    return FormField<int>(
      initialValue: _priority,
      validator: (value) => value == null ? 'Priority is required' : null,
      builder: (FormFieldState<int> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 1, label: Text('Low'), icon: Icon(Icons.low_priority)),
                ButtonSegment(value: 2, label: Text('Medium'), icon: Icon(Icons.pending)),
                ButtonSegment(value: 3, label: Text('High'), icon: Icon(Icons.priority_high)),
              ],
              selected: {_priority},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() => _priority = newSelection.first);
              },
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(state.errorText!, style: TextStyle(color: Colors.red)),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 