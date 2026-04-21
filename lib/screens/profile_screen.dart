import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../db/database_helper.dart';
import '../models/user_model.dart';
import '../utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _db = DatabaseHelper.instance;
  final _picker = ImagePicker();

  String? _gender;
  String? _academicLevel;
  String? _imagePath;
  bool _isLoading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.user.fullName;
    _emailController.text = widget.user.email;
    _studentIdController.text = widget.user.studentId;
    _gender = widget.user.gender;
    _academicLevel = widget.user.academicLevel;
    _imagePath = widget.user.profileImagePath;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked == null) return;

    setState(() => _imagePath = picked.path);
  }

  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final studentId = _studentIdController.text.trim();

    final emailTaken = await _db.isEmailTaken(email, excludingUserId: widget.user.id);
    if (!mounted) return;
    if (emailTaken) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This email is already used by another user')),
      );
      return;
    }

    final studentIdTaken =
        await _db.isStudentIdTaken(studentId, excludingUserId: widget.user.id);
    if (!mounted) return;
    if (studentIdTaken) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This student ID is already used by another user'),
        ),
      );
      return;
    }

    final newPassword = _passwordController.text.trim().isEmpty
        ? widget.user.password
        : _passwordController.text;

    final updatedUser = widget.user.copyWith(
      fullName: _fullNameController.text.trim(),
      gender: _gender,
      email: email,
      studentId: studentId,
      academicLevel: _academicLevel,
      password: newPassword,
      profileImagePath: _imagePath,
    );

    await _db.updateUser(updatedUser);

    if (!mounted) return;

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );

    Navigator.of(context).pop(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imagePath != null && File(_imagePath!).existsSync();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage:
                              hasImage ? FileImage(File(_imagePath!)) : null,
                          child: hasImage
                              ? null
                              : const Icon(Icons.person, size: 48),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _showImageSourceSheet,
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Change Photo'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) =>
                        Validators.requiredField(value, 'Full name'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Gender (optional)'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Male'),
                          value: 'Male',
                          groupValue: _gender,
                          onChanged: (value) => setState(() => _gender = value),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Female'),
                          value: 'Female',
                          groupValue: _gender,
                          onChanged: (value) => setState(() => _gender = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'University Email'),
                    validator: (value) {
                      final emailError = Validators.universityEmail(value);
                      if (emailError != null) return emailError;

                      return Validators.emailStudentIdMatch(
                        email: value,
                        studentId: _studentIdController.text,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _studentIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Student ID'),
                    validator: (value) {
                      final idError = Validators.studentId(value);
                      if (idError != null) return idError;

                      return Validators.emailStudentIdMatch(
                        email: _emailController.text,
                        studentId: value,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _academicLevel,
                    decoration: const InputDecoration(
                      labelText: 'Academic Level (optional)',
                    ),
                    items: const [
                      DropdownMenuItem(value: '1', child: Text('1')),
                      DropdownMenuItem(value: '2', child: Text('2')),
                      DropdownMenuItem(value: '3', child: Text('3')),
                      DropdownMenuItem(value: '4', child: Text('4')),
                    ],
                    onChanged: (value) => setState(() => _academicLevel = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: 'New Password (optional)',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _hidePassword = !_hidePassword);
                        },
                        icon: Icon(
                          _hidePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      return Validators.password(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _hideConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hideConfirmPassword = !_hideConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _hideConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (_passwordController.text.isEmpty &&
                          (value == null || value.isEmpty)) {
                        return null;
                      }
                      return Validators.confirmPassword(
                        password: _passwordController.text,
                        confirmPassword: value,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Profile'),
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
