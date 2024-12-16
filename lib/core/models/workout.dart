import 'package:uuid/uuid.dart';
import 'package:get_gains/core/models/exercise.dart';

class Workout {
  final String id;
  final String name;
  final int? lastPerformed;
  final List<Exercise> exercises;

  Workout({
    String? id,
    required this.name,
    this.lastPerformed,
    this.exercises = const [],
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'last_performed': lastPerformed};
  }

  factory Workout.fromMap(Map<String, dynamic> map, List<Exercise> exercises) {
    return Workout(
      id: map['id'],
      name: map['name'],
      lastPerformed: map['last_performed'],
      exercises: exercises,
    );
  }

  Workout copyWith({
    String? id,
    String? name,
    int? lastPerformed,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      exercises: exercises ?? this.exercises,
    );
  }
}
