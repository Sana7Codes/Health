class PhysicalActivity {
  // Identifiant unique pour chaque enregistrement de l'activité physique
  final int id;
  final String patientId;
  final DateTime? date;
  final int? steps;
  final int? duration;
  final int? calories;
  final String? activityType;

// Le constructeur utilise des paramètres nommés pour plus de clarté
  PhysicalActivity({
    required this.id,
    required this.patientId,
    this.date,
    this.steps,
    this.duration,
    this.calories,
    this.activityType,
  });

// La méthode fromJson convertit un Map<String, dynamic> (issu du JSON) en objet PhysicalActivity
  factory PhysicalActivity.fromJson(Map<String, dynamic> json) {
    final pid = json['people_id'];
    final pidStr = pid is Map ? pid['id'].toString() : pid.toString();
    return PhysicalActivity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      patientId: pidStr,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,
      steps: _toInt(json['numberOfSteps']),
      duration: _toInt(json['duration']),
      calories: _toInt(json['consumedCalories']),
      activityType: json['type']?.toString(),
    );
  }

// La méthode _toInt gère les différentes façons dont les nombres peuvent être représentés dans le JSON (int, double, ou String) et les convertit en int de manière sécurisée
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}
