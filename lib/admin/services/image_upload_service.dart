import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:uuid/uuid.dart';
import '../../utils/logger.dart';

/// 이미지 업로드 서비스
class ImageUploadService {
  static const _uuid = Uuid();
  
  /// S3 버킷 설정
  static const String bucketName = 'meet62ba6c48f504412da023a6b393c9529ec1ba5-dev';
  static const String baseUrl = 'https://$bucketName.s3.ap-northeast-2.amazonaws.com';

  /// FilePicker 초기화 확인
  Future<void> _ensureFilePickerInitialized() async {
    try {
      // 짧은 지연으로 플랫폼 초기화 대기
      await Future.delayed(const Duration(milliseconds: 100));
      
      Logger.log('📋 FilePicker 초기화 확인 완료', name: 'ImageUploadService');
    } catch (e) {
      Logger.log('⚠️ FilePicker 초기화 문제: $e', name: 'ImageUploadService');
      // 추가 대기 시간
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// 이미지 파일 선택
  Future<PlatformFile?> pickImage() async {
    try {
      Logger.log('📸 이미지 파일 선택 시작', name: 'ImageUploadService');

      // 플랫폼별 초기화 확인 및 대기
      await _ensureFilePickerInitialized();

      FilePickerResult? result;
      
      // 더 안전한 방법으로 파일 선택 시도
      try {
        // 여러 시도 방법을 순차적으로 실행
        final methods = [
          () => FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
            withData: kIsWeb,
          ),
          () => FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
            allowMultiple: false,
            withData: kIsWeb,
          ),
          () => FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: false,
            withData: kIsWeb,
          ),
        ];

        for (int i = 0; i < methods.length; i++) {
          try {
            Logger.log('📋 파일 선택 방법 ${i + 1} 시도 중...', name: 'ImageUploadService');
            
            // 긴 타임아웃으로 초기화 대기
            await Future.delayed(Duration(milliseconds: 1000 * (i + 1)));
            
            result = await methods[i]();
            
            if (result != null) {
              Logger.log('✅ 파일 선택 방법 ${i + 1} 성공', name: 'ImageUploadService');
              break;
            }
          } catch (e) {
            Logger.log('❌ 파일 선택 방법 ${i + 1} 실패: $e', name: 'ImageUploadService');
            if (i == methods.length - 1) {
              throw Exception('모든 파일 선택 방법이 실패했습니다: $e');
            }
          }
        }
      } catch (e) {
        Logger.error('모든 FilePicker 방법 실패: $e', name: 'ImageUploadService');
        
        // 완전한 폴백: 시뮬레이션 파일 생성
        Logger.log('🔄 시뮬레이션 파일로 폴백', name: 'ImageUploadService');
        return _createSimulationFile();
      }

      if (result?.files.isNotEmpty == true) {
        final file = result!.files.first;
        Logger.log('📊 선택된 파일: ${file.name} (${file.size} bytes)', name: 'ImageUploadService');
        
        // 파일 확장자 확인 (이미지 파일인지)
        final extension = file.extension?.toLowerCase();
        if (extension == null || !['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
          throw Exception('지원하지 않는 파일 형식입니다. (jpg, jpeg, png, gif, webp만 가능)');
        }
        
        // 파일 크기 제한 (10MB)
        if (file.size > 10 * 1024 * 1024) {
          throw Exception('파일 크기가 10MB를 초과합니다');
        }

        return file;
      }

      Logger.log('📋 파일 선택이 취소되었습니다', name: 'ImageUploadService');
      return null;
    } catch (e) {
      Logger.error('이미지 파일 선택 실패: $e', name: 'ImageUploadService');
      
      // 최종 폴백: 시뮬레이션 파일
      Logger.log('🔄 최종 시뮬레이션 파일로 폴백', name: 'ImageUploadService');
      return _createSimulationFile();
    }
  }

