import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/features/address/data/address_repository.dart';
import 'package:store_app/src/features/address/presentation/widgets/address_card.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesValue = ref.watch(userAddressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: addressesValue.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No addresses found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Add Address
                      context.push('/profile/addresses/add');
                    },
                    child: const Text('Add New Address'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return AddressCard(
                address: address,
                onEdit: () {
                  context.push('/profile/addresses/edit', extra: address);
                },
                onSetMain: () async {
                  try {
                    await ref
                        .read(addressRepositoryProvider)
                        .setMainAddress(address.id);
                    // Refresh
                    ref.refresh(userAddressesProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Main address updated")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to update: $e")),
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Navigate to Add Address
            context.push('/profile/addresses/add');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Add New Address'),
        ),
      ),
    );
  }
}
