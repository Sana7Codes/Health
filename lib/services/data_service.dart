import 'package:dio/dio.dart';
 
import '../models/physical_activity.dart';
import '../models/physiological_data.dart';
import '../models/psychic_data.dart';
import 'api_service.dart';
 
/// Service de récupération des données physiologiques, activités et psychiques.
///
/// Le filtrage Directus :
/// la syntaxe à crochets `filter[people_id][_eq]=...` n'est pas encodée
/// de façon fiable par Dio (les crochets dans les clés posent problème).
/// On utilise donc le format JSON de filtre Directus, sans crochets :
///   filter = {"people_id":{"_eq":"<id>"}}
/// Ce format est passé comme une simple chaîne de caractères, que Dio
/// encode correctement.
class DataService {
  // Instance Dio partagée, configurée dans ApiService (URL de base, en-têtes, etc.)
  final Dio _dio = ApiService().dio;
 
  /// Construit un filtre Directus au format JSON pour un patient donné.
  String _filterByPatient(String patientId) =>
      '{"people_id":{"_eq":"$patientId"}}';
 
  /// Récupère les données physiologiques d'un patient donné.
  Future<List<PhysiologicalData>> fetchPhysiological(String patientId,
      {int limit = 200}) async {
    final response =
        await _dio.get('/items/physiologicalData', queryParameters: {
      'filter': _filterByPatient(patientId), // Filtre JSON : ce patient uniquement
      'sort': 'date', // Tri chronologique
      'limit': limit, // Limite du nombre de résultats
    });
    final List<dynamic> list = response.data['data'] ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PhysiologicalData.fromJson(e))
        .toList();
  }
 
  /// Récupère les activités physiques d'un patient donné.
  Future<List<PhysicalActivity>> fetchActivities(String patientId,
      {int limit = 200}) async {
    final response =
        await _dio.get('/items/physicalActivities', queryParameters: {
      'filter': _filterByPatient(patientId),
      'sort': 'date',
      'limit': limit,
    });
 
    final List<dynamic> list = response.data['data'] ?? [];
 
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PhysicalActivity.fromJson(e))
        .toList();
  }
 
  /// Récupère les données psychiques d'un patient donné (endpoint privé).
  Future<List<PsychicData>> fetchPsychic(String patientId,
      {int limit = 200}) async {
    final response = await _dio.get('/items/psychicData', queryParameters: {
      'filter': _filterByPatient(patientId),
      'sort': 'date',
      'limit': limit,
    });
 
    final List<dynamic> list = response.data['data'] ?? [];
 
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PsychicData.fromJson(e))
        .toList();
  }
}