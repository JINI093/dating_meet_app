import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class AuthResult {
  final bool success;
  final String? error;
  final AuthUser? user;
  final String? accessToken;
  final String? refreshToken;
  final String? loginMethod;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;
  final bool? requiresConfirmation;

  const AuthResult({
    required this.success,
    this.error,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.loginMethod,
    this.expiresAt,
    this.metadata,
    this.requiresConfirmation,
  });

  factory AuthResult.success({
    AuthUser? user,
    String? accessToken,
    String? refreshToken,
    String? loginMethod,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? additionalData,
    bool? requiresConfirmation,
  }) {
    final combinedMetadata = <String, dynamic>{};
    if (metadata != null) combinedMetadata.addAll(metadata);
    if (additionalData != null) combinedMetadata.addAll(additionalData);
    
    return AuthResult(
      success: true,
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
      loginMethod: loginMethod,
      expiresAt: expiresAt,
      metadata: combinedMetadata.isNotEmpty ? combinedMetadata : null,
      requiresConfirmation: requiresConfirmation,
    );
  }

  factory AuthResult.failure({
    required String error,
    Map<String, dynamic>? metadata,
    bool? requiresConfirmation,
  }) {
    return AuthResult(
      success: false,
      error: error,
      metadata: metadata,
      requiresConfirmation: requiresConfirmation,
    );
  }

  // AuthUser의 username을 위한 getter
  String? get username => user?.username;
  
  // error message getter (backward compatibility)
  String? get errorMessage => error;
  
  // isSuccess getter (backward compatibility)
  bool get isSuccess => success;

  AuthResult copyWith({
    bool? success,
    String? error,
    AuthUser? user,
    String? accessToken,
    String? refreshToken,
    String? loginMethod,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return AuthResult(
      success: success ?? this.success,
      error: error ?? this.error,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      loginMethod: loginMethod ?? this.loginMethod,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
      'user': user != null ? {
        'userId': user!.userId,
        'username': user!.username,
      } : null,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'loginMethod': loginMethod,
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
      'requiresConfirmation': requiresConfirmation,
    };
  }

  @override
  String toString() {
    return 'AuthResult(success: $success, error: $error, user: ${user?.username})';
  }
}

class LoginRecord {
  final String userId;
  final String loginMethod;
  final DateTime timestamp;
  final bool success;
  final String? deviceInfo;
  final String? ipAddress;
  final String? location;
  final String? error;

  const LoginRecord({
    required this.userId,
    required this.loginMethod,
    required this.timestamp,
    required this.success,
    this.deviceInfo,
    this.ipAddress,
    this.location,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'loginMethod': loginMethod,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
      'location': location,
      'error': error,
    };
  }

  factory LoginRecord.fromJson(Map<String, dynamic> json) {
    return LoginRecord(
      userId: json['userId'] as String,
      loginMethod: json['loginMethod'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      success: json['success'] as bool,
      deviceInfo: json['deviceInfo'] as String?,
      ipAddress: json['ipAddress'] as String?,
      location: json['location'] as String?,
      error: json['error'] as String?,
    );
  }

  @override
  String toString() {
    return 'LoginRecord(userId: $userId, method: $loginMethod, success: $success, timestamp: $timestamp)';
  }
}