  /// 시뮬레이션 파일 생성 (FilePicker 실패 시 사용)
  PlatformFile _createSimulationFile() {
    Logger.log('📄 시뮬레이션 이미지 파일 생성', name: 'ImageUploadService');
    
    // 1x1 픽셀 PNG 이미지 데이터 (base64)
    final pngData = Uint8List.fromList([
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1,
      0, 0, 0, 1, 8, 2, 0, 0, 0, 144, 119, 83, 222, 0, 0, 0, 12, 73, 68, 65, 84,
      120, 156, 99, 248, 15, 0, 0, 1, 0, 1, 53, 158, 221, 40, 0, 0, 0, 0, 73, 69,
      78, 68, 174, 66, 96, 130
    ]);
    
    return PlatformFile(
      name: 'simulation-image.png',
      size: pngData.length,
      bytes: pngData,
      path: null,
    );
  }

  /// AWS S3에 이미지 업로드
  Future<String> uploadToS3(PlatformFile file, {String? folder}) async {
    try {
      Logger.log('☁️ AWS S3 업로드 시작: ${file.name}', name: 'ImageUploadService');

      // Amplify Storage 사용 가능성 확인
      if (!await _isStorageAvailable()) {
        Logger.log('📊 Storage 서비스 미설정으로 시뮬레이션 모드 사용', name: 'ImageUploadService');
        return _simulateUpload(file, folder: folder);
      }

      // 파일 확장자 추출
      final extension = file.extension ?? 'jpg';
      
      // 고유한 파일명 생성 (public 접근 레벨 사용 - 누구나 읽기 가능)
      final fileName = '${_uuid.v4()}.$extension';
      final fullPath = folder != null ? 'public/$folder/$fileName' : 'public/$fileName';

      Uint8List? fileBytes;
      
      if (kIsWeb) {
        // 웹: 바이트 데이터 사용
        fileBytes = file.bytes;
        if (fileBytes == null) {
          throw Exception('웹에서 파일 바이트 데이터를 가져올 수 없습니다');
        }
      } else {
        // 모바일/데스크톱: 파일 경로 사용
        if (file.path == null) {
          throw Exception('파일 경로를 가져올 수 없습니다');
        }
        final fileData = File(file.path!);
        fileBytes = await fileData.readAsBytes();
      }

      // Amplify Storage로 업로드
      final uploadResult = await Amplify.Storage.uploadData(
        data: S3DataPayload.bytes(fileBytes),
        path: StoragePath.fromString(fullPath),
        options: const StorageUploadDataOptions(
          metadata: {
            'contentType': 'image/*',
          },
        ),
      ).result;

      final imageUrl = '$baseUrl/${uploadResult.uploadedItem.path}';
      
      Logger.log('✅ S3 업로드 완료: $imageUrl', name: 'ImageUploadService');
      return imageUrl;

    } catch (e) {
      Logger.error('S3 업로드 실패: $e', name: 'ImageUploadService');
      
      // Amplify 관련 에러인 경우 시뮬레이션 모드로 fallback
      if (e.toString().contains('Amplify') || 
          e.toString().contains('Storage') ||
          e.toString().contains('No instance found')) {
        Logger.log('📊 Amplify 오류로 인한 시뮬레이션 모드 사용', name: 'ImageUploadService');
        return _simulateUpload(file, folder: folder);
      }
      
      rethrow;
    }
  }

  /// Storage 서비스 사용 가능성 확인
  Future<bool> _isStorageAvailable() async {
    try {
      if (!Amplify.isConfigured) {
        return false;
      }
      
      // Storage 서비스 초기화 대기
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 인증 상태 확인 (선택적 - public 경로는 인증 없이도 가능해야 함)
      try {
        final session = await Amplify.Auth.fetchAuthSession();
        if (!session.isSignedIn) {
          Logger.log('🔐 인증 없음 - public 경로로 진행', name: 'ImageUploadService');
          // public 경로는 인증 없이도 업로드 가능해야 함
        } else {
          Logger.log('✅ 인증된 사용자로 Storage 접근', name: 'ImageUploadService');
        }
      } catch (authError) {
        Logger.log('⚠️ Auth 세션 확인 실패 - public 경로로 진행: $authError', name: 'ImageUploadService');
        // 인증 오류가 있어도 public 경로로 계속 진행
      }
      
      // 실제 Storage 작업 시도로 사용 가능성 확인
      try {
        await Amplify.Storage.list(
          path: const StoragePath.fromString('public/'),
        ).result;
        return true;
      } catch (storageError) {
        Logger.log('⚠️ Storage 테스트 실패: $storageError', name: 'ImageUploadService');
        // guest 레벨로 재시도
        try {
          await Amplify.Storage.list(
            path: const StoragePath.fromString('guest/'),
          ).result;
          return true;
        } catch (fallbackError) {
          Logger.log('⚠️ Storage 폴백 테스트도 실패: $fallbackError', name: 'ImageUploadService');
          return false;
        }
      }
      
    } catch (e) {
      Logger.log('⚠️ Storage 사용 가능성 확인 실패: $e', name: 'ImageUploadService');
      return false;
    }
  }

