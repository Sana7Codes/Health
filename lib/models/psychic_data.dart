class PsychicData {
  final int id;
  final String patientId;
  final DateTime? date;
  final int? moodScore;
  final int? stressLevel;
  final double? sleepHours;
  final String? notes;

  PsychicData({
    required this.id,
    required this.patientId,
    this.date,
    this.moodScore,
    this.stressLevel,
    this.sleepHours,
    this.notes,
  });

  factory PsychicData.fromJson(Map<String, dynamic> json) {
    final pid = json['people_id'];
    final pidStr = pid is Map ? pid['id'].toString() : pid.toString();
    final rawDate = json['date'] ?? json['date_created'];
    return PsychicData(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      patientId: pidStr,
      date: rawDate != null ? DateTime.tryParse(rawDate.toString()) : null,
      moodScore: _toInt(json['mood_score']),
      stressLevel: _toInt(json['stress_level']),
      sleepHours: _toDouble(json['sleep_hours']),
      notes: json['notes']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
