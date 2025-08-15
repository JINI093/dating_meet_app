import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/contact_block_model.dart';
import '../utils/logger.dart';

/// 연락처 관리 서비스
class ContactService {
  static const String _blockedContactsKey = 'blocked_contacts';
  
  /// 연락처 권한 요청
  Future<bool> requestContactPermission() async {
    try {
      final status = await Permission.contacts.request();
      
      if (status == PermissionStatus.granted) {
        Logger.log('✅ 연락처 권한 승인됨', name: 'ContactService');
        return true;
      } else if (status == PermissionStatus.denied) {
        Logger.log('❌ 연락처 권한 거부됨', name: 'ContactService');
        return false;
      } else if (status == PermissionStatus.permanentlyDenied) {
        Logger.log('❌ 연락처 권한 영구 거부됨 - 설정으로 이동 필요', name: 'ContactService');
        return false;
      }
      
      return false;
    } catch (e) {
      Logger.error('연락처 권한 요청 오류: $e', name: 'ContactService');
      return false;
    }
  }

  /// 연락처 권한 상태 확인
  Future<bool> hasContactPermission() async {
    try {
      final status = await Permission.contacts.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      Logger.error('연락처 권한 상태 확인 오류: $e', name: 'ContactService');
      return false;
    }
  }

  /// 기기 연락처 불러오기
  Future<List<ContactItem>> getDeviceContacts() async {
    try {
      final hasPermission = await hasContactPermission();
      if (!hasPermission) {
        final granted = await requestContactPermission();
        if (!granted) {
          throw Exception('연락처 권한이 필요합니다.');
        }
      }

      Logger.log('📱 기기 연락처 불러오기 시작...', name: 'ContactService');
      
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
      
      final contactItems = <ContactItem>[];

      for (final contact in contacts) {
        if (contact.phones.isNotEmpty) {
          final phone = contact.phones.first.number;
          final name = contact.displayName;
          
          // 유효한 전화번호와 이름이 있는 경우만 추가
          if (phone.isNotEmpty && name.isNotEmpty && _isValidKoreanPhone(_normalizePhone(phone))) {
            final contactItem = ContactItem(
              name: name,
              phone: _normalizePhone(phone),
              displayName: contact.displayName,
              avatar: null,
            );
            contactItems.add(contactItem);
          }
        }
      }

      // 차단 상태 업데이트
      await _updateBlockStatusFromStorage(contactItems);

      Logger.log('✅ 연락처 ${contactItems.length}개 불러오기 완료', name: 'ContactService');
      return contactItems;
      
    } catch (e) {
      Logger.error('연락처 불러오기 오류: $e', name: 'ContactService');
      rethrow;
    }
  }

  /// 전화번호 정규화 (한국 형식)
  String _normalizePhone(String phone) {
    // 공백, 하이픈, 괄호 제거
    String normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // 국가 코드 처리
    if (normalized.startsWith('+82')) {
      normalized = '0${normalized.substring(3)}';
    } else if (normalized.startsWith('82')) {
      normalized = '0${normalized.substring(2)}';
    }
    
    return normalized;
  }

  /// 한국 전화번호 유효성 검사
  bool _isValidKoreanPhone(String phone) {
    // 010, 011, 016, 017, 018, 019로 시작하는 11자리 번호
    final regex = RegExp(r'^01[0-9]\d{8}$');
    return regex.hasMatch(phone);
  }

  /// 차단된 연락처 목록 가져오기
  Future<List<BlockedContact>> getBlockedContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedJson = prefs.getString(_blockedContactsKey);
      
      if (blockedJson == null || blockedJson.isEmpty) {
        return [];
      }

