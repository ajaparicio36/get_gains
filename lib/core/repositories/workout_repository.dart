import 'package:get_gains/core/models/exercise.dart';
import 'package:get_gains/core/models/workout.dart';
import 'package:get_gains/core/constants/muscles.dart';
import 'package:get_gains/core/database/database_helper.dart';

class WorkoutRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Exercise Template Methods
  Future<void> addExercise(Exercise exercise) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Insert exercise template
      await txn.insert('exercises', exercise.toMap());

      // Insert muscles
      for (final muscle in exercise.musclesWorked) {
        await txn.insert('exercise_muscles', {
          'exercise_id': exercise.id,
          'muscle': muscle.name,
        });
      }
    });
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await _databaseHelper.database;
    final exercises = await db.query('exercises');

    return Future.wait(exercises.map((exercise) async {
      final muscles = await db.query(
        'exercise_muscles',
        where: 'exercise_id = ?',
        whereArgs: [exercise['id']],
      );

      final musclesList = muscles
          .map((m) => Muscles.values.firstWhere((e) => e.name == m['muscle']))
          .toList();

      return Exercise.fromMap(exercise, musclesList);
    }));
  }

  // Workout Methods
  Future<void> createWorkout(Workout workout) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Insert workout
      await txn.insert('workouts', workout.toMap());

      // Insert workout exercises
      for (var i = 0; i < workout.exercises.length; i++) {
        final exercise = workout.exercises[i].copyWith(orderIndex: i);
        await txn.insert(
          'workout_exercises',
          exercise.toWorkoutExerciseMap(workout.id),
        );
      }
    });
  }

  Future<void> updateExercise(Exercise exercise) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Update exercise template
      await txn.update(
        'exercises',
        exercise.toMap(),
        where: 'id = ?',
        whereArgs: [exercise.id],
      );

      // Update workout exercises with the same exercise_id
      await txn.update(
        'workout_exercises',
        {
          'sets': exercise.sets ?? 0,
          'reps': exercise.reps ?? 0,
          'weight': exercise.weight ?? 0,
        },
        where: 'exercise_id = ?',
        whereArgs: [exercise.id],
      );
    });
  }

  Future<Workout> getWorkoutById(String workoutId) async {
    final db = await _databaseHelper.database;
    final workouts = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [workoutId],
    );

    if (workouts.isEmpty) {
      throw Exception('Workout not found');
    }

    final workoutMap = Map<String, dynamic>.from(workouts.first);

    final workoutExercises = await _getWorkoutExercises(workoutId);
    return Workout.fromMap(workoutMap, workoutExercises);
  }

  Future<List<Exercise>> _getWorkoutExercises(String workoutId) async {
    final db = await _databaseHelper.database;
    final exercises = await db.rawQuery('''
      SELECT 
        e.*,
        we.sets,
        we.reps,
        we.weight,
        we.order_index
      FROM workout_exercises we
      JOIN exercises e ON e.id = we.exercise_id
      WHERE we.workout_id = ?
      ORDER BY we.order_index
    ''', [workoutId]);

    return Future.wait(exercises.map((exercise) async {
      final muscles = await db.query(
        'exercise_muscles',
        where: 'exercise_id = ?',
        whereArgs: [exercise['id']],
      );

      final musclesList = muscles
          .map((m) => Muscles.values.firstWhere((e) => e.name == m['muscle']))
          .toList();

      return Exercise.fromMap(exercise, musclesList);
    }));
  }

  Future<void> updateWorkoutExercises(
      String workoutId, List<Exercise> exercises) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Delete existing workout exercises
      await txn.delete(
        'workout_exercises',
        where: 'workout_id = ?',
        whereArgs: [workoutId],
      );

      // Insert updated exercises
      for (var i = 0; i < exercises.length; i++) {
        final exercise = exercises[i].copyWith(orderIndex: i);
        await txn.insert(
          'workout_exercises',
          exercise.toWorkoutExerciseMap(workoutId),
        );
      }
    });
  }

  Future<void> updateWorkout(Workout workout) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'workouts',
        workout.toMap(),
        where: 'id = ?',
        whereArgs: [workout.id],
      );
      await updateWorkoutExercises(workout.id, workout.exercises);
    });
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await _databaseHelper.database;
    final workouts = await db.query('workouts');

    return Future.wait(workouts.map((workout) async {
      final exercises = await _getWorkoutExercises(workout['id'] as String);
      return Workout.fromMap(workout, exercises);
    }));
  }

  Future<void> performWorkout(Workout workout) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Convert DateTime to milliseconds since epoch for storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Prepare the map explicitly
      final updateMap = <String, dynamic>{
        'last_performed': timestamp,
      };

      await txn.update(
        'workouts',
        updateMap,
        where: 'id = ?',
        whereArgs: [workout.id],
      );
    });
  }
}
