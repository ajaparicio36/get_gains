// lib/core/widgets/floating_timer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';

class FloatingTimer extends StatelessWidget {
  const FloatingTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerService>(
      builder: (context, timerService, child) {
        if (!timerService.isRunning && !timerService.isPaused) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 100,
          right: 20,
          child: GestureDetector(
            onTap: () {
              // Navigate to timer screen if needed
              // Navigator.pushNamed(context, '/timer');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                timerService.formattedTime,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