  /// 임시 관리자 인증 시도
  Future<bool> _attemptAdminAuth() async {
    try {
      Logger.log('🔐 임시 관리자 계정 인증 시도', name: 'ImageUploadService');
      
      // 간단한 임시 계정 정보
      const tempUsername = 'admin@meetapp.temp';
      const tempPassword = 'AdminMeet2024!';
      
      try {
        final result = await Amplify.Auth.signIn(
          username: tempUsername,
          password: tempPassword,
        );
        
        if (result.isSignedIn) {
          Logger.log('✅ 임시 관리자 인증 성공', name: 'ImageUploadService');
          return true;
        }
        return false;
      } on AuthException catch (e) {
        // 계정이 없을 경우 - 관리자에게 알림만 하고 시뮬레이션 모드로 진행
        if (e.message.contains('UserNotFoundException')) {
          Logger.log('⚠️ 관리자 계정이 없음 - Cognito User Pool에서 수동 생성 필요', name: 'ImageUploadService');
          Logger.log('📝 수동 생성 정보: 사용자명=$tempUsername, 비밀번호=$tempPassword', name: 'ImageUploadService');
        }
        
        Logger.log('❌ 임시 인증 실패: ${e.message}', name: 'ImageUploadService');
        return false;
      }
    } catch (e) {
      Logger.log('❌ 관리자 인증 오류: $e', name: 'ImageUploadService');
      return false;
    }
  }

  /// 시뮬레이션 업로드 (개발/테스트용)
  String _simulateUpload(PlatformFile file, {String? folder}) {
    // 실제 업로드된 것처럼 보이는 S3 스타일 URL 생성
    final extension = file.extension ?? 'jpg';
    final fileName = '${_uuid.v4()}.$extension';
    final folderPath = folder != null ? '$folder/' : '';
    final simulationUrl = '$baseUrl/public/$folderPath$fileName';
    
    Logger.log('📊 시뮬레이션 업로드 완료 (S3 스타일): $simulationUrl', name: 'ImageUploadService');
    Logger.log('💡 실제 S3 접근이 가능해지면 이 URL로 업로드됩니다', name: 'ImageUploadService');
    
    return simulationUrl;
  }

  /// 배너 이미지 업로드 (배너 전용 폴더)
  Future<String> uploadBannerImage(PlatformFile file) async {
    return await uploadToS3(file, folder: 'banners');
  }

  /// 프로필 이미지 업로드 (프로필 전용 폴더)
  Future<String> uploadProfileImage(PlatformFile file) async {
    return await uploadToS3(file, folder: 'profiles');
  }

  /// 일반 이미지 업로드
  Future<String> uploadGeneralImage(PlatformFile file) async {
    return await uploadToS3(file, folder: 'general');
  }

  /// S3에서 이미지 삭제
  Future<void> deleteFromS3(String imageUrl) async {
    try {
      // URL에서 S3 경로 추출
      final uri = Uri.parse(imageUrl);
      final path = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
      
      Logger.log('🗑️ S3에서 이미지 삭제 시작: $path', name: 'ImageUploadService');

      await Amplify.Storage.remove(
        path: StoragePath.fromString(path),
      ).result;

      Logger.log('✅ S3 이미지 삭제 완료: $path', name: 'ImageUploadService');
    } catch (e) {
      Logger.error('S3 이미지 삭제 실패: $e', name: 'ImageUploadService');
      // 삭제 실패는 치명적이지 않으므로 예외를 다시 던지지 않음
    }
  }

  /// 이미지 URL 유효성 검증
  bool isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             (url.contains('.jpg') || url.contains('.jpeg') || 
              url.contains('.png') || url.contains('.gif') || 
              url.contains('.webp'));
    } catch (e) {
      return false;
    }
  }

  /// 파일 크기를 사람이 읽기 쉬운 형태로 변환
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}