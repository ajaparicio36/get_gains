import 'package:get_gains/core/models/exercise.dart';
import 'package:get_gains/core/models/workout.dart';
import 'package:get_gains/core/constants/muscles.dart';
import 'package:get_gains/core/database/database_helper.dart';

class WorkoutRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> createWorkout(Workout workout) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Insert workout
      await txn.insert('workouts', workout.toMap());

      // Insert exercises
      for (final exercise in workout.exercises) {
        await txn.insert('exercises', exercise.toMap());

        // Insert muscles for each exercise
        for (final muscle in exercise.musclesWorked) {
          await txn.insert('exercise_muscles', {
            'exercise_id': exercise.id,
            'muscle': muscle.name,
          });
        }
      }
    });
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await _databaseHelper.database;
    final workouts = await db.query('workouts');

    return Future.wait(workouts.map((workout) async {
      final exercises = await db.query(
        'exercises',
        where: 'workout_id = ?',
        whereArgs: [workout['id']],
      );

      final workoutExercises =
          await Future.wait(exercises.map((exercise) async {
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

      return Workout.fromMap(workout, workoutExercises);
    }));
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

  Future<void> addExercise(Exercise exercise) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Insert exercise
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
}
