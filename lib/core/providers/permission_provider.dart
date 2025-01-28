import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_provider.g.dart';

@riverpod
class PermissionController extends _$PermissionController {
  @override
  Future<bool> build() async {
    // 앱 시작시 권한 확인 및 요청
    final status = await Permission.contacts.status;

    // 이미 권한이 있는 경우
    if (status.isGranted) {
      return true;
    }

    // 아직 권한 요청을 하지 않은 경우에만 요청
    if (status.isDenied) {
      final result = await Permission.contacts.request();
      return result.isGranted;
    }

    // 영구적으로 거부된 경우나 다른 상태
    return false;
  }

  Future<void> requestPermission() async {
    final status = await Permission.contacts.status;

    // 이미 영구적으로 거부된 경우
    if (status.isPermanentlyDenied) {
      state = const AsyncValue.data(false);
      return;
    }

    // 권한 요청
    final result = await Permission.contacts.request();
    state = AsyncValue.data(result.isGranted);
  }

  Future<void> refreshPermissionStatus() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _checkPermission());
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.contacts.status;
    return status.isGranted;
  }
}
