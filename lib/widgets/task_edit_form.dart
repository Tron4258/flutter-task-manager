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
  bool _isSubmitting = false;

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
    final isWeb = Theme.of(context).platform != TargetPlatform.android && 
                  Theme.of(context).platform != TargetPlatform.iOS;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isWeb ? 16 : MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWeb) 
            Row(
              children: [
                Text(
                  'Edit Task',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          if (isWeb) Divider(),
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                      errorMaxLines: 2,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task title';
                      }
                      if (value.length < 3) {
                        return 'Title must be at least 3 characters long';
                      }
                      if (value.length > 50) {
                        return 'Title must not exceed 50 characters';
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      errorMaxLines: 2,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value != null && value.length > 500) {
                        return 'Description must not exceed 500 characters';
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
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
                          onChanged: _isSubmitting ? null : (value) {
                            setState(() {
                              _priority = value ?? 2;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a priority';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _isSubmitting ? null : () async {
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
                              errorText: _dueDate.isBefore(DateTime.now()) ? 'Due date cannot be in the past' : null,
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
                    onChanged: _isSubmitting ? null : (value) {
                      setState(() {
                        _isCompleted = value ?? false;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.delete, color: Colors.red),
                        label: Text('Delete', style: TextStyle(color: Colors.red)),
                        onPressed: _isSubmitting ? null : () {
                          _showDeleteConfirmation(context);
                        },
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _updateTask,
                        child: _isSubmitting 
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dueDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Due date cannot be in the past')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updatedTask = Task(
        id: widget.task.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: _isCompleted,
        userId: widget.task.userId,
      );

      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(updatedTask.id)
          .update(updatedTask.toMap());
      
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Task updated successfully');
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackBar(context, 'Error updating task: $e');
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              setState(() {
                _isSubmitting = true;
              });

              try {
                await FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(widget.task.id)
                    .delete();
                
                Navigator.pop(context); // Close edit form
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Task deleted successfully')),
                );
              } catch (e) {
                setState(() {
                  _isSubmitting = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting task: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 