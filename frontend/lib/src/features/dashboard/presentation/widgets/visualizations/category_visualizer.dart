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
    }
    
    return const SizedBox.shrink();
  }
}
