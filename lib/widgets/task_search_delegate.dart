import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'task_card.dart';
import 'task_edit_form.dart';
import '../models/task_category.dart';

enum SortOption {
  dueDate,
  priority,
  title,
  status
}

void _logError(String operation, dynamic error, StackTrace? stackTrace) {
  print('🔥 Firebase Error:');
  print('Operation: $operation');
  print('Error: $error');
  if (stackTrace != null) {
    print('Stack trace:');
    print(stackTrace);
  }
  print('------------------------');
}

class TaskSearchDelegate extends SearchDelegate {
  final String userId;
  SortOption _currentSort = SortOption.dueDate;
  String? _selectedCategoryId;

  TaskSearchDelegate({required this.userId});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.category),
        onPressed: () => _showCategoryFilter(context),
      ),
      IconButton(
        icon: Icon(Icons.sort),
        onPressed: () => _showSortOptions(context),
      ),
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  void _showSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sort Tasks By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption(context, SortOption.dueDate, 'Due Date'),
            _buildSortOption(context, SortOption.priority, 'Priority'),
            _buildSortOption(context, SortOption.title, 'Title'),
            _buildSortOption(context, SortOption.status, 'Status'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, SortOption option, String title) {
    return ListTile(
      leading: Radio<SortOption>(
        value: option,
        groupValue: _currentSort,
        onChanged: (SortOption? value) {
          if (value != null) {
            _currentSort = value;
            Navigator.pop(context);
            query = query;
          }
        },
      ),
      title: Text(title),
      onTap: () {
        _currentSort = option;
        Navigator.pop(context);
        query = query;
      },
    );
  }

  void _showCategoryFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!.docs
              .map((doc) => TaskCategory.fromMap({
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  }))
              .toList();

          return AlertDialog(
            title: Text('Filter by Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('All Categories'),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: _selectedCategoryId,
                    onChanged: (value) {
                      _selectedCategoryId = value;
                      Navigator.pop(context);
                      query = query;
                    },
                  ),
                ),
                ...categories.map((category) => ListTile(
                      title: Text(category.name),
                      leading: Radio<String?>(
                        value: category.id,
                        groupValue: _selectedCategoryId,
                        onChanged: (value) {
                          _selectedCategoryId = value;
                          Navigator.pop(context);
                          query = query;
                        },
                      ),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
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
    if (query.isEmpty) {
      return Column(
        children: [
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Recent Searches'),
          ),
          FutureBuilder<List<String>>(
            future: _getRecentSearches(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No recent searches');
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index]),
                    onTap: () {
                      query = snapshot.data![index];
                      close(context, query);
                    },
                  );
                },
              );
            },
          ),
        ],
      );
    }
    return _buildTaskList();
  }

  Widget _buildTaskList() {
    print('📋 Building task list for user: $userId');

    return StreamBuilder<QuerySnapshot>(
      stream: _getSortedTasksStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          _logError('StreamBuilder', snapshot.error, snapshot.stackTrace);
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        print('Snapshot has data: ${snapshot.hasData}');
        print('Documents count: ${snapshot.data?.docs.length}');

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('ℹ️ No tasks found for user: $userId');
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

        print('📊 Found ${snapshot.data?.docs.length} tasks');
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
              onTap: () {
                if (Theme.of(context).platform == TargetPlatform.android || 
                    Theme.of(context).platform == TargetPlatform.iOS) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => TaskEditForm(task: task),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: Container(
                        width: 600,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.8,
                        ),
                        child: TaskEditForm(task: task),
                      ),
                    ),
                  );
                }
              },
              onDelete: () => _showDeleteConfirmation(context, task),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getSortedTasksStream() {
    print('🔄 Getting sorted tasks stream with sort option: $_currentSort');
    try {
      var baseQuery = FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId);

      // Add category filter if selected
      if (_selectedCategoryId != null) {
        baseQuery = baseQuery.where('categoryId', isEqualTo: _selectedCategoryId);
      }

      // Add search filter if search query is not empty
      if (query.isNotEmpty) {
        final searchTerms = query.toLowerCase().split(' ')
            .where((term) => term.isNotEmpty)
            .toList();
        if (searchTerms.isNotEmpty) {
          baseQuery = baseQuery.where('searchableText', arrayContainsAny: searchTerms);
        }
      }

      // Add sorting
      switch (_currentSort) {
        case SortOption.dueDate:
          print('📅 Sorting by due date');
          return baseQuery.orderBy('dueDate', descending: false).snapshots();
        case SortOption.priority:
          print('⚡ Sorting by priority');
          return baseQuery.orderBy('priority', descending: true).snapshots();
        case SortOption.title:
          print('📝 Sorting by title');
          return baseQuery.orderBy('title', descending: false).snapshots();
        case SortOption.status:
          print('✓ Sorting by status');
          return baseQuery
              .orderBy('isCompleted', descending: false)
              .orderBy('dueDate', descending: false)
              .snapshots();
      }
    } catch (e, stackTrace) {
      _logError('Sort Tasks Stream', e, stackTrace);
      return FirebaseFirestore.instance
          .collection('tasks')
          .where('id', isEqualTo: 'none')
          .snapshots();
    }
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

  void _showDeleteConfirmation(BuildContext context, Task task) {
    print('🗑️ Showing delete confirmation for task: ${task.id}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () {
              print('❌ Delete cancelled for task: ${task.id}');
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                print('🗑️ Deleting task: ${task.id}');
                await FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(task.id)
                    .delete();
                
                print('✅ Task deleted successfully');
                Navigator.pop(context);
                _showSuccessSnackBar(context, 'Task deleted successfully');
              } catch (e, stackTrace) {
                _logError('Delete Task', e, stackTrace);
                Navigator.pop(context);
                _showErrorSnackBar(context, 'Error deleting task: $e');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recent_searches') ?? [];
      print('📜 Retrieved recent searches: $searches');
      return searches;
    } catch (e, stackTrace) {
      _logError('Get Recent Searches', e, stackTrace);
      return []; // Return empty list on error
    }
  }

  // Add method to save searches
  Future<void> _saveSearch(String query) async {
    if (query.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recent_searches') ?? [];
      
      // Remove if exists and add to front
      searches.remove(query);
      searches.insert(0, query);
      
      // Keep only last 5 searches
      if (searches.length > 5) {
        searches.removeLast();
      }
      
      await prefs.setStringList('recent_searches', searches);
      print('💾 Saved search query: $query');
    } catch (e, stackTrace) {
      _logError('Save Recent Search', e, stackTrace);
    }
  }
} 