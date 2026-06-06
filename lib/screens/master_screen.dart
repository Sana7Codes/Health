import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../providers/auth_provider.dart';
import '../providers/patients_provider.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientsProvider>().loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Application Santé'),
            if (auth.isAuthenticated && auth.userEmail != null)
              Text(
                auth.userEmail!,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person),
            onPressed: () {
              if (auth.isAuthenticated) {
                context.push('/profile');
              } else {
                context.push('/login');
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  context.read<PatientsProvider>().setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Rechercher un patient...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(patientProvider),
    );
  }

  Widget _buildBody(PatientsProvider provider) {
    if (provider.isLoading && provider.patients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 12),
            Text(provider.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadPatients(forceReload: true),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final patients = provider.filteredPatients;
    if (patients.isEmpty) {
      return const Center(
        child: Text('Aucun patient trouvé.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadPatients(forceReload: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: patients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _PatientCard(patient: patients[index]);
        },
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final age = patient.age;
    final gender = patient.genderLabel;
    final weight = patient.startWeight;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1D9E75),
          foregroundColor: Colors.white,
          child: Text(
            _initial(patient),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          patient.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${age != null ? '$age ans' : 'Âge inconnu'} • $gender',
        ),
        trailing: (weight != null && weight > 0)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('poids', style: TextStyle(fontSize: 12)),
                ],
              )
            : const Icon(Icons.chevron_right),
        onTap: () => context.push('/patients/${patient.id}'),
      ),
    );
  }

  static String _initial(Patient p) {
    if (p.firstName.isNotEmpty) return p.firstName[0].toUpperCase();
    if (p.lastName.isNotEmpty) return p.lastName[0].toUpperCase();
    return '?';
  }
}
