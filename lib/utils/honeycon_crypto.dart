import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class HoneyconCrypto {
  // 심플 XOR 암호화 (AES 대신 사용)
  static String encrypt(String plainText, String key) {
    if (plainText.isEmpty) throw ArgumentError('plainText는 비어 있을 수 없습니다.');
    if (key.isEmpty) throw ArgumentError('key는 비어 있을 수 없습니다.');
    
    try {
      // key를 MD5 해시로 변환하여 안정적인 키 생성
      final keyHash = md5.convert(utf8.encode(key)).toString();
      final keyBytes = utf8.encode(keyHash);
      final plainBytes = utf8.encode(plainText);
      
      // XOR 암호화
      final encryptedBytes = <int>[];
      for (int i = 0; i < plainBytes.length; i++) {
        encryptedBytes.add(plainBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return base64.encode(encryptedBytes);
    } catch (e) {
      throw Exception('암호화 실패: $e');
    }
  }

  // 복호화 (쿠폰번호 복호화용)
  static String decrypt(String encryptedText, String key) {
    if (encryptedText.isEmpty) throw ArgumentError('encryptedText는 비어 있을 수 없습니다.');
    if (key.isEmpty) throw ArgumentError('key는 비어 있을 수 없습니다.');
    
    try {
      final encryptedBytes = base64.decode(encryptedText);
      final keyHash = md5.convert(utf8.encode(key)).toString();
      final keyBytes = utf8.encode(keyHash);
      
      // XOR 복호화 (암호화와 동일한 연산)
      final decryptedBytes = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw Exception('복호화 실패: $e');
    }
  }

  // 트랜잭션 ID 생성 (중복 방지)
  static String generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    final raw = 'tr_${timestamp}_$random';
    return raw.length > 20 ? raw.substring(0, 20) : raw;
  }

  // 해시 함수 (데이터 무결성 검증용)
  static String hash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 랜덤 문자열 생성 (토큰, 쿠폰 번호 등)
  static String generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
} 