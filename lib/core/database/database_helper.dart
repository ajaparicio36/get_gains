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
    String path = join(await getDatabasesPath(), 'get_gains_prod_4.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Workouts table
    await db.execute('''
    CREATE TABLE workouts(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      last_performed INTEGER
    )
    ''');

    // Exercises table (template exercises)
    await db.execute('''
    CREATE TABLE exercises(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      sets INTEGER,
      reps INTEGER,
      weight REAL,
      order_index INTEGER
    )
    ''');

    // Exercise Muscles table (for template exercises)
    await db.execute('''
    CREATE TABLE exercise_muscles(
      exercise_id TEXT NOT NULL,
      muscle TEXT NOT NULL,
      PRIMARY KEY (exercise_id, muscle),
      FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
    )
    ''');

    // Workout Exercises table (junction table with exercise details for each workout)
    await db.execute('''
    CREATE TABLE workout_exercises(
      id TEXT PRIMARY KEY,
      workout_id TEXT NOT NULL,
      exercise_id TEXT NOT NULL,
      sets INTEGER NOT NULL,
      reps INTEGER NOT NULL,
      weight REAL NOT NULL,
      order_index INTEGER NOT NULL,
      FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE,
      FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
    )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Backup existing data
      final exercises = await db.query('exercises');
      final muscles = await db.query('exercise_muscles');

      // Drop existing tables
      await db.execute('DROP TABLE IF EXISTS exercise_muscles');
      await db.execute('DROP TABLE IF EXISTS exercises');
      await db.execute('DROP TABLE IF EXISTS workout_exercises');

      // Create new tables
      await db.execute('''
        CREATE TABLE exercises(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE exercise_muscles(
          exercise_id TEXT NOT NULL,
          muscle TEXT NOT NULL,
          PRIMARY KEY (exercise_id, muscle),
          FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE workout_exercises(
          id TEXT PRIMARY KEY,
          workout_id TEXT NOT NULL,
          exercise_id TEXT NOT NULL,
          sets INTEGER NOT NULL,
          reps INTEGER NOT NULL,
          weight REAL NOT NULL,
          order_index INTEGER NOT NULL,
          FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE,
          FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
        )
      ''');

      // Restore exercises data
      for (final exercise in exercises) {
        final newExercise = {
          'id': exercise['id'],
          'name': exercise['name'],
        };
        await db.insert('exercises', newExercise);
      }

      // Restore muscles data
      for (final muscle in muscles) {
        await db.insert('exercise_muscles', muscle as Map<String, dynamic>);
      }
    }
  }
}
