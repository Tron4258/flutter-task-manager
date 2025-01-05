class CategoryManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        return Column(
          children: [
            _buildCategoryList(snapshot.data?.docs ?? []),
            _buildAddCategoryButton(context),
          ],
        );
      },
    );
  }

  Widget _buildColorPicker(BuildContext context, Color initialColor) {
    return BlockPicker(
      pickerColor: initialColor,
      onColorChanged: (color) {
        // Handle color selection
      },
    );
  }
} 