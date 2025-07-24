import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionState {
  final bool notificationGranted;
  final bool locationGranted;
  final bool storageGranted;
  final bool allGranted;

  const PermissionState({
    this.notificationGranted = false,
    this.locationGranted = false,
    this.storageGranted = false,
    this.allGranted = false,
  });

  PermissionState copyWith({
    bool? notificationGranted,
    bool? locationGranted,
    bool? storageGranted,
    bool? allGranted,
  }) {
    return PermissionState(
      notificationGranted: notificationGranted ?? this.notificationGranted,
      locationGranted: locationGranted ?? this.locationGranted,
      storageGranted: storageGranted ?? this.storageGranted,
      allGranted: allGranted ?? this.allGranted,
    );
  }
}

class PermissionViewModel extends StateNotifier<PermissionState> {
  PermissionViewModel() : super(const PermissionState());

  Future<void> checkAllPermissions() async {
    final notification = await Permission.notification.isGranted;
    final location = await Permission.locationWhenInUse.isGranted;
    final storage = await Permission.photos.isGranted;
    final all = notification && location && storage;
    state = state.copyWith(
      notificationGranted: notification,
      locationGranted: location,
      storageGranted: storage,
      allGranted: all,
    );
  }

  Future<void> requestNotification() async {
    await Permission.notification.request();
    await checkAllPermissions();
  }

  Future<void> requestLocation() async {
    await Permission.locationWhenInUse.request();
    await checkAllPermissions();
  }

  Future<void> requestStorage() async {
    await Permission.photos.request();
    await checkAllPermissions();
  }
}

final permissionViewModelProvider = StateNotifierProvider<PermissionViewModel, PermissionState>((ref) {
  return PermissionViewModel();
}); 