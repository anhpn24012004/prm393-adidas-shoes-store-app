import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';

class AdminCategoryFormScreen extends StatefulWidget {
  final CategoryModel? category;

  const AdminCategoryFormScreen({super.key, this.category});

  @override
  State<AdminCategoryFormScreen> createState() =>
      _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState extends State<AdminCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final CategoryService _categoryService = CategoryService();

  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  bool get isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();

    final category = widget.category;

    if (category != null) {
      _categoryNameController.text = category.categoryName;
      _descriptionController.text = category.description ?? '';
    }
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final categoryName = _categoryNameController.text.trim();
      final description = _descriptionController.text.trim();

      if (isEditMode) {
        await _categoryService.updateCategory(
          categoryId: widget.category!.categoryId,
          categoryName: categoryName,
          description: description,
        );
      } else {
        await _categoryService.createCategory(
          categoryName: categoryName,
          description: description,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? context.tr('categoryUpdated')
                : context.tr('categoryCreated'),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${context.tr('error')}: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditMode
        ? context.tr('editCategory')
        : context.tr('createCategory');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(
                      labelText: context.tr('categoryName'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.tr('requiredField');
                      }

                      if (value.trim().length > 100) {
                        return context.tr('categoryNameTooLong');
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: context.tr('productDescription'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != null && value.length > 255) {
                        return context.tr('descriptionTooLong');
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : Text(
                              isEditMode
                                  ? context.tr('updateCategory')
                                  : context.tr('createCategory'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
