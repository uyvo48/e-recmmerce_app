import 'package:flutter/material.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;
  final String? initialTitle;
  final double? initialPrice;
  final String? initialDescription;

  const ProductFormScreen({
    super.key,
    this.productId,
    this.initialTitle,
    this.initialPrice,
    this.initialDescription,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  final _categoryIdController = TextEditingController(text: '1');
  final _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _priceController = TextEditingController(
      text: widget.initialPrice?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryIdController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'title': _titleController.text,
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
        'categoryId': int.parse(_categoryIdController.text),
        'images': [_imageUrlController.text],
      };
      Navigator.pop(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Sua san pham' : 'Them san pham'),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Ten san pham',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty == true ? 'Nhap ten' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Gia',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty == true) return 'Nhap gia';
                if (double.tryParse(v!) == null) return 'Gia phai la so';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mo ta',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (v) => v?.isEmpty == true ? 'Nhap mo ta' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryIdController,
              decoration: const InputDecoration(
                labelText: 'Category ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty == true) return 'Nhap category ID';
                if (int.tryParse(v!) == null) return 'Phai la so nguyen';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty == true ? 'Nhap image URL' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEdit ? 'Cap nhat' : 'Tao san pham'),
            ),
          ],
        ),
      ),
    );
  }
}
