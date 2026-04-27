import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/store/data/store_repository.dart';

class StoreInfoBar extends ConsumerWidget {
  const StoreInfoBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeValue = ref.watch(nearestStoreProvider);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.store, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: storeValue.when(
              data: (store) {
                if (store == null)
                  return const Text(
                    "Finding nearest store...",
                    style: TextStyle(fontSize: 12),
                  );
                return Row(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (store.districtName != null)
                            Text(
                              "${store.streetName ?? ''}, ${store.villageName ?? ''}, ${store.districtName}",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Text(
                "Loading store...",
                style: TextStyle(fontSize: 12),
              ),
              error: (_, __) => const Text(
                "Store unavailable",
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
        ],
      ),
    );
  }
}
