import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/product/presentation/discover_controller.dart';
import 'package:store_app/src/core/theme/app_theme.dart';

class DiscoverFilterSheet extends ConsumerStatefulWidget {
  const DiscoverFilterSheet({super.key});

  @override
  ConsumerState<DiscoverFilterSheet> createState() =>
      _DiscoverFilterSheetState();
}

class _DiscoverFilterSheetState extends ConsumerState<DiscoverFilterSheet> {
  // Local state for filters
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late bool _isSupportCod;
  late bool _isSupportInstant;
  late bool _isContainPoints;

  @override
  void initState() {
    super.initState();
    final currentState =
        ref.read(discoverControllerProvider).value ?? DiscoverState();
    _minPriceController = TextEditingController(
      text: currentState.minPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: currentState.maxPrice?.toString() ?? '',
    );
    _isSupportCod = currentState.isSupportCod;
    _isSupportInstant = currentState.isSupportInstantDelivery;
    _isContainPoints = currentState.isContainPoints;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _apply() {
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);
    final controller = ref.read(discoverControllerProvider.notifier);

    controller.setPriceRange(minPrice, maxPrice);
    controller.toggleFilter(
      cod: _isSupportCod,
      instant: _isSupportInstant,
      points: _isContainPoints,
    );
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _minPriceController.clear();
      _maxPriceController.clear();
      _isSupportCod = false;
      _isSupportInstant = false;
      _isContainPoints = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filter Products",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Price Range",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Min Price",
                            prefixText: "Rp ",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Max Price",
                            prefixText: "Rp ",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Services",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ChoiceChip(
                        label: const Text("Support COD"),
                        selected: _isSupportCod,
                        onSelected: (v) => setState(() => _isSupportCod = v),
                        selectedColor: AppColors.primary.withValues(
                          alpha: 0.15,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: _isSupportCod
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                        labelStyle: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(
                              color: _isSupportCod
                                  ? AppColors.primary
                                  : Colors.black,
                              fontWeight: _isSupportCod
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: false,
                      ),
                      ChoiceChip(
                        label: const Text("Instant Delivery"),
                        selected: _isSupportInstant,
                        onSelected: (v) =>
                            setState(() => _isSupportInstant = v),
                        selectedColor: AppColors.primary.withValues(
                          alpha: 0.15,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: _isSupportInstant
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                        labelStyle: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(
                              color: _isSupportInstant
                                  ? AppColors.primary
                                  : Colors.black,
                              fontWeight: _isSupportInstant
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: false,
                      ),
                      ChoiceChip(
                        label: const Text("Contains Points"),
                        selected: _isContainPoints,
                        onSelected: (v) => setState(() => _isContainPoints = v),
                        selectedColor: AppColors.primary.withValues(
                          alpha: 0.15,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: _isContainPoints
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                        labelStyle: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(
                              color: _isContainPoints
                                  ? AppColors.primary
                                  : Colors.black,
                              fontWeight: _isContainPoints
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Buttons remain unchanged
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: AppColors.textPrimary,
                  ),
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text("Apply"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Removed _FilterToggleButton as we use standard ChoiceChip now

class DiscoverSortSheet extends ConsumerStatefulWidget {
  const DiscoverSortSheet({super.key});

  @override
  ConsumerState<DiscoverSortSheet> createState() => _DiscoverSortSheetState();
}

class _DiscoverSortSheetState extends ConsumerState<DiscoverSortSheet> {
  late String? _sortBy;
  late bool _sortDescending;

  @override
  void initState() {
    super.initState();
    final currentState =
        ref.read(discoverControllerProvider).value ?? DiscoverState();
    _sortBy = currentState.sortBy;
    _sortDescending = currentState.sortDescending;
  }

  void _apply() {
    ref
        .read(discoverControllerProvider.notifier)
        .setSort(_sortBy, _sortDescending);
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _sortBy = null;
      _sortDescending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sort By",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SortChip(
                  label: "Name",
                  value: "name",
                  groupValue: _sortBy,
                  descending: _sortDescending,
                  onTap: (v, d) => setState(() {
                    _sortBy = v;
                    _sortDescending = d;
                  }),
                ),
                _SortChip(
                  label: "Price",
                  value: "sell_price",
                  groupValue: _sortBy,
                  descending: _sortDescending,
                  onTap: (v, d) => setState(() {
                    _sortBy = v;
                    _sortDescending = d;
                  }),
                ),
                _SortChip(
                  label: "Sold Count",
                  value: "sold_count",
                  groupValue: _sortBy,
                  descending: _sortDescending,
                  onTap: (v, d) => setState(() {
                    _sortBy = v;
                    _sortDescending = d;
                  }),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: AppColors.textPrimary,
                  ),
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text("Apply"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String? groupValue;
  final bool descending;
  final Function(String, bool) onTap;

  const _SortChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.descending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (isSelected) ...[
            const SizedBox(width: 4),
            Icon(
              descending
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 16,
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (isSelected) {
          onTap(value, !descending);
        } else {
          onTap(value, false);
        }
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey.shade300,
      ),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: isSelected ? AppColors.primary : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }
}
