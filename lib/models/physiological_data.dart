class PhysiologicalData {
  final int id;
  final String patientId;
  final DateTime? date;
  final double? weight;

  PhysiologicalData({
    required this.id,
    required this.patientId,
    this.date,
    this.weight,
  });

  factory PhysiologicalData.fromJson(Map<String, dynamic> json) {
    final pid = json['people_id'];
    final pidStr = pid is Map ? pid['id'].toString() : pid.toString();
    return PhysiologicalData(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      patientId: pidStr,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,
      weight: _toDouble(json['weight']),
    );
  }
// La méthode _toDouble gère les différentes représentations JSON(null, int, double, String) pour les valeurs numériques et les convertit en double de manière sécurisée.
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
