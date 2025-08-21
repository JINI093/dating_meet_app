import 'package:flutter_contacts/flutter_contacts.dart';

/// 연락처 아이템 모델
class ContactItem {
  final String name;
  final String phone;
  final String? displayName;
  final String? avatar;
  bool isBlocked;

  ContactItem({
    required this.name,
    required this.phone,
    this.displayName,
    this.avatar,
    this.isBlocked = false,
  });

  /// 연락처에서 ContactItem으로 변환
  factory ContactItem.fromContact(Contact contact) {
    final phone = contact.phones.isNotEmpty 
        ? contact.phones.first.number
        : '';
    
    return ContactItem(
      name: contact.displayName,
      phone: _normalizePhone(phone),
      displayName: contact.displayName,
      avatar: null, // 아바타는 일단 null로 처리
    );
  }

  /// 전화번호 정규화 (한국 형식)
  static String _normalizePhone(String phone) {
    // 공백, 하이픈 제거
    String normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // 국가 코드 처리
    if (normalized.startsWith('+82')) {
      normalized = '0${normalized.substring(3)}';
    } else if (normalized.startsWith('82')) {
      normalized = '0${normalized.substring(2)}';
    }
    
    return normalized;
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'displayName': displayName,
      'isBlocked': isBlocked,
    };
  }

  factory ContactItem.fromJson(Map<String, dynamic> json) {
    return ContactItem(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      displayName: json['displayName'],
      isBlocked: json['isBlocked'] ?? false,
    );
  }

  @override
  String toString() {
    return 'ContactItem(name: $name, phone: $phone, isBlocked: $isBlocked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactItem && 
           other.phone == phone;
  }

  @override
  int get hashCode => phone.hashCode;
}

/// 차단된 연락처 정보
class BlockedContact {
  final String phone;
  final String name;
  final DateTime blockedAt;
  final String? reason;

  BlockedContact({
    required this.phone,
    required this.name,
    required this.blockedAt,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'name': name,
      'blockedAt': blockedAt.toIso8601String(),
      'reason': reason,
    };
  }

  factory BlockedContact.fromJson(Map<String, dynamic> json) {
    return BlockedContact(
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      blockedAt: DateTime.parse(json['blockedAt']),
      reason: json['reason'],
    );
  }

  @override
  String toString() {
    return 'BlockedContact(phone: $phone, name: $name, blockedAt: $blockedAt)';
  }
}