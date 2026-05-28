// Un modele représente la structure d'un objet patient tel qu'elle est renvoyée par l'API.
//Chaque champ correspond à une clé du JSON retourné par GET/items/people

class Patient {
  // Identifiant unique du patient dans la base de données Directus
  final int id;

  // Données personnelles optionnelles car l'API peut retourner null
  final String? firstName;
  final String? lastName;
  final String? gender; // 'M' pour masculin, 'F' pour féminin
  final String? birthDate; // Date au format ISO 8601 : "1990-05-14"
  final double? height; // Taille en centimètres
  final double? startWeight; // Poids au début du suivi, en kilogrammes
  final double?
      targetWeight; // Poids objectif fixé avec le professionnel de santé
  final String? email;

  // Le constructeur utilise des paramètres nommés pour plus de lisibilité
  // "required" signifie que le champ est obligatoire à l'instanciation
  Patient({
    required this.id,
    this.firstName,
    this.lastName,
    this.gender,
    this.birthDate,
    this.height,
    this.startWeight,
    this.targetWeight,
    this.email,
  });

  // factory fromJson : méthode de désérialisation
  // Elle convertit un Map<String, dynamic> (issu du JSON) en objet Patient
  // On utilise l'opérateur "as num?" pour gérer le fait que l'API
  // peut retourner un entier ou un double selon le champ
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      birthDate: json['birth_date'],
      // toDouble() convertit num en double pour uniformiser le type
      height: (json['height'] as num?)?.toDouble(),
      startWeight: (json['start_weight'] as num?)?.toDouble(),
      targetWeight: (json['target_weight'] as num?)?.toDouble(),
      email: json['email'],
    );
  }

  // Getter calculé : évite de répéter la concaténation partout dans le code
  // Le .trim() supprime les espaces en cas de prénom ou nom manquant
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  // Calcul de l'âge à partir de la date de naissance
  // On compare l'année courante avec l'année de naissance,
  // puis on soustrait 1 si l'anniversaire n'est pas encore passé cette année
  int get age {
    if (birthDate == null) return 0;
    final birth = DateTime.parse(birthDate!);
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--; // L'anniversaire n'est pas encore passé
    }
    return age;
  }
}
