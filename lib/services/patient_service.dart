import 'package:dio/dio.dart';

import '../models/patient.dart';
import 'api_service.dart';

/// Service de récupération des patients depuis l'API publique.
class PatientService {
  final Dio _dio = ApiService().dio;

  Future<List<Patient>> fetchAll({int limit = 200}) async {
    final response = await _dio.get('/items/people', queryParameters: {
      'limit': limit,
      'sort': 'lastname',
    });
    final List<dynamic> list = response.data['data'] ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => Patient.fromJson(e))
        .toList();
  }

  Future<Patient> fetchById(String id) async {
    final response = await _dio.get('/items/people/$id');
    final data = response.data['data'];
    return Patient.fromJson(Map<String, dynamic>.from(data));
  }
}
