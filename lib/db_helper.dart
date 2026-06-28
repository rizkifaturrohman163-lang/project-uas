import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Database? _database;

  Future <Database> get db async {
    if(_database!=null) return _database!;
    _database = await initDb();
     return _database!;
  }

  initDb() async {
    String sql = 'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT )' ;
    String path = join(await getDatabasesPath(),'user_data.db');
    return await openDatabase(path, version: 1,onCreate: (db, version) async{
    await db.execute(sql);
    },);
  }

//fungsimenyimpan data ke database (register)
  Future<int> register (String username, String password) async {
    var dbClient = await db;
    return await dbClient.insert('users', {'username':username, 'password':password});
 }

 //fungsi membaca data/select dari database (login)
  Future<bool> checkLogin (String username, String password) async {
    String sql = " SELECT * FROM users WHERE username= '$username' AND password = '$password'";
    var dbClient = await db;
    var result = await dbClient.rawQuery(sql);
    return result.isNotEmpty;
  }
}