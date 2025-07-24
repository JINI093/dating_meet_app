import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

class ApiProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;
  Response? _lastResponse;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Response? get lastResponse => _lastResponse;

  Future<void> request({
    required Future<Response> Function(ApiService api) apiCall,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _lastResponse = await apiCall(_apiService);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 