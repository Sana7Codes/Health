import 'package:flutter/foundation.dart';

import '../models/psychic_data.dart';
import '../services/data_service.dart';

/// Provider dédié aux données psychiques (réservées aux utilisateurs authentifiés).
class PsychicProvider extends ChangeNotifier {
  final DataService _service = DataService();

  final Map<String, List<PsychicData>> _cache = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<PsychicData> dataFor(String patientId) => _cache[patientId] ?? const [];

  Future<void> loadFor(String patientId,
      {required bool isAuthenticated, bool forceReload = false}) async {
    if (!isAuthenticated) {
      _error = 'Authentification requise pour les données psychiques.';
      notifyListeners();
      return;
    }
    if (!forceReload && _cache.containsKey(patientId)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cache[patientId] = await _service.fetchPsychic(patientId);
    } catch (e) {
      _error = 'Erreur lors du chargement des données psychiques.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
