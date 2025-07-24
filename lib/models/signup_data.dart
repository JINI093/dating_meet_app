class SignupData {
  final String username;
  final String password;
  final String email;
  final String? phoneNumber;
  final String? name;
  final DateTime? birthDate;
  final String? gender;
  final Map<String, dynamic>? additionalInfo;

  const SignupData({
    required this.username,
    required this.password,
    required this.email,
    this.phoneNumber,
    this.name,
    this.birthDate,
    this.gender,
    this.additionalInfo,
  });

  SignupData copyWith({
    String? username,
    String? password,
    String? email,
    String? phoneNumber,
    String? name,
    DateTime? birthDate,
    String? gender,
    Map<String, dynamic>? additionalInfo,
  }) {
    return SignupData(
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'phoneNumber': phoneNumber,
      'name': name,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'additionalInfo': additionalInfo,
    };
  }

  factory SignupData.fromJson(Map<String, dynamic> json) {
    return SignupData(
      username: json['username'] as String,
      password: json['password'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      name: json['name'] as String?,
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      gender: json['gender'] as String?,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'SignupData(username: $username, email: $email, name: $name)';
  }
}