import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  final String id;
  final String name;
  final int age;
  final String location;
  final List<String> profileImages;
  final String? bio;
  final String? occupation;
  final String? education;
  final int? height;
  final String? bodyType;
  final String? smoking;
  final String? drinking;
  final String? religion;
  final String? mbti;
  final List<String> hobbies;
  final List<String> badges;
  final bool isVip;
  final bool isPremium;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeen;
  final double? distance;
  final int likeCount;
  final int superChatCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? gender;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.age,
    required this.location,
    required this.profileImages,
    this.bio,
    this.occupation,
    this.education,
    this.height,
    this.bodyType,
    this.smoking,
    this.drinking,
    this.religion,
    this.mbti,
    this.hobbies = const [],
    this.badges = const [],
    this.isVip = false,
    this.isPremium = false,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeen,
    this.distance,
    this.likeCount = 0,
    this.superChatCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.gender,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  factory ProfileModel.empty() => ProfileModel(
    id: '',
    name: 'Unknown',
    age: 0,
    location: '',
    profileImages: [],
    gender: null, // 성별 정보 추가
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  ProfileModel copyWith({
    String? id,
    String? name,
    int? age,
    String? location,
    List<String>? profileImages,
    String? bio,
    String? occupation,
    String? education,
    int? height,
    String? bodyType,
    String? smoking,
    String? drinking,
    String? religion,
    String? mbti,
    List<String>? hobbies,
    List<String>? badges,
    bool? isVip,
    bool? isPremium,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastSeen,
    double? distance,
    int? likeCount,
    int? superChatCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? gender,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      location: location ?? this.location,
      profileImages: profileImages ?? this.profileImages,
      bio: bio ?? this.bio,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      height: height ?? this.height,
      bodyType: bodyType ?? this.bodyType,
      smoking: smoking ?? this.smoking,
      drinking: drinking ?? this.drinking,
      religion: religion ?? this.religion,
      mbti: mbti ?? this.mbti,
      hobbies: hobbies ?? this.hobbies,
      badges: badges ?? this.badges,
      isVip: isVip ?? this.isVip,
      isPremium: isPremium ?? this.isPremium,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      distance: distance ?? this.distance,
      likeCount: likeCount ?? this.likeCount,
      superChatCount: superChatCount ?? this.superChatCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender ?? this.gender,
    );
  }

  // Helper methods
  String get displayAge => '$age세';
  
  String get displayLocation {
    if (distance != null && distance! < 1) {
      return '${(distance! * 1000).round()}m';
    } else if (distance != null) {
      return '${distance!.round()}km';
    }
    return location;
  }

  String get fullDisplayName => '$name, $displayAge';

  bool get hasMultipleImages => profileImages.length > 1;

  String get primaryImage => profileImages.isNotEmpty 
      ? profileImages.first 
      : '';

  List<String> get displayBadges {
    final List<String> result = [];
    
    if (isVip) result.add('VIP');
    if (isPremium) result.add('PREMIUM');
    if (isVerified) result.add('인증');
    
    // Add ranking badges
    if (badges.contains('1등')) result.add('1등');
    if (badges.contains('인기')) result.add('인기');
    if (badges.contains('신규')) result.add('신규');
    
    return result;
  }

  String get onlineStatus {
    if (isOnline) return '온라인';
    if (lastSeen == null) return '오프라인';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '1주일 이상';
    }
  }

  double get profileCompletionRate {
    int completedFields = 0;
    int totalFields = 12; // 총 프로필 필드 수

    if (profileImages.isNotEmpty) completedFields++;
    if (bio != null && bio!.isNotEmpty) completedFields++;
    if (occupation != null && occupation!.isNotEmpty) completedFields++;
    if (education != null && education!.isNotEmpty) completedFields++;
    if (height != null) completedFields++;
    if (bodyType != null && bodyType!.isNotEmpty) completedFields++;
    if (smoking != null && smoking!.isNotEmpty) completedFields++;
    if (drinking != null && drinking!.isNotEmpty) completedFields++;
    if (religion != null && religion!.isNotEmpty) completedFields++;
    if (mbti != null && mbti!.isNotEmpty) completedFields++;
    if (hobbies.isNotEmpty) completedFields++;
    if (isVerified) completedFields++;

    return completedFields / totalFields;
  }

  bool get isProfileComplete => profileCompletionRate >= 0.8;

  // Static factory methods for mock data
  static ProfileModel createMockProfile({
    required String id,
    required String name,
    required int age,
    required String location,
    List<String>? profileImages,
    bool isVip = false,
    bool isVerified = false,
    List<String>? badges,
    double? distance,
  }) {
    final now = DateTime.now();
    return ProfileModel(
      id: id,
      name: name,
      age: age,
      location: location,
      profileImages: profileImages ?? [
        'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=400',
      ],
      bio: '안녕하세요! 진지한 만남을 찾고 있습니다.',
      occupation: 'IT 개발자',
      education: '대학교 졸업',
      height: 170,
      bodyType: '보통',
      smoking: '비흡연',
      drinking: '가끔',
      religion: '무교',
      mbti: 'INFP',
      hobbies: ['영화감상', '독서', '요리'],
      badges: badges ?? [],
      isVip: isVip,
      isPremium: false,
      isVerified: isVerified,
      isOnline: true,
      lastSeen: now.subtract(const Duration(minutes: 5)),
      distance: distance,
      likeCount: 45,
      superChatCount: 12,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now,
    );
  }

  static List<ProfileModel> getMockProfiles() {
    return [
      createMockProfile(
        id: '9',
        name: '소영',
        age: 29,
        location: '서울 강남구',
        isVip: false,
        isVerified: true,
        badges: ['인기'],
        distance: 2.1,
        profileImages: [
          'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=400',
        ],
      ),
      createMockProfile(
        id: '2',
        name: '지은',
        age: 31,
        location: '서울 강남구',
        isVip: false,
        isVerified: true,
        badges: ['인기'],
        distance: 5.2,
        profileImages: [
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
        ],
      ),
      createMockProfile(
        id: '3',
        name: '민지',
        age: 28,
        location: '서울 서초구',
        isVip: true,
        isVerified: false,
        badges: ['신규'],
        distance: 3.8,
        profileImages: [
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
        ],
      ),
      createMockProfile(
        id: '4',
        name: '수진',
        age: 33,
        location: '인천 남동구',
        isVip: false,
        isVerified: true,
        badges: [],
        distance: 12.5,
        profileImages: [
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
        ],
      ),
      createMockProfile(
        id: '5',
        name: '하영',
        age: 30,
        location: '경기도 고양시',
        isVip: true,
        isVerified: true,
        badges: ['인기', 'VIP'],
        distance: 8.3,
        profileImages: [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        ],
      ),
      createMockProfile(
        id: '6',
        name: '예린',
        age: 27,
        location: '서울 마포구',
        isVip: false,
        isVerified: false,
        badges: ['신규'],
        distance: 4.7,
        profileImages: [
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
        ],
      ),
      createMockProfile(
        id: '7',
        name: '지혜',
        age: 32,
        location: '경기도 분당구',
        isVip: true,
        isVerified: true,
        badges: ['VIP'],
        distance: 15.2,
        profileImages: [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        ],
      ),
      createMockProfile(
        id: '8',
        name: '유진',
        age: 26,
        location: '서울 송파구',
        isVip: false,
        isVerified: true,
        badges: ['인기'],
        distance: 6.8,
        profileImages: [
          'https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?w=400',
        ],
      ),
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProfileModel(id: $id, name: $name, age: $age, location: $location)';
  }
}