import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_gains/core/models/workout.dart';
import 'package:get_gains/core/repositories/workout_repository.dart';
import 'package:get_gains/features/workout/add_workout_screen.dart';
import 'package:get_gains/features/workout/workout_details_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Get Gains',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Workout>>(
        future: WorkoutRepository().getAllWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading workouts: ${snapshot.error}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }

          final workouts = snapshot.data ?? [];

          if (workouts.isEmpty) {
            return Center(
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
                    'No workouts yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your first workout to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddWorkoutScreen(),
                        ),
                      );

                      if (result == true) {
                        setState(() {}); // Refresh the workout list
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Workout'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    workout.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: workout.lastPerformed != null
                      ? Text(
                          'Last performed: ${DateFormat('MMM d, y').format(DateTime.fromMillisecondsSinceEpoch(workout.lastPerformed!))}',
                          style: const TextStyle(color: Colors.grey),
                        )
                      : const Text(
                          'Never performed',
                          style: TextStyle(color: Colors.grey),
                        ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutDetailsScreen(
                          workoutId: workout.id,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddWorkoutScreen(),
            ),
          );

          if (result == true) {
            setState(() {}); // Refresh the workout list
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
