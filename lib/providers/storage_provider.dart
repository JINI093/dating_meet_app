import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class StorageProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  List<StorageItem> _files = [];
  String? _error;

  double get uploadProgress => _uploadProgress;
  bool get isUploading => _isUploading;
  List<StorageItem> get files => _files;
  String? get error => _error;

  Future<void> uploadFile({required File file, required String key}) async {
    _isUploading = true;
    _error = null;
    notifyListeners();
    try {
      await _storageService.uploadFile(
        file: file,
        key: key,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );
      await fetchFiles(key.substring(0, key.lastIndexOf('/') + 1));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<void> fetchFiles(String path) async {
    try {
      _files = await _storageService.listFiles(path);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> deleteFile(String key) async {
    try {
      await _storageService.deleteFile(key);
      await fetchFiles(key.substring(0, key.lastIndexOf('/') + 1));
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _storageService.dispose();
    super.dispose();
  }
} 