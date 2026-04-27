import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/features/address/data/address_repository.dart';
import 'package:store_app/src/features/address/domain/region_models.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/address/domain/user_address.dart';

// --- Providers for Form State ---

// Stores selected IDs
final selectedProvinceIdProvider = StateProvider<int?>((ref) => null);
final selectedRegencyIdProvider = StateProvider<int?>((ref) => null);
final selectedDistrictIdProvider = StateProvider<int?>((ref) => null);
final selectedVillageIdProvider = StateProvider<int?>((ref) => null);
final selectedStreetIdProvider = StateProvider<int?>((ref) => null);

// Fetchers
final provincesProvider = FutureProvider<List<Province>>((ref) async {
  return ref.read(addressRepositoryProvider).getProvinces();
});

final regenciesProvider = FutureProvider.family<List<RegencyMunicipality>, int>(
  (ref, provinceId) async {
    return ref.read(addressRepositoryProvider).getRegencies(provinceId);
  },
);

final districtsProvider = FutureProvider.family<List<District>, int>((
  ref,
  regencyId,
) async {
  return ref.read(addressRepositoryProvider).getDistricts(regencyId);
});

final villagesProvider = FutureProvider.family<List<Village>, int>((
  ref,
  districtId,
) async {
  return ref.read(addressRepositoryProvider).getVillages(districtId);
});

final streetsProvider = FutureProvider.family<List<Street>, int>((
  ref,
  villageId,
) async {
  return ref.read(addressRepositoryProvider).getStreets(villageId);
});

// ... providers remain same

class AddAddressScreen extends ConsumerStatefulWidget {
  final UserAddress? addressToEdit; // Added parameter

  const AddAddressScreen({super.key, this.addressToEdit});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _receiverNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _otherDetailsController;

  bool _isOffice = false;
  bool _isMainAddress = false;
  bool _isEditMode = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.addressToEdit;
    _isEditMode = addr != null;

    _receiverNameController = TextEditingController(
      text: addr?.receiverName ?? '',
    );
    _phoneNumberController = TextEditingController(
      text: addr?.receiverPhoneNumber ?? '',
    );
    _otherDetailsController = TextEditingController(
      text: addr?.otherDetails ?? '',
    );

    _isOffice = addr?.isOffice ?? false;
    _isMainAddress = addr?.isMainAddress ?? false;

