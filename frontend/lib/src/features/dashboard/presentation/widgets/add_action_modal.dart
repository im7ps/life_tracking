import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dimension/presentation/dimension_providers.dart';
import '../../../action/presentation/action_providers.dart';
import '../../domain/action_category_data.dart';
import 'icon_action_selector.dart';
import 'visual_fulfillment_selector.dart';

class AddActionModal extends ConsumerStatefulWidget {
  const AddActionModal({super.key});

  @override
  ConsumerState<AddActionModal> createState() => _AddActionModalState();
}

class _AddActionModalState extends ConsumerState<AddActionModal> {
  String? _selectedDimensionId;
  String? _selectedActionKey;
  int _fulfillmentScore = 3;
  bool _isSubmitting = false;
  
  final DateTime _startTime = DateTime.now();

  Future<void> _submit() async {
    if (_isSubmitting) return;
    
    if (_selectedDimensionId != null && _selectedActionKey != null) {
      setState(() => _isSubmitting = true);
      
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (!mounted) return;

      final action = await ref
          .read(actionCreateControllerProvider.notifier)
          .createAction(
            startTime: _startTime,
            description: _selectedActionKey,
            dimensionId: _selectedDimensionId!,
            fulfillmentScore: _fulfillmentScore,
          );

      if (action != null && mounted) {
        Navigator.of(context).pop(action);
      } else {
        if (mounted) setState(() => _isSubmitting = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleziona una Dimensione e un'Attività")),
      );
    }
  }

  void _onFulfillmentChanged(int val) {
    if (_isSubmitting) return;
    setState(() => _fulfillmentScore = val);
    
    if (_selectedDimensionId != null && _selectedActionKey != null) {
      _submit();
    }
  }

  Color _getDimensionColor(String? dimensionId) {
    if (dimensionId == null) return const Color(0xFF64FFDA); 
    switch (dimensionId.toLowerCase()) {
      case 'energia': return const Color(0xFFE64A19);
      case 'chiarezza': return const Color(0xFF006064);
      case 'relazioni': return const Color(0xFFFBC02D);
      case 'anima': return const Color(0xFF6A1B9A);
      default: return const Color(0xFF64FFDA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimensionsAsync = ref.watch(dimensionsListProvider);
    final activeColor = _getDimensionColor(_selectedDimensionId);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12, // Reduced top padding for drag handle
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Vital for BottomSheet
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24, top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Text(
            "Nuova Attività",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 1. Dimension Selector
          dimensionsAsync.when(
            data: (dimensions) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dimensions.map((dim) {
                  final isSelected = _selectedDimensionId == dim.id;
                  final dimColor = _getDimensionColor(dim.id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(dim.name),
                      selected: isSelected,
                      selectedColor: dimColor.withValues(alpha: 0.2),
                      side: isSelected ? BorderSide(color: dimColor) : null,
                      labelStyle: TextStyle(
                        color: isSelected ? dimColor : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedDimensionId = selected ? dim.id : null;
                          // Optional: Clear activity if dimension changes and current activity is not valid for new dim
                          if (_selectedActionKey != null && !ActionCategory.isKnown(_selectedActionKey)) {
                              _selectedActionKey = null;
                          }
                        });
                      },
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          
          const SizedBox(height: 24),

          // 2. Action Selector (Using Flexible to prevent overflow while remaining scrollable)
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: IconActionSelector(
                dimensionId: _selectedDimensionId,
                selectedAction: _selectedActionKey,
                onSelected: (val) => setState(() => _selectedActionKey = val),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 3. Fulfillment (Visual Scale)
          Text(
            "Intensità",
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          VisualFulfillmentSelector(
            value: _fulfillmentScore,
            activeColor: activeColor,
            isSubmitting: _isSubmitting,
            icon: Icons.bolt,
            onChanged: _onFulfillmentChanged,
          ),

          const SizedBox(height: 48),

          if (_selectedDimensionId == null || _selectedActionKey == null)
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("SELEZIONA ATTIVITÀ"),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
