import 'package:battery_state/data/providers.dart';
import 'package:battery_state/screens/secondary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Homepage extends ConsumerWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryState = ref.watch(batteryStateProvider);
    final batteryLevel = ref.watch(batteryLevelProvider);
    final batteryInfoPackage = ref.watch(batteryInfoPackageProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Text('Battery State: $batteryState'),
          Text('Battery Level: $batteryLevel%'),
          Text('Battery Info Package: $batteryInfoPackage'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecondaryPage()),
            ),
            child: const Text('Navigate to Page 2'),
          ),
        ],
      )),
    );
  }
}
