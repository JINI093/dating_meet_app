import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/files.dart';
import '../../utils/logger.dart';

class FileDao {
  Future<int> insertFile(FileInfo file) async {
    final db = await DatabaseHelper().database;
    return await db.insert('files', file.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<FileInfo?> getFile(String id) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('files', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return FileInfo.fromMap(maps.first);
    }
    return null;
  }

  Future<List<FileInfo>> getAllFiles() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('files');
    return maps.map((e) => FileInfo.fromMap(e)).toList();
  }

  Future<int> updateFile(FileInfo file) async {
    final db = await DatabaseHelper().database;
    return await db.update('files', file.toMap(), where: 'id = ?', whereArgs: [file.id]);
  }

  Future<int> deleteFile(String id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('files', where: 'id = ?', whereArgs: [id]);
  }

  // AWS와 동기화 (예시)
  Future<void> syncWithAWS() async {
    Logger.i('FileDao: AWS 동기화 시작');
    // TODO: Amplify Storage와 연동하여 동기화 구현
  }
} 