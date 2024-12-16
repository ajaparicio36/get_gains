// lib/features/main/main_screen.dart

import 'package:flutter/material.dart';
import 'package:get_gains/features/workout/workout_screen.dart';
import 'package:get_gains/features/exercise/exercise_screen.dart';
import 'package:get_gains/features/timer/timer_screen.dart';
import 'package:get_gains/core/widgets/floating_timer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    WorkoutScreen(),
    ExerciseScreen(),
    TimerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          const FloatingTimer(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_gymnastics),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
        ],
      ),
    );
  }
}
