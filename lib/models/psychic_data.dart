/// Donnée psychique telle que renvoyée par l'API (endpoint privé /items/psychicData).
///
/// Structure réelle d'un enregistrement :
///   {"id":1562, "people_id":"<uuid>", "feeling":"addicted", "date":"2023-12-15"}
///
/// `feeling` est une CATÉGORIE textuelle (ex : "addicted", "enduring", "happy"…),
/// et non un score numérique. On ne peut donc pas en faire une moyenne :
/// la visualisation adaptée est une répartition (comptage par catégorie).
class PsychicData {
  final int id;
  final String patientId;
  final String? feeling;
  final DateTime? date;

  PsychicData({
    required this.id,
    required this.patientId,
    this.feeling,
    this.date,
  });

  factory PsychicData.fromJson(Map<String, dynamic> json) {
    // people_id peut arriver sous forme de chaîne (uuid) ou d'objet imbriqué.
    final pid = json['people_id'];
    final pidStr = pid is Map ? pid['id'].toString() : pid.toString();

    final rawDate = json['date'] ?? json['date_created'];

    return PsychicData(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      patientId: pidStr,
      feeling: json['feeling']?.toString(),
      date: rawDate != null ? DateTime.tryParse(rawDate.toString()) : null,
    );
  }
}