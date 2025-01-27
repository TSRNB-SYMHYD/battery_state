import 'package:battery_state/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecondaryPage extends ConsumerWidget {
  const SecondaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryState = ref.watch(batteryStateProvider);
    final batteryLevel = ref.watch(batteryLevelProvider);
    final batteryInfoPackage = ref.watch(batteryInfoPackageProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 2'),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Text('Battery State: $batteryState'),
          Text('Battery Level: $batteryLevel%'),
          Text('Battery Info Package: $batteryInfoPackage'),
        ],
      )),
    );
  }
}
