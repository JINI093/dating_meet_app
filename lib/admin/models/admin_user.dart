/// 관리자 사용자 모델
class AdminUser {
  final String id;
  final String username;
  final String email;
  final String name;
  final AdminRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final String? profileImage;
  final Map<String, bool> permissions;

  AdminUser({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.profileImage,
    this.permissions = const {},
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: AdminRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => AdminRole.viewer,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      profileImage: json['profileImage'] as String?,
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
      'profileImage': profileImage,
      'permissions': permissions,
    };
  }

  AdminUser copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    AdminRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    String? profileImage,
    Map<String, bool>? permissions,
  }) {
    return AdminUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      profileImage: profileImage ?? this.profileImage,
      permissions: permissions ?? this.permissions,
    );
  }
}

/// 관리자 권한 레벨
enum AdminRole {
  superAdmin('최고 관리자', 'admin.super'),
  userManager('회원 관리자', 'admin.user'),
  contentManager('콘텐츠 관리자', 'admin.content'),
  financeManager('결제 관리자', 'admin.finance'),
  supportManager('고객지원 관리자', 'admin.support'),
  analyst('분석가', 'admin.analyst'),
  viewer('열람자', 'admin.viewer');

  final String displayName;
  final String code;

  const AdminRole(this.displayName, this.code);

  /// 권한별 접근 가능 메뉴
  List<String> get accessibleMenus {
    switch (this) {
      case AdminRole.superAdmin:
        return [
          'dashboard',
          'users',
          'vip',
          'points',
          'realtime',
          'reports',
          'rankings',
          'admins',
          'products',
          'payments',
          'coupons',
          'blacklist',
          'statistics',
          'notices',
          'settings'
        ];
      case AdminRole.userManager:
        return ['dashboard', 'users', 'vip', 'points', 'realtime', 'reports', 'rankings'];
      case AdminRole.contentManager:
        return ['dashboard', 'notices', 'products'];
      case AdminRole.financeManager:
        return ['dashboard', 'payments', 'coupons', 'statistics'];
      case AdminRole.supportManager:
        return ['dashboard', 'reports', 'blacklist', 'users'];
      case AdminRole.analyst:
        return ['dashboard', 'statistics', 'users', 'realtime'];
      case AdminRole.viewer:
        return ['dashboard'];
    }
  }

  /// 권한별 작업 가능 여부
  bool canEdit(String menu) {
    if (this == AdminRole.viewer) return false;
    if (this == AdminRole.superAdmin) return true;
    
    switch (menu) {
      case 'users':
        return this == AdminRole.userManager;
      case 'notices':
      case 'products':
        return this == AdminRole.contentManager;
      case 'payments':
      case 'coupons':
        return this == AdminRole.financeManager;
      case 'reports':
      case 'blacklist':
        return this == AdminRole.supportManager;
      default:
        return false;
    }
  }
}