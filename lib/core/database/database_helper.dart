import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'get_gains.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Workouts table
    await db.execute('''
      CREATE TABLE workouts(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        last_performed TEXT
      )
    ''');

    // Exercises table
    await db.execute('''
      CREATE TABLE exercises(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL NOT NULL,
        sets INTEGER NOT NULL,
        workout_id TEXT NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''');

    // Exercise Muscles table (junction table for many-to-many relationship)
    await db.execute('''
      CREATE TABLE exercise_muscles(
        exercise_id TEXT NOT NULL,
        muscle TEXT NOT NULL,
        PRIMARY KEY (exercise_id, muscle),
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');
  }
}
