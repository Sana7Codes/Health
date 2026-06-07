import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../models/physical_activity.dart';
import '../models/physiological_data.dart';
import '../providers/activities_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/patients_provider.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.patientId});

  final String patientId;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Patient? _patient;
  bool _loadingPatient = true;
  String? _patientError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    final patientsProvider = context.read<PatientsProvider>();
    final activitiesProvider = context.read<ActivitiesProvider>();
    final auth = context.read<AuthProvider>();

    try {
      final patient = await patientsProvider.ensurePatient(widget.patientId);
      if (!mounted) return;
      setState(() {
        _patient = patient;
        _loadingPatient = false;
        if (patient == null) {
          _patientError = 'Patient introuvable.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _patientError = 'Erreur lors du chargement du patient.';
        _loadingPatient = false;
      });
    }

    // Déclenchement parallèle des chargements de données.
    activitiesProvider.loadDataForPatient(widget.patientId);
    activitiesProvider.loadPsychicData(widget.patientId,
        isAuthenticated: auth.isAuthenticated);
  }

  @override
  Widget build(BuildContext context) {
    final activitiesProvider = context.watch<ActivitiesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_patient?.fullName ?? 'Détails patient'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/patients'),
        ),
      ),
      body: _buildBody(activitiesProvider),
    );
  }

  Widget _buildBody(ActivitiesProvider activitiesProvider) {
    if (_loadingPatient) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_patientError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 12),
            Text(_patientError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAll,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final patient = _patient!;
    final activities = activitiesProvider.activitiesFor(patient.id.toString());
    final physiological = activitiesProvider.physiologicalFor(patient.id.toString());
    final isLoadingData = activitiesProvider.isLoadingFor(patient.id.toString());
    final dataError = activitiesProvider.errorFor(patient.id.toString());

    final lastPhysio = _lastWithWeight(physiological);
    final currentWeight = lastPhysio?.weight ?? patient.startWeight;
    final totalSteps =
        activities.fold<int>(0, (sum, a) => sum + (a.steps ?? 0));
    final activityCount = activities.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _IdentityCard(patient: patient),
        const SizedBox(height: 16),
        _StatsRow(
          weight: currentWeight,
          totalSteps: totalSteps,
          activityCount: activityCount,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Activités récentes',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () =>
                  context.push('/patients/${patient.id.toString()}/charts'),
              icon: const Icon(Icons.bar_chart),
              label: const Text('Graphiques'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoadingData)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (dataError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Text(dataError, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => activitiesProvider.loadDataForPatient(
                      patient.id.toString(),
                      forceReload: true),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          )
        else if (activities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('Aucune activité enregistrée.')),
          )
        else
          ..._recentActivities(activities),
      ],
    );
  }

  PhysiologicalData? _lastWithWeight(List<PhysiologicalData> data) {
    final filtered = data.where((d) => d.weight != null).toList()
      ..sort((a, b) =>
          (a.date ?? DateTime(1970)).compareTo(b.date ?? DateTime(1970)));
    return filtered.isEmpty ? null : filtered.last;
  }

  List<Widget> _recentActivities(List<PhysicalActivity> activities) {
    final sorted = [...activities]
      ..sort((a, b) => (b.date ?? DateTime(1970))
          .compareTo(a.date ?? DateTime(1970)));
    final top = sorted.take(5).toList();
    final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

    return top
        .map((a) => Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF1D9E75),
                  foregroundColor: Colors.white,
                  child: Icon(Icons.directions_run),
                ),
                title: Text(a.activityType ?? 'Activité'),
                subtitle: Text(
                  '${a.date != null ? dateFormat.format(a.date!) : '?'} • '
                  '${a.steps ?? 0} pas • ${a.duration ?? 0} min',
                ),
                trailing: Text('${a.calories ?? 0} kcal'),
              ),
            ))
        .toList();
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.patient});

  final Patient patient;

  static String _initial(Patient p) {
    final f = p.firstName ?? '';
    final l = p.lastName ?? '';
    if (f.isNotEmpty) return f[0].toUpperCase();
    if (l.isNotEmpty) return l[0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final age = patient.age;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFF1D9E75),
              foregroundColor: Colors.white,
              child: Text(
                _initial(patient),
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${age != null ? '$age ans' : 'Âge ?'} • '
                    '${patient.genderLabel}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Taille : ${patient.height != null ? '${patient.height} cm' : '?'}',
                  ),
                  Text(
                    'Objectif : ${patient.targetWeight != null ? '${patient.targetWeight!.toStringAsFixed(1)} kg' : '?'}',
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.weight,
    required this.totalSteps,
    required this.activityCount,
  });

  final double? weight;
  final int totalSteps;
  final int activityCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.monitor_weight_outlined,
            label: 'Poids actuel',
            value: weight != null ? '${weight!.toStringAsFixed(1)} kg' : '—',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.directions_walk,
            label: 'Pas (total)',
            value: NumberFormat.compact().format(totalSteps),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.fitness_center,
            label: 'Activités',
            value: '$activityCount',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1D9E75), size: 28),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
