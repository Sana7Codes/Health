import 'package:dio/dio.dart';

import '../models/physical_activity.dart';
import '../models/physiological_data.dart';
import '../models/psychic_data.dart';
import 'api_service.dart';

/// Service de récupération des données physiologiques, activités et psychiques.
class DataService {
<<<<<<< HEAD
  final Dio _dio = ApiService().dio;

  Future<List<PhysiologicalData>> fetchPhysiological(String patientId,
      {int limit = 200}) async {
    final response =
        await _dio.get('/items/physiologicalData', queryParameters: {
      'filter[people_id][_eq]': patientId,
      'sort': 'date',
      'limit': limit,
    });
    final List<dynamic> list = response.data['data'] ?? [];
=======
  // Instance Dio partagée, configurée dans ApiService (URL de base, en-têtes, etc.)
  final Dio _dio = ApiService().dio;

  /// Récupère les données physiologiques d'un patient donné.
  /// [patientId] : identifiant du patient à filtrer.
  /// [limit] : nombre maximum d'enregistrements à retourner (200 par défaut).
  Future<List<PhysiologicalData>> fetchPhysiological(String patientId,
      {int limit = 200}) async {
    // Requête GET vers l'endpoint, filtrée par patient et triée par date.
    final response = await _dio.get('/items/physiologicalData',
        queryParameters: {
          'filter[people_id][_eq]': patientId, // Filtre : ne garder que ce patient
          'sort': 'date', // Tri chronologique
          'limit': limit, // Limite du nombre de résultats
        });
    // On extrait la liste sous la clé 'data' ; liste vide si absente.
    final List<dynamic> list = response.data['data'] ?? [];
    // On ne garde que les éléments de type Map, puis on les convertit en objets typés.
>>>>>>> e741175fd9008d80f27a26c1f34ebdddec41a945
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PhysiologicalData.fromJson(e))
        .toList();
  }

<<<<<<< HEAD
  Future<List<PhysicalActivity>> fetchActivities(String patientId,
      {int limit = 200}) async {
    final response =
        await _dio.get('/items/physicalActivities', queryParameters: {
      'filter[people_id][_eq]': patientId,
      'sort': 'date',
      'limit': limit,
    });
    final List<dynamic> list = response.data['data'] ?? [];
=======
  /// Récupère les activités physiques d'un patient donné.
  Future<List<PhysicalActivity>> fetchActivities(String patientId,
      {int limit = 200}) async {

    final response = await _dio.get('/items/physicalActivities',
        queryParameters: {
          'filter[people_id][_eq]': patientId, 
          'sort': 'date',
          'limit': limit, 
        });
   
    final List<dynamic> list = response.data['data'] ?? [];
    
>>>>>>> e741175fd9008d80f27a26c1f34ebdddec41a945
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PhysicalActivity.fromJson(e))
        .toList();
  }

<<<<<<< HEAD
  Future<List<PsychicData>> fetchPsychic(String patientId,
      {int limit = 200}) async {
    final response = await _dio.get('/items/psychicData', queryParameters: {
      'filter[people_id][_eq]': patientId,
      'sort': 'date',
      'limit': limit,
    });
    final List<dynamic> list = response.data['data'] ?? [];
=======
  
  Future<List<PsychicData>> fetchPsychic(String patientId,
      {int limit = 200}) async {
    
    final response = await _dio.get('/items/psychicData', queryParameters: {
      'filter[people_id][_eq]': patientId, 
      'sort': 'date', 
      'limit': limit, 
    });
   
    final List<dynamic> list = response.data['data'] ?? [];
    
>>>>>>> e741175fd9008d80f27a26c1f34ebdddec41a945
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PsychicData.fromJson(e))
        .toList();
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> e741175fd9008d80f27a26c1f34ebdddec41a945
