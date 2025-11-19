import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/contact_model.dart';

class DBHelper {
  static Database? _db;

  // Inisialisasi / buka database
  static Future<void> initDB() async {
    if (_db != null) return;
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, "contacts_app.db");

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Buat tabel user
        await db.execute("""
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            photo TEXT
          )
        """);

        // Buat tabel kontak
        await db.execute("""
          CREATE TABLE contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            phone TEXT,
            photo TEXT,
            avatarUrl TEXT
          )
        """);
      },
    );
  }

  // Ambil user berdasarkan id
static Future<UserModel?> loginById(int id) async {
  final res = await _db!.query(
    'users',
    where: "id=?",
    whereArgs: [id],
  );
  if (res.isNotEmpty) return UserModel.fromMap(res.first);
  return null;
}

  // Register user baru
  static Future<int> insertUser(UserModel user) async {
    return await _db!.insert('users', user.toMap());
  }

  // Login user
  static Future<UserModel?> login(String username, String password) async {
    final res = await _db!.query(
      'users',
      where: "username=? AND password=?",
      whereArgs: [username, password],
    );
    if (res.isNotEmpty) return UserModel.fromMap(res.first);
    return null;
  }

  // Update field user
  static Future<int> updateUserFields(int id, Map<String, dynamic> fields) async {
    return await _db!.update('users', fields, where: 'id = ?', whereArgs: [id]);
  }

  // Delete user (juga hapus semua kontak)
  static Future<int> deleteUser(int id) async {
    await deleteAllContacts();
    return await _db!.delete('users', where: 'id=?', whereArgs: [id]);
  }

  // Membuat kontak
  static Future<int> insertContact(ContactModel contact) async {
    return await _db!.insert('contacts', contact.toMap());
  }

  // Tampilkan semua kontak
  static Future<List<ContactModel>> getContacts() async {
    final res = await _db!.query('contacts', orderBy: 'id DESC');
    return res.map((e) => ContactModel.fromMap(e)).toList();
  }

  // Update kontak
  static Future<int> updateContact(int id, Map<String, dynamic> fields) async {
    return await _db!.update('contacts', fields, where: 'id=?', whereArgs: [id]);
  }

  // Delete kontak
  static Future<int> deleteContact(int id) async {
    return await _db!.delete('contacts', where: 'id=?', whereArgs: [id]);
  }

  // Delete semua kontak (misal saat hapus akun)
  static Future<int> deleteAllContacts() async {
    return await _db!.delete('contacts');
  }
}
