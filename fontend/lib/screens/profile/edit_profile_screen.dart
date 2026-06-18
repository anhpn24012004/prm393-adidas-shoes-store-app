import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../models/auth_model.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  UserProfile? _profile;
  String? _gender;
  DateTime? _dateOfBirth;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _fullNameController.text = profile.fullName;
        _emailController.text = profile.email;
        _phoneController.text = profile.phone ?? '';
        _gender = _normalizeGender(profile.gender);
        _dateOfBirth = profile.dateOfBirth;
      });
    } catch (error) {
      if (mounted) _show(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selected == null) return;

    setState(() => _dateOfBirth = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await _authService.updateProfile(
        fullName: _fullNameController.text.trim(),
        email: _profile!.email,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        gender: _gender,
        dateOfBirth: _dateOfBirth,
      );

      if (!mounted) return;

      _show(context.tr('profileUpdated'));
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _show(error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(Object message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString().replaceFirst('Exception: ', '')),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return context.tr('selectDateOfBirth');

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year.toString().padLeft(4, '0')}';
  }

  String? _normalizeGender(String? gender) {
    final value = gender?.trim().toLowerCase();

    return switch (value) {
      'nam' || 'male' => 'Nam',
      'nữ' || 'nu' || 'female' => 'Nữ',
      'khác' || 'khac' || 'other' => 'Khác',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('editProfile'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? Center(child: Text(context.tr('signInToContinue')))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              labelText: context.tr('fullName'),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              return value == null || value.trim().isEmpty
                                  ? context.tr('fullNameRequired')
                                  : null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            enabled: false,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: context.tr('emailAddress'),
                              helperText: context.tr('emailCannotBeChanged'),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: context.tr('phoneNumber'),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final phone = value?.trim() ?? '';
                              if (phone.isEmpty) return null;

                              final digits = phone.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              );

                              return digits.length < 8
                                  ? context.tr('invalidPhone')
                                  : null;
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: InputDecoration(
                              labelText: context.tr('gender'),
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'Nam',
                                child: Text(context.tr('male')),
                              ),
                              DropdownMenuItem(
                                value: 'Nữ',
                                child: Text(context.tr('female')),
                              ),
                              DropdownMenuItem(
                                value: 'Khác',
                                child: Text(context.tr('other')),
                              ),
                            ],
                            onChanged: _saving
                                ? null
                                : (value) => setState(() => _gender = value),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: _saving ? null : _pickDateOfBirth,
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: Text(_formatDate(_dateOfBirth)),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _save,
                              child: Text(
                                (_saving
                                        ? context.tr('saving')
                                        : context.tr('saveProfile'))
                                    .toUpperCase(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
