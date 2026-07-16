import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import 'admin_category_form_screen.dart';

class AdminCategoryListScreen extends StatefulWidget {
  const AdminCategoryListScreen({super.key});

  @override
  State<AdminCategoryListScreen> createState() =>
      _AdminCategoryListScreenState();
}

class _AdminCategoryListScreenState extends State<AdminCategoryListScreen> {
  final CategoryService _categoryService = CategoryService();

  late Future<List<CategoryModel>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _categoriesFuture = _categoryService.getCategories();
  }

  Future<void> _goToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminCategoryFormScreen()),
    );

    if (result == true) {
      setState(() {
        _loadCategories();
      });
    }
  }

  Future<void> _goToEdit(CategoryModel category) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminCategoryFormScreen(category: category),
      ),
    );

    if (result == true) {
      setState(() {
        _loadCategories();
      });
    }
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('deleteCategory')),
          content: Text(
            '${context.tr('deleteCategoryQuestion')} "${category.categoryName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr('delete')),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _categoryService.deleteCategory(category.categoryId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('categoryDeleted'))));

      setState(() {
        _loadCategories();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${context.tr('error')}: $e')));
    }
  }

  Widget _buildCategoryItem(CategoryModel category) {
    return Card(
      child: ListTile(
        title: Text(
          category.categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${category.description ?? context.tr('noDescription')}\n${context.tr('metricProducts')}: ${category.productCount}',
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _goToEdit(category),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteCategory(category),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<CategoryModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${context.tr('error')}: ${snapshot.error}'),
            ),
          );
        }

        final categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return Center(child: Text(context.tr('noCategories')));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryItem(categories[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('categoryManagement'))),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}
