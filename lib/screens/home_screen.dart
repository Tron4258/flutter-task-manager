import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';
import '../widgets/task_search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Complete Task Manager App',
      description: 'Implement core features of the task manager',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: 3,
    ),
    Task(
      id: '2',
      title: 'Add Firebase Integration',
      description: 'Set up Firebase for data persistence',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      priority: 2,
    ),
  ];

  List<Task> _filteredTasks = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredTasks = _tasks;
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Add New Task',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TaskForm(task: null),
              ],
            ),
          ),
        );
      },
    ).then((newTask) {
      if (newTask != null) {
        setState(() {
          _tasks.add(newTask);
          _filterTasks();
        });
      }
    });
  }

  void _showEditTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Edit Task',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TaskForm(task: task),
              ],
            ),
          ),
        );
      },
    ).then((updatedTask) {
      if (updatedTask != null) {
        setState(() {
          final index = _tasks.indexWhere((t) => t.id == task.id);
          _tasks[index] = updatedTask;
          _filterTasks();
        });
      }
    });
  }

  void _filterTasks() {
    if (_searchQuery.isEmpty) {
      _filteredTasks = _tasks;
    } else {
      _filteredTasks = _tasks.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedPriority = 0; // 0 means no filter
        return AlertDialog(
          title: const Text('Filter by Priority'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                title: const Text('All'),
                value: 0,
                groupValue: selectedPriority,
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text('Low'),
                value: 1,
                groupValue: selectedPriority,
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text('Medium'),
                value: 2,
                groupValue: selectedPriority,
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text('High'),
                value: 3,
                groupValue: selectedPriority,
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _filterTasksByPriority(selectedPriority);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _filterTasksByPriority(int priority) {
    if (priority == 0) {
      _filteredTasks = _tasks;
    } else {
      _filteredTasks = _tasks.where((task) => task.priority == priority).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(_tasks, (query) {
                  setState(() {
                    _searchQuery = query;
                    _filterTasks();
                  });
                }),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredTasks.length,
        itemBuilder: (context, index) {
          return TaskCard(
            task: _filteredTasks[index],
            onTap: () => _showEditTaskDialog(_filteredTasks[index]),
            onComplete: () {
              setState(() {
                final taskIndex = _tasks.indexWhere((t) => t.id == _filteredTasks[index].id);
                _tasks[taskIndex] = _tasks[taskIndex].copyWith(
                  isCompleted: !_tasks[taskIndex].isCompleted,
                );
                _filterTasks();
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
