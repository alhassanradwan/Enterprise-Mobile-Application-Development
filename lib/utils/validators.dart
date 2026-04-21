class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? universityEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'University email is required';
    }

    final normalized = value.trim();
    final emailRegex = RegExp(r'^\d+@stud\.fci-cu\.edu\.eg$');
    if (!emailRegex.hasMatch(normalized)) {
      return 'Use format: studentID@stud.fci-cu.edu.eg';
    }
    return null;
  }

  static String? studentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student ID is required';
    }

    final studentIdRegex = RegExp(r'^\d{8}$');
    if (!studentIdRegex.hasMatch(value.trim())) {
      return 'Student ID must be 8 digits';
    }
    return null;
  }

  static String? emailStudentIdMatch({
    required String? email,
    required String? studentId,
  }) {
    if (email == null || studentId == null) {
      return null;
    }

    final normalizedEmail = email.trim();
    final normalizedId = studentId.trim();
    if (normalizedEmail.isEmpty || normalizedId.isEmpty) {
      return null;
    }

    final emailLocalPart = normalizedEmail.split('@').first;
    if (emailLocalPart != normalizedId) {
      return 'Email and Student ID must match';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    final containsNumber = RegExp(r'\d').hasMatch(value);
    if (!containsNumber) {
      return 'Password must include at least one number';
    }

    return null;
  }

  static String? confirmPassword({
    required String? password,
    required String? confirmPassword,
  }) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
