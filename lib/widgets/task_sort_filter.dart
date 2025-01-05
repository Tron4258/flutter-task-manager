class TaskSortFilter extends StatelessWidget {
  final List<SortOption> sortOptions = [
    SortOption(
      id: 'dueDate',
      label: 'Due Date',
      icon: Icons.calendar_today,
      comparator: (a, b) => a.dueDate.compareTo(b.dueDate),
    ),
    SortOption(
      id: 'priority',
      label: 'Priority',
      icon: Icons.priority_high,
      comparator: (a, b) => b.priority.compareTo(a.priority),
    ),
    // ... more sort options
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      icon: Icon(Icons.sort),
      itemBuilder: (context) => sortOptions
          .map((option) => PopupMenuItem(
                value: option,
                child: ListTile(
                  leading: Icon(option.icon),
                  title: Text(option.label),
                ),
              ))
          .toList(),
      onSelected: (option) {
        // Handle sort selection
      },
    );
  }
} 