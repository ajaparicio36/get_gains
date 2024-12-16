// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_gains/core/services/timer_service.dart';
import 'package:get_gains/features/main/main_screen.dart';
import 'package:get_gains/theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TimerService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Get Gains',
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
