import 'package:flutter/material.dart';
import 'package:get_gains/core/models/workout.dart';
import 'package:get_gains/core/models/exercise.dart';
import 'package:get_gains/core/repositories/workout_repository.dart';
import 'package:get_gains/features/exercise/exercise_details_screen.dart';
import 'package:get_gains/features/exercise/add_exercise_screen.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final String workoutId;

  const WorkoutDetailsScreen({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  final _workoutRepository = WorkoutRepository();
  late Future<Workout> _workoutFuture;

  @override
  void initState() {
    super.initState();
    _workoutFuture = _workoutRepository.getWorkoutById(widget.workoutId);
  }

  void _refreshWorkout() {
    setState(() {
      _workoutFuture = _workoutRepository.getWorkoutById(widget.workoutId);
    });
  }

  Future<void> _addExercise(BuildContext context, Workout workout) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => AddExerciseBottomSheet(workout: workout),
    );

    if (result == true) {
      setState(() {
        _workoutFuture = _workoutRepository.getWorkoutById(widget.workoutId);
      });
    }
  }

  Future<void> _performWorkout(Workout workout) async {
    try {
      // Create a new Workout object with updated lastPerformed
      final updatedWorkout = workout.copyWith(
          lastPerformed: DateTime.now().millisecondsSinceEpoch);

      await _workoutRepository.performWorkout(updatedWorkout);

      _refreshWorkout(); // Refresh the workout details

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout completed!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Workout>(
      future: _workoutFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error loading workout: ${snapshot.error}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          );
        }

        final workout = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(workout.name),
            centerTitle: true,
            actions: [
              FilledButton.icon(
                onPressed: workout.exercises.isEmpty
                    ? null
                    : () => _performWorkout(workout),
                icon: const Icon(Icons.fitness_center),
                label: const Text('Perform'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: workout.exercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No exercises yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add exercises to get started',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: workout.exercises.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final exercise = workout.exercises[index];
                    return ExerciseCard(exercise: exercise);
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addExercise(context, workout),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCard({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseDetailsScreen(
                  exercise: exercise,
                  onExerciseUpdated: () {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: exercise.musclesWorked.map((muscle) {
                    return Chip(
                      label: Text(muscle.displayName),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ExerciseDetail(
                      label: 'Sets',
                      value: exercise.sets?.toString() ?? '-',
                    ),
                    _ExerciseDetail(
                      label: 'Reps',
                      value: exercise.reps?.toString() ?? '-',
                    ),
                    _ExerciseDetail(
                      label: 'Weight',
                      value: exercise.weight != null
                          ? '${exercise.weight}kg'
                          : '-',
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class _ExerciseDetail extends StatelessWidget {
  final String label;
  final String value;

  const _ExerciseDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class AddExerciseBottomSheet extends StatefulWidget {
  final Workout workout;

  const AddExerciseBottomSheet({
    super.key,
    required this.workout,
  });

  @override
  State<AddExerciseBottomSheet> createState() => _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<AddExerciseBottomSheet> {
  final _workoutRepository = WorkoutRepository();
  late Future<List<Exercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _workoutRepository.getAllExercises();
  }

  Future<void> _addNewExercise() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExerciseScreen(),
      ),
    );

    if (result == true) {
      setState(() {
        _exercisesFuture = _workoutRepository.getAllExercises();
      });
    }
  }

  Future<void> _addExistingExercise(Exercise exercise) async {
    final updatedExercises = [...widget.workout.exercises, exercise];
    await _workoutRepository.updateWorkoutExercises(
      widget.workout.id,
      updatedExercises,
    );
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Exercise',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Create New Exercise'),
              onTap: _addNewExercise,
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<Exercise>>(
                future: _exercisesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading exercises: ${snapshot.error}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }

                  final exercises = snapshot.data!;
                  final availableExercises = exercises
                      .where(
                        (e) => !widget.workout.exercises
                            .any((we) => we.id == e.id),
                      )
                      .toList();

                  if (availableExercises.isEmpty) {
                    return const Center(
                      child: Text('No available exercises to add'),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: availableExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = availableExercises[index];
                      return ListTile(
                        title: Text(exercise.name),
                        subtitle: Text(
                          exercise.musclesWorked
                              .map((m) => m.displayName)
                              .join(', '),
                        ),
                        onTap: () => _addExistingExercise(exercise),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
