class UserModel {
  final int? id;
  final String fullName;
  final String? gender;
  final String email;
  final String studentId;
  final String? academicLevel;
  final String password;
  final String? profileImagePath;

  const UserModel({
    this.id,
    required this.fullName,
    this.gender,
    required this.email,
    required this.studentId,
    this.academicLevel,
    required this.password,
    this.profileImagePath,
  });

  UserModel copyWith({
    int? id,
    String? fullName,
    String? gender,
    String? email,
    String? studentId,
    String? academicLevel,
    String? password,
    String? profileImagePath,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      academicLevel: academicLevel ?? this.academicLevel,
      password: password ?? this.password,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'gender': gender,
      'email': email,
      'studentId': studentId,
      'academicLevel': academicLevel,
      'password': password,
      'profileImagePath': profileImagePath,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      fullName: map['fullName'] as String,
      gender: map['gender'] as String?,
      email: map['email'] as String,
      studentId: map['studentId'] as String,
      academicLevel: map['academicLevel'] as String?,
      password: map['password'] as String,
      profileImagePath: map['profileImagePath'] as String?,
    );
  }
}
