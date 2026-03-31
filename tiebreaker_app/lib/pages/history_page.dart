import 'package:flutter/material.dart';
import '../models/decision_model.dart';
import '../utils/app_colors.dart';
import '../widgets/result_ui_components.dart';

class HistoryPage extends StatelessWidget {
  final List<Decision> history;
  final Function(String) onDelete;

  const HistoryPage({super.key, required this.history, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History"), centerTitle: true),
      body: history.isEmpty ? const Center(
          child: Text("Wala ka pang nade-decide.")) : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return Dismissible(
            key: Key(item.id),
            onDismissed: (_) => onDelete(item.id),
            background: Container(color: Colors.red[300],
                child: const Icon(Icons.delete, color: Colors.white)),
            child: Card(
              color: AppColors.shell,
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(
                        builder: (c) => DecisionDetailView(decision: item))),
                title: Text("${item.optionA} vs ${item.optionB}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Winner: ${item.result}\n${item.date}"),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DecisionDetailView extends StatelessWidget {
  final Decision decision;

  const DecisionDetailView({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analysis Detail")),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(24), child: buildResultUI(decision)),
    );
  }
}