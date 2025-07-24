import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/app_settings.dart';
import '../../utils/logger.dart';

class AppSettingsDao {
  Future<int> insertSetting(AppSetting setting) async {
    final db = await DatabaseHelper().database;
    return await db.insert('app_settings', setting.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AppSetting?> getSetting(String key) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('app_settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isNotEmpty) {
      return AppSetting.fromMap(maps.first);
    }
    return null;
  }

  Future<List<AppSetting>> getAllSettings() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('app_settings');
    return maps.map((e) => AppSetting.fromMap(e)).toList();
  }

  Future<int> updateSetting(AppSetting setting) async {
    final db = await DatabaseHelper().database;
    return await db.update('app_settings', setting.toMap(), where: 'key = ?', whereArgs: [setting.key]);
  }

  Future<int> deleteSetting(String key) async {
    final db = await DatabaseHelper().database;
    return await db.delete('app_settings', where: 'key = ?', whereArgs: [key]);
  }

  // AWS와 동기화 (예시)
  Future<void> syncWithAWS() async {
    Logger.i('AppSettingsDao: AWS 동기화 시작');
    // TODO: Amplify API와 연동하여 동기화 구현
  }
} 