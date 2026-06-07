import 'package:flutter/foundation.dart';

import '../models/patient.dart';
import '../services/patient_service.dart';


/// Provider dédié à la gestion de la liste des patients et de leurs détails.
class PatientsProvider extends ChangeNotifier {
  final PatientService _service = PatientService();
// Cache local de la liste des patients et de leur état de chargement.
  List<Patient> _patients = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  bool _hasLoaded = false;
// Getters publics pour accéder aux données et à l'état.
  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  /// Liste filtrée selon la requête de recherche courante.
  List<Patient> get filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    final q = _searchQuery.toLowerCase();
    return _patients
        .where((p) =>
            p.fullName.toLowerCase().contains(q) ||
            (p.firstName?.toLowerCase().contains(q) ?? false) ||
            (p.lastName?.toLowerCase().contains(q) ?? false))
        .toList();
  }
/// Met à jour la requête de recherche et notifie les écouteurs pour rafraîchir l'affichage.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Charge la liste des patients. Garde-fou anti-rechargements multiples.
  Future<void> loadPatients({bool forceReload = false}) async {
    if (_hasLoaded && !forceReload) return;
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();
// Appel du service pour récupérer les patients, avec gestion des erreurs.
    try {
      _patients = await _service.fetchAll();
      _hasLoaded = true;
    } catch (e) {
      _error = 'Impossible de charger la liste des patients.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
/// Recherche un patient par son ID dans le cache local. Retourne null si non trouvé.
  Patient? findById(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
/// Assure que les détails d'un patient sont chargés. Si déjà en cache, retourne immédiatement.
  Future<Patient?> ensurePatient(String id) async {
    final existing = findById(id);
    if (existing != null) return existing;
    try {
      final patient = await _service.fetchById(id);
      // Insère ou met à jour le patient dans la liste.
      final idx = _patients.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        _patients[idx] = patient;
      } else {
        _patients = [..._patients, patient];
      }
      notifyListeners();
      return patient;
    } catch (_) {
      return null;
    }
  }
}