      final List<dynamic> blockedList = json.decode(blockedJson);
      return blockedList.map((item) => BlockedContact.fromJson(item)).toList();
      
    } catch (e) {
      Logger.error('차단된 연락처 불러오기 오류: $e', name: 'ContactService');
      return [];
    }
  }

  /// 연락처 차단하기
  Future<bool> blockContact(ContactItem contact, {String? reason}) async {
    try {
      final blockedContacts = await getBlockedContacts();
      
      // 이미 차단된 연락처인지 확인
      final isAlreadyBlocked = blockedContacts.any((blocked) => 
          blocked.phone == contact.phone);
      
      if (isAlreadyBlocked) {
        Logger.log('⚠️ 이미 차단된 연락처: ${contact.phone}', name: 'ContactService');
        return false;
      }

      // 새로운 차단 연락처 추가
      final newBlocked = BlockedContact(
        phone: contact.phone,
        name: contact.name,
        blockedAt: DateTime.now(),
        reason: reason,
      );

      blockedContacts.add(newBlocked);
      
      // 로컬 저장소에 저장
      await _saveBlockedContacts(blockedContacts);
      
      // TODO: AWS에 차단 정보 동기화
      await _syncBlockedContactsToAWS(blockedContacts);

      Logger.log('✅ 연락처 차단 완료: ${contact.name} (${contact.phone})', name: 'ContactService');
      return true;
      
    } catch (e) {
      Logger.error('연락처 차단 오류: $e', name: 'ContactService');
      return false;
    }
  }

  /// 연락처 차단 해제하기
  Future<bool> unblockContact(String phone) async {
    try {
      final blockedContacts = await getBlockedContacts();
      
      // 차단 목록에서 제거
      final originalLength = blockedContacts.length;
      blockedContacts.removeWhere((blocked) => blocked.phone == phone);
      
      if (blockedContacts.length == originalLength) {
        Logger.log('⚠️ 차단되지 않은 연락처: $phone', name: 'ContactService');
        return false;
      }

      // 로컬 저장소에 저장
      await _saveBlockedContacts(blockedContacts);
      
      // TODO: AWS에 차단 해제 정보 동기화
      await _syncBlockedContactsToAWS(blockedContacts);

      Logger.log('✅ 연락처 차단 해제 완료: $phone', name: 'ContactService');
      return true;
      
    } catch (e) {
      Logger.error('연락처 차단 해제 오류: $e', name: 'ContactService');
      return false;
    }
  }

  /// 특정 전화번호가 차단되었는지 확인
  Future<bool> isContactBlocked(String phone) async {
    try {
      final blockedContacts = await getBlockedContacts();
      return blockedContacts.any((blocked) => blocked.phone == phone);
    } catch (e) {
      Logger.error('차단 상태 확인 오류: $e', name: 'ContactService');
      return false;
    }
  }

  /// 차단된 연락처 목록을 로컬 저장소에 저장
  Future<void> _saveBlockedContacts(List<BlockedContact> blockedContacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedJson = json.encode(
        blockedContacts.map((contact) => contact.toJson()).toList()
      );
      await prefs.setString(_blockedContactsKey, blockedJson);
    } catch (e) {
      Logger.error('차단된 연락처 저장 오류: $e', name: 'ContactService');
      rethrow;
    }
  }

  /// 저장된 차단 상태를 연락처 목록에 반영
  Future<void> _updateBlockStatusFromStorage(List<ContactItem> contacts) async {
    try {
      final blockedContacts = await getBlockedContacts();
      final blockedPhones = blockedContacts.map((blocked) => blocked.phone).toSet();
      
      for (final contact in contacts) {
        contact.isBlocked = blockedPhones.contains(contact.phone);
      }
    } catch (e) {
      Logger.error('차단 상태 업데이트 오류: $e', name: 'ContactService');
    }
  }

  /// AWS에 차단된 연락처 동기화 (미구현)
  Future<void> _syncBlockedContactsToAWS(List<BlockedContact> blockedContacts) async {
    try {
      // TODO: AWS GraphQL API 또는 Cognito custom attributes를 사용하여 동기화
      // 보안상 전화번호를 해시화하여 저장하는 것을 권장
      Logger.log('📡 AWS 동기화 필요 (미구현): ${blockedContacts.length}개', name: 'ContactService');
    } catch (e) {
      Logger.error('AWS 동기화 오류: $e', name: 'ContactService');
    }
  }

  /// 연락처 검색
  List<ContactItem> searchContacts(List<ContactItem> contacts, String query) {
    if (query.isEmpty) return contacts;
    
    final lowerQuery = query.toLowerCase();
    return contacts.where((contact) {
      final name = contact.name.toLowerCase();
      final phone = contact.phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      return name.contains(lowerQuery) || phone.contains(query);
    }).toList();
  }

  /// 설정 앱으로 이동 (권한 설정용)
  Future<void> openAppSettings() async {
    try {
      await Permission.contacts.request();
    } catch (e) {
      Logger.error('설정 앱 열기 오류: $e', name: 'ContactService');
    }
  }
}