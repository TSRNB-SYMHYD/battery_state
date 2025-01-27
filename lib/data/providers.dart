import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BatteryInfoPackage { batteryPlus, batteryInfo }

final batteryStateProvider = StateProvider<String?>((_) => null);
final batteryLevelProvider = StateProvider<int>((_) => 0);
final batteryInfoPackageProvider = StateProvider<BatteryInfoPackage>((_) => BatteryInfoPackage.batteryInfo);
