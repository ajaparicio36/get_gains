import 'package:flutter/material.dart';
import 'package:get_gains/core/models/exercise.dart';
import 'package:get_gains/core/repositories/workout_repository.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback? onExerciseUpdated;

  const ExerciseDetailsScreen({
    super.key,
    required this.exercise,
    this.onExerciseUpdated,
  });

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _setsController =
        TextEditingController(text: widget.exercise.sets?.toString() ?? '');
    _repsController =
        TextEditingController(text: widget.exercise.reps?.toString() ?? '');
    _weightController =
        TextEditingController(text: widget.exercise.weight?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedExercise = widget.exercise.copyWith(
        name: _nameController.text.trim(),
        sets: _setsController.text.isNotEmpty
            ? int.parse(_setsController.text)
            : null,
        reps: _repsController.text.isNotEmpty
            ? int.parse(_repsController.text)
            : null,
        weight: _weightController.text.isNotEmpty
            ? double.parse(_weightController.text)
            : null,
      );

      await WorkoutRepository().updateExercise(updatedExercise);

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise updated successfully')),
        );
        widget.onExerciseUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value != null && value.isNotEmpty) {
      final number = num.tryParse(value);
      if (number == null) {
        return 'Please enter a valid number';
      }
      if (number < 0) {
        return '$fieldName cannot be negative';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Details'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an exercise name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            Text(
              'Muscles Worked',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.exercise.musclesWorked.map((muscle) {
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

            const SizedBox(height: 24),

            Text(
              'Default Values',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Sets input
            TextFormField(
              controller: _setsController,
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sets',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateNumber(value, 'Sets'),
            ),
            const SizedBox(height: 16),

            // Reps input
            TextFormField(
              controller: _repsController,
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateNumber(value, 'Reps'),
            ),
            const SizedBox(height: 16),

            // Weight input
            TextFormField(
              controller: _weightController,
              enabled: _isEditing,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateNumber(value, 'Weight'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isEditing
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveExercise,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            )
          : null,
    );
  }
}
