import 'package:dimo/data/memo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'memo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE memos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            content TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertMemo(Memo memo) async {
    Database db = await database;
    return await db.insert('memos', memo.toMap());
  }

  Future<List<Memo>> readMemos() async {
    Database db = await database;

    List<Map<String, dynamic>> maps = await db.query('memos');

    return List.generate(maps.length, (index) {
      return Memo(
          id: maps[index]['id'],
          name: maps[index]['name'],
          content: maps[index]['content']);
    });
  }

  Future<List<Memo>> readMemo(String name) async {
    Database db = await database;

    List<Map<String, dynamic>> maps =
        await db.query('memos', where: 'name = ?', whereArgs: [name]);

    return List.generate(maps.length, (index) {
      return Memo(
          id: maps[index]['id'],
          name: maps[index]['name'],
          content: maps[index]['content']);
    });
  }

  Future<void> updateMemo(Memo memo) async {
    Database db = await database;
    db.update(
      'memos',
      memo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );

    print(await db.query('memos'));
  }

  Future<void> deleteAllMemo() async {
    Database db = await database;
    db.delete(
      'memos',
    );
    print("deleteAll 실행됨");
  }

  Future<void> deleteOneMemo(String name) async {
    Database db = await database;
    db.delete(
      'memos',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<bool> isthereMemo(String name) async {
    Database db = await database;

    try {
      List<Map<String, dynamic>> map =
          await db.query('memos', where: 'name = ?', whereArgs: [name]);
      print(map[0]['name']);
    } catch (E) {
      return false; // print수행할때 데이터베이스에 데이터 없어서 에러 나면 false 리턴
    }

    return true; // 에러 안 났다는 건 데이터 있었다는 소리니까 true 리턴
  }

  Future<bool> haveMemos() async {
    Database db = await database;

    try {
      List<Map<String, dynamic>> map = await db.query('memos');
      print(map[0]['name']);
    } catch (E) {
      return false; // print수행할때 데이터베이스에 데이터 없어서 에러 나면 false 리턴
    }
    return true;
  }

  Future<int> dbSize() async {
    Database db = await database;

    int size = 0;
    try {
      List<Map<String, dynamic>> map = await db.query('memos');
      print(map[0]['name']);
      size = map.length;
    } catch (E) {
      return 0; // print수행할때 데이터베이스에 데이터 없어서 에러 나면 false 리턴
    }
    return size;
  }
}
