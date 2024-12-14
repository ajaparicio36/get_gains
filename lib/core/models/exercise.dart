import 'package:uuid/uuid.dart';
import 'package:get_gains/core/constants/muscles.dart';

class Exercise {
  final String id;
  final String name;
  final List<Muscles> musclesWorked;
  final int reps;
  final double weight;
  final int sets;
  final String workoutId;

  Exercise({
    String? id,
    required this.name,
    required this.musclesWorked,
    required this.reps,
    required this.weight,
    required this.sets,
    required this.workoutId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reps': reps,
      'weight': weight,
      'sets': sets,
      'workout_id': workoutId,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map, List<Muscles> muscles) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      musclesWorked: muscles,
      reps: map['reps'],
      weight: map['weight'],
      sets: map['sets'],
      workoutId: map['workout_id'],
    );
  }
}
