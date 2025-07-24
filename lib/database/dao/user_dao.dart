import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/users.dart';
import '../../utils/logger.dart';

class UserDao {
  Future<int> insertUser(User user) async {
    final db = await DatabaseHelper().database;
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUser(String id) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('users');
    return maps.map((e) => User.fromMap(e)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await DatabaseHelper().database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(String id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // AWS와 동기화 (예시)
  Future<void> syncWithAWS() async {
    Logger.i('UserDao: AWS 동기화 시작');
    // TODO: Amplify API/Storage와 연동하여 동기화 구현
  }
} 