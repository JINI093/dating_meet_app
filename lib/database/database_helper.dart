import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DB_NAME);
    return await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        avatarUrl TEXT,
        updatedAt INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE files (
        id TEXT PRIMARY KEY,
        userId TEXT,
        fileName TEXT,
        filePath TEXT,
        uploaded INTEGER,
        awsUrl TEXT,
        updatedAt INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 버전 업그레이드 시 마이그레이션 로직
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('users');
    await db.delete('files');
    await db.delete('app_settings');
  }

  // 오프라인 데이터 동기화 예시 (각 DAO에서 구체적으로 구현)
  Future<void> syncWithAWS() async {
    Logger.i('DB 동기화 시작');
    // 각 DAO의 sync 메서드 호출
    // 예: await UserDao().syncWithAWS();
    // 예: await FileDao().syncWithAWS();
  }
} 