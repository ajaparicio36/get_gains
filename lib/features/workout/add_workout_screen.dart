import 'package:flutter/material.dart';
import 'package:get_gains/core/models/workout.dart';
import 'package:get_gains/core/models/exercise.dart';
import 'package:get_gains/core/repositories/workout_repository.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workoutRepository = WorkoutRepository();
  final _nameController = TextEditingController();
  final List<Exercise> _selectedExercises = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    final exercises = await _workoutRepository.getAllExercises();

    if (!mounted) return;

    final result = await showModalBottomSheet<Exercise>(
      context: context,
      builder: (context) => _SelectExerciseBottomSheet(
        exercises: exercises,
        selectedExercises: _selectedExercises,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedExercises.add(result);
      });
    }
  }

  void _removeExercise(Exercise exercise) {
    setState(() {
      _selectedExercises.removeWhere((e) => e.id == exercise.id);
    });
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final workout = Workout(
        name: _nameController.text.trim(),
        exercises: _selectedExercises,
      );
      await _workoutRepository.createWorkout(workout);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                hintText: 'Enter workout name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a workout name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                FilledButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedExercises.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No exercises added yet. Tap the button above to add exercises.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedExercises.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final exercise = _selectedExercises[index];
                  return Card(
                    child: ListTile(
                      title: Text(exercise.name),
                      subtitle: Text(
                        exercise.musclesWorked
                            .map((m) => m.displayName)
                            .join(', '),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeExercise(exercise),
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _isSaving ? null : _saveWorkout,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Workout'),
          ),
        ),
      ),
    );
  }
}

class _SelectExerciseBottomSheet extends StatelessWidget {
  final List<Exercise> exercises;
  final List<Exercise> selectedExercises;

  const _SelectExerciseBottomSheet({
    required this.exercises,
    required this.selectedExercises,
  });

  @override
  Widget build(BuildContext context) {
    final availableExercises = exercises
        .where((e) => !selectedExercises.any((se) => se.id == e.id))
        .toList();

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
                    'Select Exercise',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            if (availableExercises.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No available exercises. Create new exercises first.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: availableExercises.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final exercise = availableExercises[index];
                    return ListTile(
                      title: Text(exercise.name),
                      subtitle: Text(
                        exercise.musclesWorked
                            .map((m) => m.displayName)
                            .join(', '),
                      ),
                      onTap: () => Navigator.pop(context, exercise),
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
