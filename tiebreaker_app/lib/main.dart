import 'package:flutter/material.dart';
import 'utils/app_colors.dart';
import 'pages/main_navigation.dart';

void main() {
  runApp(const IkawBahalaApp());
}

class IkawBahalaApp extends StatelessWidget {
  const IkawBahalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ikaw Bahala',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}