    if (_isEditMode && addr != null) {
      // Pre-fill dropdowns using Microtask to avoid build collisions
      Future.microtask(() {
        // Assuming details maps have 'id'
        final provinceId = addr.provinceDetail?['id'] as int?;
        final regencyId = addr.regencyDetail?['id'] as int?;
        final districtId = addr.districtDetail?['id'] as int?;
        final villageId = addr.villageId; // or villageDetail['id']
        final streetId = addr.streetId;

        if (provinceId != null)
          ref.read(selectedProvinceIdProvider.notifier).state = provinceId;
        if (regencyId != null)
          ref.read(selectedRegencyIdProvider.notifier).state = regencyId;
        if (districtId != null)
          ref.read(selectedDistrictIdProvider.notifier).state = districtId;
        ref.read(selectedVillageIdProvider.notifier).state = villageId;
        ref.read(selectedStreetIdProvider.notifier).state = streetId;
      });
    } else {
      // Clear providers on fresh add?
      // If we navigate back and forth, providers might keep state.
      // Best to clear them on init for fresh start.
      Future.microtask(() {
        ref.read(selectedProvinceIdProvider.notifier).state = null;
        ref.read(selectedRegencyIdProvider.notifier).state = null;
        ref.read(selectedDistrictIdProvider.notifier).state = null;
        ref.read(selectedVillageIdProvider.notifier).state = null;
        ref.read(selectedStreetIdProvider.notifier).state = null;
      });
    }
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _phoneNumberController.dispose();
    _otherDetailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final streetId = ref.read(selectedStreetIdProvider);
    if (streetId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a street')));
      return;
    }
    final villageId = ref.read(selectedVillageIdProvider);
    if (villageId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a village')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(addressRepositoryProvider);
      if (_isEditMode && widget.addressToEdit != null) {
        await repo.updateAddress(
          id: widget.addressToEdit!.id,
          receiverName: _receiverNameController.text,
          receiverPhoneNumber: _phoneNumberController.text,
          streetId: streetId,
          villageId: villageId,
          otherDetails: _otherDetailsController.text,
          latitude: widget.addressToEdit!.latitude, // Keep existing loc for now
          longitude: widget.addressToEdit!.longitude,
          isOffice: _isOffice,
          isMainAddress: _isMainAddress,
        );
      } else {
        await repo.createAddress(
          receiverName: _receiverNameController.text,
          receiverPhoneNumber: _phoneNumberController.text,
          streetId: streetId,
          villageId: villageId,
          otherDetails: _otherDetailsController.text,
          latitude: 0,
          longitude: 0,
          isOffice: _isOffice,
          isMainAddress: _isMainAddress,
        );
      }

      if (mounted) {
        ref.refresh(userAddressesProvider); // Force refresh list
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Address updated' : 'Address added'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch selections
    final provinceId = ref.watch(selectedProvinceIdProvider);
    final regencyId = ref.watch(selectedRegencyIdProvider);
    final districtId = ref.watch(selectedDistrictIdProvider);
    final villageId = ref.watch(selectedVillageIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Address' : 'Add New Address'),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Contact Info
              Text(
                'Contact Information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _receiverNameController,
                decoration: const InputDecoration(
                  labelText: 'Receiver Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),

              const SizedBox(height: 24),
              Text('Location', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              // Province
              Consumer(
                builder: (context, ref, _) {
                  final provinces = ref.watch(provincesProvider);
                  return provinces.when(
                    data: (list) => DropdownButtonFormField<int>(
                      value: provinceId,
                      decoration: const InputDecoration(labelText: 'Province'),
                      items: list
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        ref.read(selectedProvinceIdProvider.notifier).state =
                            val;
                        ref.read(selectedRegencyIdProvider.notifier).state =
                            null;
                        ref.read(selectedDistrictIdProvider.notifier).state =
                            null;
                        ref.read(selectedVillageIdProvider.notifier).state =
                            null;
                        ref.read(selectedStreetIdProvider.notifier).state =
                            null;
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error loading provinces: $e'),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Regency
              if (provinceId != null)
                Consumer(
                  builder: (context, ref, _) {
                    final regencies = ref.watch(regenciesProvider(provinceId));
                    return regencies.when(
                      data: (list) => DropdownButtonFormField<int>(
                        value: regencyId,
                        decoration: const InputDecoration(
                          labelText: 'City / Regency',
                        ),
                        items: list
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          ref.read(selectedRegencyIdProvider.notifier).state =
                              val;
                          ref.read(selectedDistrictIdProvider.notifier).state =
                              null;
                          ref.read(selectedVillageIdProvider.notifier).state =
                              null;
                          ref.read(selectedStreetIdProvider.notifier).state =
                              null;
                        },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Error loading regencies: $e'),
                    );
                  },
                ),
              if (provinceId != null) const SizedBox(height: 16),

              // District
              if (regencyId != null)
                Consumer(
                  builder: (context, ref, _) {
                    final districts = ref.watch(districtsProvider(regencyId));
                    return districts.when(
                      data: (list) => DropdownButtonFormField<int>(
                        value: districtId,
                        decoration: const InputDecoration(
                          labelText: 'District',
                        ),
                        items: list
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          ref.read(selectedDistrictIdProvider.notifier).state =
                              val;
                          ref.read(selectedVillageIdProvider.notifier).state =
                              null;
                          ref.read(selectedStreetIdProvider.notifier).state =
                              null;
                        },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Error loading districts: $e'),
                    );
                  },
                ),
              if (regencyId != null) const SizedBox(height: 16),

              // Village
              if (districtId != null)
                Consumer(
                  builder: (context, ref, _) {
                    final villages = ref.watch(villagesProvider(districtId));
                    return villages.when(
                      data: (list) => DropdownButtonFormField<int>(
                        value: villageId,
                        decoration: const InputDecoration(labelText: 'Village'),
                        items: list
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          ref.read(selectedVillageIdProvider.notifier).state =
                              val;
                          ref.read(selectedStreetIdProvider.notifier).state =
                              null;
                        },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Error loading villages: $e'),
                    );
                  },
                ),
              if (districtId != null) const SizedBox(height: 16),

              // Street
              if (villageId != null)
                Consumer(
                  builder: (context, ref, _) {
                    // Note: Ideally filtering streets by village, reusing generic street fetcher for now
                    // Assuming user must search or pick from list associated with village
                    final streets = ref.watch(streetsProvider(villageId));
                    return streets.when(
                      data: (list) => DropdownButtonFormField<int>(
                        value: ref.watch(selectedStreetIdProvider),
                        decoration: const InputDecoration(labelText: 'Street'),
                        items: list
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          ref.read(selectedStreetIdProvider.notifier).state =
                              val;
                        },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Error loading streets: $e'),
                    );
                  },
                ),
              if (villageId != null) const SizedBox(height: 16),

              TextFormField(
                controller: _otherDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Other Details (e.g. House No, Landmark)',
                  prefixIcon: Icon(Icons.comment),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Flags
              SwitchListTile(
                title: const Text('Is this an Office address?'),
                value: _isOffice,
                onChanged: (v) => setState(() => _isOffice = v),
              ),
              SwitchListTile(
                title: const Text('Set as Main Address'),
                value: _isMainAddress,
                onChanged: (v) => setState(() => _isMainAddress = v),
              ),

              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Save Address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
