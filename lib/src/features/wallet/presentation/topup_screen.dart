import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopupScreen extends ConsumerWidget {
  const TopupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up Wallet')),
      body: SafeArea(
        bottom: true,
        top: false,
        child: const Center(child: Text('Top Up Feature Coming Soon')),
      ),
    );
  }
}
