import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransferScreen extends ConsumerWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Balance')),
      body: SafeArea(
        bottom: true,
        top: false,
        child: const Center(child: Text('Transfer Feature Coming Soon')),
      ),
    );
  }
}
