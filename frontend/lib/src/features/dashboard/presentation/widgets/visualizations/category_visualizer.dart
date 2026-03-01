import 'package:flutter/material.dart';
import '../../dashboard_models.dart';
import 'identity_tree.dart';
import 'soul_constellation.dart';
import 'duty_mountain.dart';
import 'energy_core.dart';
import 'relation_threads.dart';

class CategoryVisualizer extends StatelessWidget {
  final CategoryInfo category;
  final List<TaskUIModel> tasks;

  const CategoryVisualizer({
    super.key,
    required this.category,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final catId = category.id.toLowerCase();
    final catLabel = category.label.toLowerCase();

    if (catId == 'passione' || catLabel == 'passione') {
      return IdentityTree(tasks: tasks);
    } else if (catId == 'anima' || catLabel == 'anima') {
      return SoulConstellation(tasks: tasks);
    } else if (catId == 'dovere' || catLabel == 'dovere') {
      return DutyMountain(tasks: tasks);
    } else if (catId == 'energia' || catLabel == 'energia') {
      return EnergyCore(tasks: tasks);
    } else if (catId == 'relazioni' || catLabel == 'relazioni') {
      return RelationThreads(tasks: tasks);
    } else if (catId == 'general' || catLabel == 'generali') {
      // Per la categoria generale (Specchio), mostriamo un riepilogo visuale
      // Se c'è solo una categoria dominante, mostriamo quella, altrimenti un placeholder coerente
      if (tasks.isEmpty) {
        return _buildEmptyMirror(context);
      }
      
      // Se la maggior parte dei task appartiene a una categoria specifica, 
      // mostriamo quella visualizzazione in modalità "riepilogo"
      final categoriesInTasks = tasks.map((t) => t.category.toLowerCase()).toSet();
      if (categoriesInTasks.length == 1) {
        final soloCat = categoriesInTasks.first;
        if (soloCat == 'passione') return IdentityTree(tasks: tasks);
        if (soloCat == 'anima') return SoulConstellation(tasks: tasks);
        if (soloCat == 'dovere') return DutyMountain(tasks: tasks);
        if (soloCat == 'energia') return EnergyCore(tasks: tasks);
        if (soloCat == 'relazioni') return RelationThreads(tasks: tasks);
      }

      return _buildGeneralMirror(context);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildEmptyMirror(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_mosaic_rounded, size: 48, color: Colors.white24),
            SizedBox(height: 12),
            Text("LO SPECCHIO È VUOTO", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            Text("Aggiungi una task per iniziare", style: TextStyle(color: Colors.white12, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralMirror(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.blur_on_rounded, size: 120, color: Colors.white10),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "RIEPILOGO MULTI-DIMENSIONALE",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _miniStat(Icons.bolt_rounded, tasks.length.toString(), Colors.amber),
                    const SizedBox(width: 20),
                    _miniStat(Icons.check_circle_outline_rounded, tasks.where((t) => t.isCompleted).length.toString(), Colors.greenAccent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
