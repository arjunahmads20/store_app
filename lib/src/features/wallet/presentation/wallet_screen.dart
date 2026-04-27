import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: SafeArea(
        bottom: true,
        top: false,
        child: const Center(child: Text('Wallet Features Coming Soon')),
      ),
    );
  }
}
