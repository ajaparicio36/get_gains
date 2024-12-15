import 'package:flutter/material.dart';
import 'package:get_gains/theme/app_theme.dart';
import 'package:get_gains/features/main/main_screen.dart';

void main() {
  runApp(const MyApp());
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
