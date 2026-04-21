import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'student_task_manager.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        gender TEXT,
        email TEXT NOT NULL UNIQUE,
        studentId TEXT NOT NULL UNIQUE,
        academicLevel TEXT,
        password TEXT NOT NULL,
        profileImagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        priority TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> createUser(UserModel user) async {
    final db = await database;
    return db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<bool> isEmailTaken(String email, {int? excludingUserId}) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: excludingUserId == null ? 'email = ?' : 'email = ? AND id != ?',
      whereArgs: excludingUserId == null ? [email] : [email, excludingUserId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<bool> isStudentIdTaken(String studentId, {int? excludingUserId}) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: excludingUserId == null ? 'studentId = ?' : 'studentId = ? AND id != ?',
      whereArgs:
          excludingUserId == null ? [studentId] : [studentId, excludingUserId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  Future<List<TaskModel>> getTasksForUser(int userId) async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dueDate ASC',
    );

    return result.map(TaskModel.fromMap).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int taskId) async {
    final db = await database;
    return db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }
}
