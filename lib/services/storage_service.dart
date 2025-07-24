import 'dart:async';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

class StorageService {
  // 업로드 진행률 스트림
  final StreamController<double> _uploadProgressController = StreamController.broadcast();
  Stream<double> get uploadProgress => _uploadProgressController.stream;

  // 파일 업로드
  Future<StorageUploadFileResult> uploadFile({
    required File file,
    required String key,
    void Function(double progress)? onProgress,
  }) async {
    final awsFile = AWSFile.fromPath(file.path);
    final uploadTask = Amplify.Storage.uploadFile(
      localFile: awsFile,
      path: StoragePath.fromString(key),
      onProgress: (progress) {
        final percent = progress.transferredBytes / progress.totalBytes;
        _uploadProgressController.add(percent);
        if (onProgress != null) onProgress(percent);
      },
    );
    return await uploadTask.result;
  }

  // 파일 다운로드
  Future<File> downloadFile({
    required String key,
    required File local,
  }) async {
    final awsFile = AWSFile.fromPath(local.path);
    final downloadTask = Amplify.Storage.downloadFile(
      path: StoragePath.fromString(key),
      localFile: awsFile,
    );
    await downloadTask.result;
    return local;
  }

  // 파일 삭제
  Future<void> deleteFile(String key) async {
    await Amplify.Storage.remove(
      path: StoragePath.fromString(key),
    ).result;
  }

  // 파일 URL 생성
  Future<Uri> getFileUrl(String key) async {
    final result = await Amplify.Storage.getUrl(
      path: StoragePath.fromString(key),
    ).result;
    return result.url;
  }

  // 파일 목록 조회
  Future<List<StorageItem>> listFiles(String path) async {
    final result = await Amplify.Storage.list(
      path: StoragePath.fromString(path),
    ).result;
    return result.items;
  }

  // 폴더 구조 예시 생성 함수 (실제 S3는 폴더 개념이 없으나, prefix로 관리)
  static String userProfilePath(String userId) => 'users/$userId/profile/';
  static String userUploadsPath(String userId) => 'users/$userId/uploads/';
  static String publicSharedPath() => 'public/shared/';

  void dispose() {
    _uploadProgressController.close();
  }
}
