import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import '../models/decision_model.dart';
import '../utils/app_colors.dart';
import '../widgets/input_cards.dart';
import '../widgets/result_ui_components.dart';

class DecisionLabPage extends StatefulWidget {
  final Function(Decision) onDecisionMade;

  const DecisionLabPage({super.key, required this.onDecisionMade});

  @override
  State<DecisionLabPage> createState() => _DecisionLabPageState();
}

class _DecisionLabPageState extends State<DecisionLabPage> {
  final TextEditingController _optA = TextEditingController();
  final TextEditingController _optB = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();

  bool _isAnalyzing = false;
  bool _isAnswering = false;
  bool _showResults = false;
  Decision? _currentDecision;

  // Tandaan: Mas mabuting ilagay ang API Key sa environment variables (.env)
  final String _apiKey = "YOUR_API_KEY_HERE";

  Future<void> _runGeminiAnalysis() async {
    if (_optA.text.isEmpty || _optB.text.isEmpty) return;
    setState(() {
      _isAnalyzing = true;
      _showResults = false;
    });

    try {
      // Ginabmit ang 'gemini-1.5-flash' dahil ito ang stable version sa 2026
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

      final prompt =
          """Tulungan mo akong mag-decide sa pagitan ng "${_optA.text}" at "${_optB.text}". 
      Sumagot gamit ang sumusunod na format nang eksakto (isang linya bawat key):
      
      PROSA: list of 3 pros separated by comma
      CONSA: list of 3 cons separated by comma
      PROSB: list of 3 pros separated by comma
      CONSB: list of 3 cons separated by comma
      SWOTA: S:text|W:text|O:text|T:text
      SWOTB: S:text|W:text|O:text|T:text
      WINNER: name of choice
      REASON: short justification
      COMPARISON: 1 sentence comparison
      QUESTIONS: question1 | question2""";

      final response = await model.generateContent([Content.text(prompt)]);
      final rawText = response.text ?? "";
      final lines = rawText.split('\n');

      Map<String, String> swotA = {}, swotB = {};
      List<String> pA = [], cA = [], pB = [], cB = [], ques = [];
      String winner = "Walang Napili",
          reason = "Hindi nakapag-generate ng rason.",
          compare = "";

      // Improved Parsing Logic para maiwasan ang RangeError
      for (var line in lines) {
        final cleanLine = line.trim();
        if (cleanLine.startsWith("PROSA:")) {
          pA = cleanLine
              .replaceFirst("PROSA:", "")
              .split(',')
              .map((e) => e.trim())
              .toList();
        } else if (cleanLine.startsWith("CONSA:")) {
          cA = cleanLine
              .replaceFirst("CONSA:", "")
              .split(',')
              .map((e) => e.trim())
              .toList();
        } else if (cleanLine.startsWith("PROSB:")) {
          pB = cleanLine
              .replaceFirst("PROSB:", "")
              .split(',')
              .map((e) => e.trim())
              .toList();
        } else if (cleanLine.startsWith("CONSB:")) {
          cB = cleanLine
              .replaceFirst("CONSB:", "")
              .split(',')
              .map((e) => e.trim())
              .toList();
        } else if (cleanLine.startsWith("SWOTA:")) {
          swotA = _parseSwot(cleanLine.replaceFirst("SWOTA:", ""));
        } else if (cleanLine.startsWith("SWOTB:")) {
          swotB = _parseSwot(cleanLine.replaceFirst("SWOTB:", ""));
        } else if (cleanLine.startsWith("WINNER:")) {
          winner = cleanLine.replaceFirst("WINNER:", "").trim();
        } else if (cleanLine.startsWith("REASON:")) {
          reason = cleanLine.replaceFirst("REASON:", "").trim();
        } else if (cleanLine.startsWith("COMPARISON:")) {
          compare = cleanLine.replaceFirst("COMPARISON:", "").trim();
        } else if (cleanLine.startsWith("QUESTIONS:")) {
          ques = cleanLine
              .replaceFirst("QUESTIONS:", "")
              .split('|')
              .map((e) => e.trim())
              .toList();
        }
      }

      _currentDecision = Decision(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        optionA: _optA.text,
        optionB: _optB.text,
        result: winner,
        justification: reason,
        date: DateFormat('MMM dd, hh:mm a').format(DateTime.now()),
        swotA: swotA,
        swotB: swotB,
        prosA: pA,
        consA: cA,
        prosB: pB,
        consB: cB,
        relatedQuestions: ques,
        comparisonSummary: compare,
        followUps: [],
      );

      widget.onDecisionMade(_currentDecision!);
      setState(() => _showResults = true);
    } catch (e) {
      debugPrint("Error details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Maling format ang naibigay ng AI. Subukan muli."),
        ),
      );
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _askFollowUp() async {
    if (_followUpController.text.isEmpty || _currentDecision == null) return;
    setState(() => _isAnswering = true);
    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final prompt =
          "Base sa choices na ${_currentDecision!.optionA} at ${_currentDecision!.optionB}, sagutin mo: ${_followUpController.text}. Direkta at maikli lang.";
      final response = await model.generateContent([Content.text(prompt)]);
      setState(() {
        _currentDecision!.followUps.add({
          "q": _followUpController.text,
          "a": response.text ?? "Walang sagot mula sa AI.",
        });
        _followUpController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sa follow-up: $e")));
    } finally {
      setState(() => _isAnswering = false);
    }
  }

  Map<String, String> _parseSwot(String raw) {
    final parts = raw.split('|');
    Map<String, String> map = {'S': '', 'W': '', 'O': '', 'T': ''};
    for (var p in parts) {
      final kv = p.split(':');
      if (kv.length >= 2) {
        String key = kv[0].trim().toUpperCase();
        String value = kv
            .sublist(1)
            .join(':')
            .trim(); // Handle cases with multiple colons
        map[key] = value;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ikaw Bahala Lab"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (!_showResults) ...[
              const Text(
                "Timbangin natin gamit ang AI.",
                style: TextStyle(color: AppColors.accent),
              ),
              const SizedBox(height: 30),
              InputCard(
                controller: _optA,
                label: "Option A",
                icon: Icons.auto_awesome,
              ),
              const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "VS",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              InputCard(
                controller: _optB,
                label: "Option B",
                icon: Icons.psychology,
              ),
              const SizedBox(height: 30),
              _buildAnalyzeButton(),
            ] else ...[
              if (_currentDecision != null) buildResultUI(_currentDecision!),
              const SizedBox(height: 20),
              _buildFollowUpSection(),
              const SizedBox(height: 30),
              _buildTryAgainButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: _isAnalyzing ? null : _runGeminiAnalysis,
        icon: const Icon(Icons.bolt),
        label: Text(_isAnalyzing ? "Thinking..." : "Ask Gemini AI"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40, thickness: 1),
        const Text(
          "May pahabol na tanong?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 15),
        if (_currentDecision != null && _currentDecision!.followUps.isNotEmpty)
          ..._currentDecision!.followUps.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        f['q'] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        f['a'] ?? "",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _followUpController,
                decoration: const InputDecoration(
                  hintText: "Tanong...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: _isAnswering ? null : _askFollowUp,
              icon: const Icon(Icons.send, color: AppColors.secondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTryAgainButton() {
    return OutlinedButton.icon(
      onPressed: () => setState(() {
        _showResults = false;
        _optA.clear();
        _optB.clear();
        _currentDecision = null;
      }),
      icon: const Icon(Icons.refresh),
      label: const Text("Try Another Decision"),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: const BorderSide(color: AppColors.accent),
      ),
    );
  }
}
