// lib/features/timer/timer_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:get_gains/core/services/timer_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _minutes = 0;
  int _seconds = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerService>(
      builder: (context, timerService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Timer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!timerService.isRunning && !timerService.isPaused)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Minutes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            NumberPicker(
                              value: _minutes,
                              minValue: 0,
                              maxValue: 59,
                              itemHeight: 60,
                              itemWidth: 80,
                              infiniteLoop: true,
                              decoration: BoxDecoration(
                                border: Border.symmetric(
                                  horizontal: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) =>
                                  setState(() => _minutes = value),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            const Text(
                              'Seconds',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            NumberPicker(
                              value: _seconds,
                              minValue: 0,
                              maxValue: 59,
                              itemHeight: 60,
                              itemWidth: 80,
                              infiniteLoop: true,
                              decoration: BoxDecoration(
                                border: Border.symmetric(
                                  horizontal: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) =>
                                  setState(() => _seconds = value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    timerService.formattedTime,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!timerService.isRunning && !timerService.isPaused)
                      ElevatedButton.icon(
                        onPressed: () =>
                            timerService.startTimer(_minutes, _seconds),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                        ),
                      )
                    else ...[
                      ElevatedButton.icon(
                        onPressed: timerService.isPaused
                            ? timerService.resumeTimer
                            : timerService.pauseTimer,
                        icon: Icon(timerService.isPaused
                            ? Icons.play_arrow
                            : Icons.pause),
                        label: Text(timerService.isPaused ? 'Resume' : 'Pause'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: timerService.stopTimer,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
