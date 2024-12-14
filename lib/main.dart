import 'package:flutter/material.dart';
import 'package:get_gains/theme/app_theme.dart';
import 'package:get_gains/features/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Get Gains',
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
