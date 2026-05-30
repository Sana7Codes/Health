import 'package:dio/dio.dart';

import '../models/physical_activity.dart';
import '../models/physiological_data.dart';
import '../models/psychic_data.dart';
import 'api_service.dart';

/// Service de récupération des données physiologiques, activités et psychiques.
class DataService {
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
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PhysiologicalData.fromJson(e))
        .toList();
  }

  Future<List<PhysicalActivity>> fetchActivities(String patientId,
      {int limit = 200}) async {
    final response =
        await _dio.get('/items/physicalActivities', queryParameters: {
      'filter[people_id][_eq]': patientId,
      'sort': 'date',
      'limit': limit,
    });
    final List<dynamic> list = response.data['data'] ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PhysicalActivity.fromJson(e))
        .toList();
  }

  Future<List<PsychicData>> fetchPsychic(String patientId,
      {int limit = 200}) async {
    final response = await _dio.get('/items/psychicData', queryParameters: {
      'filter[people_id][_eq]': patientId,
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
