import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
 
import '../models/physical_activity.dart';
import '../models/physiological_data.dart';
import '../models/psychic_data.dart';
import '../providers/activities_provider.dart';
import '../providers/auth_provider.dart';
 
class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key, required this.patientId});
 
  final String patientId;
 
  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}
 
class _ChartsScreenState extends State<ChartsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
 
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activitiesProvider = context.read<ActivitiesProvider>();
      final auth = context.read<AuthProvider>();
      activitiesProvider.loadDataForPatient(widget.patientId);
      activitiesProvider.loadPsychicData(widget.patientId,
          isAuthenticated: auth.isAuthenticated);
    });
  }
 
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final activitiesProvider = context.watch<ActivitiesProvider>();
    final auth = context.watch<AuthProvider>();
    final physiological = activitiesProvider.physiologicalFor(widget.patientId);
    final activities = activitiesProvider.activitiesFor(widget.patientId);
    final psychic = activitiesProvider.psychicFor(widget.patientId);
    final isLoading = activitiesProvider.isLoadingFor(widget.patientId);
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graphiques'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/patients/${widget.patientId}'),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.monitor_weight), text: 'Poids'),
            Tab(icon: Icon(Icons.directions_walk), text: 'Activités'),
            Tab(icon: Icon(Icons.psychology), text: 'Bien-être'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _WeightChart(data: physiological),
                _StepsChart(activities: activities),
                _PsychicChart(
                    data: psychic, isAuthenticated: auth.isAuthenticated),
              ],
            ),
    );
  }
}
 
class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.data});
 
  final List<PhysiologicalData> data;
 
  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Aucune donnée de poids disponible.'));
    }
 
    final sorted = [...data]
      ..sort((a, b) =>
          (a.date ?? DateTime(1970)).compareTo(b.date ?? DateTime(1970)));
 
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      final w = sorted[i].weight;
      if (w != null) {
        spots.add(FlSpot(i.toDouble(), w));
      }
    }
    if (spots.isEmpty) {
      return const Center(child: Text('Aucune mesure de poids exploitable.'));
    }
 
    final weights = spots.map((s) => s.y).toList();
    final minY = (weights.reduce((a, b) => a < b ? a : b)) - 2;
    final maxY = (weights.reduce((a, b) => a > b ? a : b)) + 2;
    final stepX = (sorted.length / 6).ceil().clamp(1, 100);
    final dateFormat = DateFormat('dd/MM');
 
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Évolution du poids (kg)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black12),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: stepX.toDouble(),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= sorted.length) {
                          return const SizedBox.shrink();
                        }
                        if (idx % stepX != 0) {
                          return const SizedBox.shrink();
                        }
                        final date = sorted[idx].date;
                        if (date == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(dateFormat.format(date),
                              style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF1D9E75),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF1D9E75).withOpacity(0.18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
class _StepsChart extends StatelessWidget {
  const _StepsChart({required this.activities});
 
  final List<PhysicalActivity> activities;
 
  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(child: Text('Aucune activité enregistrée.'));
    }
 
    final sorted = [...activities.where((a) => a.date != null)]
      ..sort((a, b) => a.date!.compareTo(b.date!));
    final last14 =
        sorted.length > 14 ? sorted.sublist(sorted.length - 14) : sorted;
 
    if (last14.isEmpty) {
      return const Center(child: Text('Aucune date exploitable.'));
    }
 
    final maxSteps =
        last14.map((a) => a.steps ?? 0).fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = ((maxSteps / 1000).ceil() * 1000 + 1000).toDouble();
 
    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < last14.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (last14[i].steps ?? 0).toDouble(),
              color: const Color(0xFF1D9E75),
              width: 14,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }
 
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nombre de pas (14 derniers jours)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black12),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('0');
                        final k = (value / 1000).toStringAsFixed(0);
                        return Text('${k}k',
                            style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= last14.length) {
                          return const SizedBox.shrink();
                        }
                        final day = last14[idx].date?.day;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(day?.toString() ?? '',
                              style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
/// Onglet Bien-être.
///
/// L'API renvoie pour chaque enregistrement psychique un champ `feeling`
/// qui est une CATÉGORIE textuelle (ex : "addicted", "enduring"…), et non
/// un score numérique. On ne peut donc pas en calculer une moyenne.
/// La visualisation adaptée est une RÉPARTITION : on compte le nombre de
/// jours associés à chaque ressenti, affiché sous forme de diagramme à barres
/// horizontales (une barre par catégorie).
class _PsychicChart extends StatelessWidget {
  const _PsychicChart({required this.data, required this.isAuthenticated});
 
  final List<PsychicData> data;
  final bool isAuthenticated;
 
  // Traduction des catégories de l'API vers un libellé lisible en français.
  static const Map<String, String> _labels = {
    'happy': 'Heureux',
    'sad': 'Triste',
    'anxious': 'Anxieux',
    'angry': 'En colère',
    'addicted': 'Dépendant',
    'enduring': 'Endurant',
    'tired': 'Fatigué',
    'stressed': 'Stressé',
    'motivated': 'Motivé',
    'calm': 'Calme',
  };
 
  String _label(String raw) => _labels[raw] ?? raw;
 
  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 64, color: Color(0xFF1D9E75)),
              const SizedBox(height: 12),
              const Text(
                'Les données psychiques nécessitent une authentification.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }
    if (data.isEmpty) {
      return const Center(child: Text('Aucune donnée psychique disponible.'));
    }
 
    // Comptage du nombre d'occurrences de chaque ressenti.
    final counts = <String, int>{};
    for (final d in data) {
      final f = d.feeling;
      if (f == null || f.isEmpty) continue;
      counts[f] = (counts[f] ?? 0) + 1;
    }
 
    if (counts.isEmpty) {
      return const Center(child: Text('Aucun ressenti exploitable.'));
    }
 
    // Tri décroissant : le ressenti le plus fréquent en premier.
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
 
    final maxCount = entries.first.value;
    // Borne supérieure de l'axe : on arrondit au-dessus pour aérer le graphe.
    final maxX = (maxCount + 1).toDouble();
 
    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < entries.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entries[i].value.toDouble(),
              color: const Color(0xFF1D9E75),
              width: 16,
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
          ],
        ),
      );
    }
 
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Répartition des ressentis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${data.length} enregistrement(s) au total',
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 16),
          Expanded(
            // Diagramme à barres HORIZONTALES : on fait pivoter l'axe en
            // utilisant un BarChart classique mais avec rotation des étiquettes,
            // ou plus simplement on garde des barres verticales lisibles.
            child: BarChart(
              BarChartData(
                maxY: maxX,
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black12),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) return const SizedBox.shrink();
                        return Text(value.toInt().toString(),
                            style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _label(entries[idx].key),
                            style: const TextStyle(fontSize: 9),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Légende détaillée sous le graphe.
          ...entries.map((e) => _legendRow(_label(e.key), e.value)),
        ],
      ),
    );
  }
 
  Widget _legendRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF1D9E75),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$label : $count jour(s)'),
        ],
      ),
    );
  }
}