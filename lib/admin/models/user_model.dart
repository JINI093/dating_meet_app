/// 사용자 모델 (관리자용)
class UserModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phoneNumber;
  final String email;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final String location;
  final String? job;
  final bool isVip;
  final bool isPhoneVerified;
  final bool isJobVerified;
  final bool isPhotoVerified;
  final int activityScore;
  final int receivedLikes;
  final int sentLikes;
  final int successfulMatches;
  final UserStatus status;
  final String? profileImage;
  final List<String> profileImages;
  final String? bio;
  final int? height;
  final String? bodyType;
  final String? education;
  final String? smoking;
  final String? drinking;
  final String? religion;
  final String? mbti;
  final List<String> hobbies;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.email,
    required this.createdAt,
    required this.lastLoginAt,
    required this.location,
    this.job,
    this.isVip = false,
    this.isPhoneVerified = false,
    this.isJobVerified = false,
    this.isPhotoVerified = false,
    this.activityScore = 0,
    this.receivedLikes = 0,
    this.sentLikes = 0,
    this.successfulMatches = 0,
    this.status = UserStatus.active,
    this.profileImage,
    this.profileImages = const [],
    this.bio,
    this.height,
    this.bodyType,
    this.education,
    this.smoking,
    this.drinking,
    this.religion,
    this.mbti,
    this.hobbies = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      location: json['location'] as String,
      job: json['job'] as String?,
      isVip: json['isVip'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      isJobVerified: json['isJobVerified'] as bool? ?? false,
      isPhotoVerified: json['isPhotoVerified'] as bool? ?? false,
      activityScore: json['activityScore'] as int? ?? 0,
      receivedLikes: json['receivedLikes'] as int? ?? 0,
      sentLikes: json['sentLikes'] as int? ?? 0,
      successfulMatches: json['successfulMatches'] as int? ?? 0,
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      profileImage: json['profileImage'] as String?,
      profileImages: List<String>.from(json['profileImages'] ?? []),
      bio: json['bio'] as String?,
      height: json['height'] as int?,
      bodyType: json['bodyType'] as String?,
      education: json['education'] as String?,
      smoking: json['smoking'] as String?,
      drinking: json['drinking'] as String?,
      religion: json['religion'] as String?,
      mbti: json['mbti'] as String?,
      hobbies: List<String>.from(json['hobbies'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'location': location,
      'job': job,
      'isVip': isVip,
      'isPhoneVerified': isPhoneVerified,
      'isJobVerified': isJobVerified,
      'isPhotoVerified': isPhotoVerified,
      'activityScore': activityScore,
      'receivedLikes': receivedLikes,
      'sentLikes': sentLikes,
      'successfulMatches': successfulMatches,
      'status': status.name,
      'profileImage': profileImage,
      'profileImages': profileImages,
      'bio': bio,
      'height': height,
      'bodyType': bodyType,
      'education': education,
      'smoking': smoking,
      'drinking': drinking,
      'religion': religion,
      'mbti': mbti,
      'hobbies': hobbies,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? phoneNumber,
    String? email,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? location,
    String? job,
    bool? isVip,
    bool? isPhoneVerified,
    bool? isJobVerified,
    bool? isPhotoVerified,
    int? activityScore,
    int? receivedLikes,
    int? sentLikes,
    int? successfulMatches,
    UserStatus? status,
    String? profileImage,
    List<String>? profileImages,
    String? bio,
    int? height,
    String? bodyType,
    String? education,
    String? smoking,
    String? drinking,
    String? religion,
    String? mbti,
    List<String>? hobbies,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      location: location ?? this.location,
      job: job ?? this.job,
      isVip: isVip ?? this.isVip,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isJobVerified: isJobVerified ?? this.isJobVerified,
      isPhotoVerified: isPhotoVerified ?? this.isPhotoVerified,
      activityScore: activityScore ?? this.activityScore,
      receivedLikes: receivedLikes ?? this.receivedLikes,
      sentLikes: sentLikes ?? this.sentLikes,
      successfulMatches: successfulMatches ?? this.successfulMatches,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      profileImages: profileImages ?? this.profileImages,
      bio: bio ?? this.bio,
      height: height ?? this.height,
      bodyType: bodyType ?? this.bodyType,
      education: education ?? this.education,
      smoking: smoking ?? this.smoking,
      drinking: drinking ?? this.drinking,
      religion: religion ?? this.religion,
      mbti: mbti ?? this.mbti,
      hobbies: hobbies ?? this.hobbies,
    );
  }
}

/// 사용자 상태
enum UserStatus {
  active('활성'),
  suspended('정지'),
  deleted('탈퇴');

  final String displayName;
  const UserStatus(this.displayName);
}