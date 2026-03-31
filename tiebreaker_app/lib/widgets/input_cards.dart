import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class InputCard extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const InputCard({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: AppColors.accent.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon, color: AppColors.accent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 20, horizontal: 10),
        ),
      ),
    );
  }
}