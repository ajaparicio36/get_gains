import 'package:uuid/uuid.dart';
import 'package:get_gains/core/models/exercise.dart';

class Workout {
  final String id;
  final String name;
  final DateTime? lastPerformed;
  final List<Exercise> exercises;

  Workout({
    String? id,
    required this.name,
    this.lastPerformed,
    this.exercises = const [],
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'last_performed': lastPerformed?.toIso8601String(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map, List<Exercise> exercises) {
    return Workout(
      id: map['id'],
      name: map['name'],
      lastPerformed: map['last_performed'] != null
          ? DateTime.parse(map['last_performed'])
          : null,
      exercises: exercises,
    );
  }
}
