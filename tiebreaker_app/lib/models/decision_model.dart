class Decision {
  final String id;
  final String optionA;
  final String optionB;
  final String result;
  final String justification;
  final String date;

  final Map<String, String> swotA;
  final Map<String, String> swotB;
  final List<String> prosA;
  final List<String> consA;
  final List<String> prosB;
  final List<String> consB;
  final List<String> relatedQuestions;
  final String comparisonSummary;
  final List<Map<String, String>> followUps;

  Decision({
    required this.id, required this.optionA, required this.optionB,
    required this.result, required this.justification, required this.date,
    required this.swotA, required this.swotB,
    required this.prosA, required this.consA,
    required this.prosB, required this.consB,
    required this.relatedQuestions,
    required this.comparisonSummary,
    this.followUps = const [],
  });
}