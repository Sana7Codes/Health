// Modèle représentant un patient tel que renvoyé par l'API (GET /items/people).
// Les noms de champs correspondent exactement aux clés du JSON de l'API Directus.

class Patient {
  // Identifiant unique : l'API renvoie un UUID (chaîne de caractères), pas un entier.
  final String id;

  // Données personnelles (optionnelles car l'API peut renvoyer null ou une chaîne vide).
  final String? firstName; // clé JSON : "firstname"
  final String? lastName; // clé JSON : "lastname"
  final int? sex; // clé JSON : "sex" — entier (ex : 1)
  final int? birthYear; // clé JSON : "birthyear" — année de naissance
  final double? height; // taille en centimètres
  final double? startWeight; // clé JSON : "weightStart"
  final double? targetWeight; // clé JSON : "weightGoal"
  final String? activityProfile; // clé JSON : "activityProfile" (ex : "sedentary")
  final String? bmiStart; // clé JSON : "bmiStart"
  final String? bmiGoal; // clé JSON : "bmiGoal"

  Patient({
    required this.id,
    this.firstName,
    this.lastName,
    this.sex,
    this.birthYear,
    this.height,
    this.startWeight,
    this.targetWeight,
    this.activityProfile,
    this.bmiStart,
    this.bmiGoal,
  });

  // Désérialisation : convertit le Map<String, dynamic> issu du JSON en objet Patient.
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      // L'id est un UUID : on le force en String pour rester robuste.
      id: json['id'].toString(),
      firstName: json['firstname'] as String?,
      lastName: json['lastname'] as String?,
      sex: _toInt(json['sex']),
      birthYear: _toInt(json['birthyear']),
      // toDouble() uniformise le type (l'API peut renvoyer int ou double).
      height: (json['height'] as num?)?.toDouble(),
      startWeight: (json['weightStart'] as num?)?.toDouble(),
      targetWeight: (json['weightGoal'] as num?)?.toDouble(),
      activityProfile: json['activityProfile'] as String?,
      bmiStart: json['bmiStart'] as String?,
      bmiGoal: json['bmiGoal'] as String?,
    );
  }

  // Conversion sécurisée vers int (gère null, int, double, String).
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  // Nom complet : évite de répéter la concaténation partout dans le code.
  // .trim() supprime les espaces si le prénom ou le nom est manquant.
  String get fullName {
    final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    // L'API renvoie souvent des noms vides : on affiche alors l'id abrégé.
    return name.isNotEmpty ? name : 'Patient ${id.substring(0, 8)}';
  }

  // Libellé lisible du sexe (l'API renvoie un entier).
  String get genderLabel {
    switch (sex) {
      case 1:
        return 'Homme';
      case 2:
        return 'Femme';
      default:
        return 'Non précisé';
    }
  }

  // Âge calculé à partir de l'année de naissance.
  // Retourne null si l'année est absente (l'écran peut alors afficher "Âge inconnu").
  int? get age {
    if (birthYear == null || birthYear == 0) return null;
    return DateTime.now().year - birthYear!;
  }
}