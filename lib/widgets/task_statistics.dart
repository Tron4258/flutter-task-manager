class TaskStatistics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final tasks = snapshot.data!.docs
            .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return Column(
          children: [
            _buildCompletionChart(tasks),
            _buildPriorityDistribution(tasks),
            _buildCategoryBreakdown(tasks),
            _buildOverdueStatus(tasks),
          ],
        );
      },
    );
  }
} 