import 'package:flutter/material.dart';
import '../models/decision_model.dart';
import '../utils/app_colors.dart';

Widget buildResultUI(Decision decision) {
  return Column(
    children: [
      buildBoxResult(decision),
      const SizedBox(height: 25),
      buildCompareBox(decision.comparisonSummary),
      const SizedBox(height: 25),
      buildOptionDetail(
          decision.optionA, decision.prosA, decision.consA, decision.swotA),
      const SizedBox(height: 25),
      buildOptionDetail(
          decision.optionB, decision.prosB, decision.consB, decision.swotB),
      const SizedBox(height: 25),
      buildQSection(decision.relatedQuestions),
    ],
  );
}

Widget buildBoxResult(Decision d) {
  return Container(
    width: double.infinity, padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.accent]),
        borderRadius: BorderRadius.circular(30)),
    child: Column(
      children: [
        const Text("AI RECOMMENDATION", style: TextStyle(
            color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(d.result.toUpperCase(), style: const TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Text(d.justification, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  );
}

Widget buildCompareBox(String text) {
  return Container(padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Text(text, textAlign: TextAlign.center,
          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)));
}

Widget buildOptionDetail(String title, List<String> pros, List<String> cons,
    Map<String, String> swot) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: infoBox(
            "PROS", pros, Colors.green[50]!, Colors.green[800]!)),
        const SizedBox(width: 10),
        Expanded(
            child: infoBox("CONS", cons, Colors.red[50]!, Colors.red[800]!)),
      ]),
      const SizedBox(height: 10),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          swotBox("Strength", swot['S'] ?? ""),
          swotBox("Weakness", swot['W'] ?? ""),
          swotBox("Opportunity", swot['O'] ?? ""),
          swotBox("Threat", swot['T'] ?? ""),
        ],
      ),
    ],
  );
}

Widget infoBox(String label, List<String> items, Color bg, Color tc) {
  return Container(padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: tc)),
            ...items.map((e) =>
                Text("• $e", style: TextStyle(fontSize: 10, color: tc)))
          ]
      )
  );
}

Widget swotBox(String label, String value) {
  return Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.shell, borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
                fontSize: 9, fontWeight: FontWeight.bold)),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 10)))
          ]
      )
  );
}

Widget buildQSection(List<String> qs) {
  return Container(width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Questions to consider:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...qs.map((q) => Text("? $q", style: const TextStyle(fontSize: 12)))
          ]
      )
  );
}