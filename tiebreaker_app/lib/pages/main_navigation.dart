import 'package:flutter/material.dart';
import '../models/decision_model.dart';
import '../utils/app_colors.dart';
import 'decision_lab_page.dart';
import 'quick_toss_page.dart';
import 'history_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Decision> _history = [];

  void _addDecision(Decision d) {
    setState(() => _history.insert(0, d));
  }

  void _removeFromHistory(String id) {
    setState(() => _history.removeWhere((item) => item.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DecisionLabPage(onDecisionMade: _addDecision),
      const QuickTossPage(),
      HistoryPage(history: _history, onDelete: _removeFromHistory),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.accent,
        backgroundColor: AppColors.shell,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded), label: 'Lab'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bolt_rounded), label: 'Quick'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), label: 'History'),
        ],
      ),
    );
  }
}