import 'package:flutter/foundation.dart';

import '../models/physical_activity.dart';
import '../models/physiological_data.dart';
import '../models/psychic_data.dart';
import '../services/data_service.dart';

class ActivitiesProvider extends ChangeNotifier {
  final DataService _service = DataService();

  final Map<String, List<PhysicalActivity>> _activities = {};
  final Map<String, List<PhysiologicalData>> _physiological = {};
  final Map<String, List<PsychicData>> _psychic = {};
  final Map<String, bool> _loadingByPatient = {};
  final Map<String, String?> _errorByPatient = {};

  List<PhysicalActivity> activitiesFor(String patientId) =>
      _activities[patientId] ?? const [];

  List<PhysiologicalData> physiologicalFor(String patientId) =>
      _physiological[patientId] ?? const [];

  List<PsychicData> psychicFor(String patientId) =>
      _psychic[patientId] ?? const [];

  bool isLoadingFor(String patientId) => _loadingByPatient[patientId] ?? false;
  String? errorFor(String patientId) => _errorByPatient[patientId];

  bool hasDataFor(String patientId) =>
      _activities.containsKey(patientId) &&
      _physiological.containsKey(patientId);

  /// Charge en parallèle les données d'activité et physiologiques d'un patient.
  /// Garde-fou : ne recharge pas si déjà en cache (sauf forceReload).
  Future<void> loadDataForPatient(String patientId,
      {bool forceReload = false}) async {
    if (!forceReload && hasDataFor(patientId)) return;
    if (_loadingByPatient[patientId] == true) return;

    _loadingByPatient[patientId] = true;
    _errorByPatient[patientId] = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.fetchActivities(patientId),
        _service.fetchPhysiological(patientId),
      ]);
      _activities[patientId] = results[0] as List<PhysicalActivity>;
      _physiological[patientId] = results[1] as List<PhysiologicalData>;
    } catch (e) {
      _errorByPatient[patientId] = 'Erreur lors du chargement des données.';
    } finally {
      _loadingByPatient[patientId] = false;
      notifyListeners();
    }
  }

  /// Charge les données psychiques (nécessite une authentification).
  Future<void> loadPsychicData(String patientId,
      {required bool isAuthenticated, bool forceReload = false}) async {
    if (!isAuthenticated) return;
    if (!forceReload && _psychic.containsKey(patientId)) return;

    try {
      final data = await _service.fetchPsychic(patientId);
      _psychic[patientId] = data;
      notifyListeners();
    } catch (_) {
      // Échec silencieux : les données psychiques sont optionnelles.
    }
  }

  void clearCache() {
    _activities.clear();
    _physiological.clear();
    _psychic.clear();
    _loadingByPatient.clear();
    _errorByPatient.clear();
    notifyListeners();
  }
}
