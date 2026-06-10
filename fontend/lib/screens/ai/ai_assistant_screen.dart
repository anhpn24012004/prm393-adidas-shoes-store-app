import 'package:flutter/material.dart';
import '../../models/ai_recommendation_model.dart';
import '../../services/ai_assistant_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _formKey = GlobalKey<FormState>();

  final _footLengthController = TextEditingController();
  final _budgetController = TextEditingController();
  final _favoriteColorController = TextEditingController();

  final _aiService = AiAssistantService();

  String _gender = 'Nam';
  String _footWidth = 'Bình thường';
  String _purpose = 'Chạy bộ';

  bool _isLoading = false;
  AiRecommendationResponse? _result;

  @override
  void dispose() {
    _footLengthController.dispose();
    _budgetController.dispose();
    _favoriteColorController.dispose();
    super.dispose();
  }

  Future<void> _submitRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final request = AiRecommendationRequest(
        gender: _gender,
        footLengthCm: double.parse(_footLengthController.text),
        footWidth: _footWidth,
        purpose: _purpose,
        budget: double.parse(_budgetController.text),
        favoriteColor: _favoriteColorController.text.trim(),
      );

      final response = await _aiService.getRecommendation(request);

      setState(() {
        _result = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Shoe Assistant'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: _inputDecoration('Giới tính'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Nam',
                            child: Text('Nam'),
                          ),
                          DropdownMenuItem(
                            value: 'Nữ',
                            child: Text('Nữ'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _gender = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _footLengthController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          'Chiều dài bàn chân (cm)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập chiều dài bàn chân';
                          }

                          final number = double.tryParse(value);
                          if (number == null || number <= 0) {
                            return 'Chiều dài bàn chân không hợp lệ';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _footWidth,
                        decoration: _inputDecoration('Độ rộng bàn chân'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Hẹp',
                            child: Text('Hẹp'),
                          ),
                          DropdownMenuItem(
                            value: 'Bình thường',
                            child: Text('Bình thường'),
                          ),
                          DropdownMenuItem(
                            value: 'Rộng',
                            child: Text('Rộng'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _footWidth = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _purpose,
                        decoration: _inputDecoration('Mục đích sử dụng'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Chạy bộ',
                            child: Text('Chạy bộ'),
                          ),
                          DropdownMenuItem(
                            value: 'Đi học',
                            child: Text('Đi học'),
                          ),
                          DropdownMenuItem(
                            value: 'Tập gym',
                            child: Text('Tập gym'),
                          ),
                          DropdownMenuItem(
                            value: 'Thời trang',
                            child: Text('Thời trang'),
                          ),
                          DropdownMenuItem(
                            value: 'Đá bóng',
                            child: Text('Đá bóng'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _purpose = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Ngân sách (VND)'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập ngân sách';
                          }

                          final number = double.tryParse(value);
                          if (number == null || number <= 0) {
                            return 'Ngân sách không hợp lệ';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _favoriteColorController,
                        decoration: _inputDecoration('Màu sắc yêu thích'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập màu sắc yêu thích';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed:
                          _isLoading ? null : _submitRecommendation,
                          icon: _isLoading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            _isLoading
                                ? 'Đang tư vấn...'
                                : 'Nhận tư vấn AI',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_result != null)
              Card(
                color: Colors.grey.shade100,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kết quả tư vấn',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Size đề xuất: ${_result!.recommendedSize}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _result!.advice,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}