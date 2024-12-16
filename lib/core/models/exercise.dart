import 'package:uuid/uuid.dart';
import 'package:get_gains/core/constants/muscles.dart';

class Exercise {
  final String id;
  final String name;
  final List<Muscles> musclesWorked;
  final int? sets;
  final int? reps;
  final double? weight;
  final int? orderIndex;

  Exercise({
    String? id,
    required this.name,
    required this.musclesWorked,
    this.sets,
    this.reps,
    this.weight,
    this.orderIndex,
  }) : id = id ?? const Uuid().v4();

  Exercise copyWith({
    String? id,
    String? name,
    List<Muscles>? musclesWorked,
    int? sets,
    int? reps,
    double? weight,
    int? orderIndex,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      musclesWorked: musclesWorked ?? this.musclesWorked,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'order_index': orderIndex,
    };
  }

  Map<String, dynamic> toWorkoutExerciseMap(String workoutId) {
    return {
      'id': const Uuid().v4(),
      'workout_id': workoutId,
      'exercise_id': id,
      'sets': sets ?? 0,
      'reps': reps ?? 0,
      'weight': weight ?? 0,
      'order_index': orderIndex ?? 0,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map, List<Muscles> muscles) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      musclesWorked: muscles,
      sets: map['sets'] as int?,
      reps: map['reps'] as int?,
      weight: map['weight'] == null ? null : (map['weight'] as num).toDouble(),
      orderIndex: map['order_index'] as int?,
    );
  }
}
