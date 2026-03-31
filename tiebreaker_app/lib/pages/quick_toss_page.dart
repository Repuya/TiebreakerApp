import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/app_colors.dart';

class QuickTossPage extends StatefulWidget {
  const QuickTossPage({super.key});

  @override State<QuickTossPage> createState() => _QuickTossPageState();
}

class _QuickTossPageState extends State<QuickTossPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String result = "TAP";

  @override void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  void _flip() async {
    _controller.repeat();
    await Future.delayed(const Duration(seconds: 1));
    _controller.stop();
    setState(() => result = Random().nextBool() ? "OO" : "HINDI");
  }

  @override Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("Random Na Desisyon"),
          const SizedBox(height: 50),
          GestureDetector(onTap: _flip,
              child: RotationTransition(turns: _controller,
                  child: Container(width: 180,
                      height: 180,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.accent])),
                      child: Center(child: Text(result, style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.w900))))))
        ]));
  }

  @override void dispose() {
    _controller.dispose();
    super.dispose();
  }
}