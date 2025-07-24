import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HoneyconDao {
  static const String ordersTable = 'honeycon_orders';
  static const String goodsTable = 'honeycon_goods';

  static Future<Database> get database async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'honeycon.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $ordersTable (
            tr_id TEXT PRIMARY KEY,
            order_id TEXT,
            goods_id TEXT,
            receiver_mobile TEXT,
            order_date TEXT,
            order_status TEXT,
            coupon_num TEXT,
            title TEXT,
            content TEXT,
            sms_type TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE $goodsTable (
            goods_id TEXT PRIMARY KEY,
            goods_name TEXT,
            goods_price INTEGER,
            goods_info_url TEXT,
            rcompany_name TEXT,
            last_updated TEXT
          )
        ''');
      },
    );
  }

  // 주문 정보 CRUD
  static Future<void> insertOrder(Map<String, dynamic> order) async {
    final db = await database;
    await db.insert(ordersTable, order, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return db.query(ordersTable, orderBy: 'order_date DESC');
  }

  static Future<Map<String, dynamic>?> getOrderByTrId(String trId) async {
    final db = await database;
    final result = await db.query(ordersTable, where: 'tr_id = ?', whereArgs: [trId]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> updateOrder(String trId, Map<String, dynamic> order) async {
    final db = await database;
    await db.update(ordersTable, order, where: 'tr_id = ?', whereArgs: [trId]);
  }

  static Future<void> deleteOrder(String trId) async {
    final db = await database;
    await db.delete(ordersTable, where: 'tr_id = ?', whereArgs: [trId]);
  }

  // 상품 정보 CRUD
  static Future<void> insertGoods(Map<String, dynamic> goods) async {
    final db = await database;
    await db.insert(goodsTable, goods, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getGoodsList() async {
    final db = await database;
    return db.query(goodsTable, orderBy: 'goods_name ASC');
  }

  static Future<Map<String, dynamic>?> getGoodsById(String goodsId) async {
    final db = await database;
    final result = await db.query(goodsTable, where: 'goods_id = ?', whereArgs: [goodsId]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> updateGoods(String goodsId, Map<String, dynamic> goods) async {
    final db = await database;
    await db.update(goodsTable, goods, where: 'goods_id = ?', whereArgs: [goodsId]);
  }

  static Future<void> deleteGoods(String goodsId) async {
    final db = await database;
    await db.delete(goodsTable, where: 'goods_id = ?', whereArgs: [goodsId]);
  }

  // 동기화: 서버에서 받아온 주문/상품 데이터로 로컬 DB 갱신
  static Future<void> syncOrders(List<Map<String, dynamic>> orders) async {
    final db = await database;
    final batch = db.batch();
    for (final order in orders) {
      batch.insert(ordersTable, order, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> syncGoods(List<Map<String, dynamic>> goodsList) async {
    final db = await database;
    final batch = db.batch();
    for (final goods in goodsList) {
      batch.insert(goodsTable, goods, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
} 