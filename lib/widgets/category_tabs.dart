import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onSelectCategory;

  const CategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          _buildCategoryTab('Hepsi', 'Hepsi'),
          _buildCategoryTab('Yemek', 'Yemek'),
          _buildCategoryTab('İçecek', 'İçecek'),
          _buildCategoryTab('Atıştırmalık', 'Atıştırmalık'),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title, String category) {
    final isSelected = selectedCategory == category;
    
    return GestureDetector(
      onTap: () => onSelectCategory(category),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected 
                  ? const Color(0xFF2D4599) 
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2D4599) : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
