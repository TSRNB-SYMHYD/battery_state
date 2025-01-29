import 'dart:async';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/iso_battery_info.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:battery_state/data/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Task {
  final Function execute;
  bool isActive;
  StreamSubscription? subscription;
  OverlayEntry? overlay;

  Task(this.execute, {this.isActive = true});
}

class TaskManager with WidgetsBindingObserver {
  late WidgetRef ref;
  static final Map<String, Task> tasks = {};
  static bool isInitialized = false;

  TaskManager() {
    WidgetsBinding.instance.addObserver(this);
  }

  initialize(WidgetRef ref) async {
    if (isInitialized) return;
    this.ref = ref;
    _setupInitialTasks();
    debugPrint('Task manager initialized.');
    runTasks();
    isInitialized = true;
  }

  _setupInitialTasks() {
    addTask('counterThreshold', Task(_counterThreshold, isActive: false));
    addTask('lowBatteryMonitor', Task(_lowBatteryMonitor, isActive: true));
  }

  addTask(String name, Task task) {
    if (tasks.containsKey(name)) {
      debugPrint('Task "$name" already exists.');
      return;
    }
    tasks[name] = task;
    debugPrint('Task added: $name');
    toggleTask(name, task.isActive);
  }

  Task? getTask(String name) {
    if (!tasks.containsKey(name)) return null;

    return tasks[name];
  }

  removeTask(String name) {
    final task = tasks[name];
    if (task == null || !task.isActive) return;
    task.subscription?.cancel();
    tasks.remove(name);
    debugPrint('Task removed: $name');
  }

  toggleTask(String name, bool isActive) {
    final task = tasks[name];
    if (task != null) {
      task.isActive = isActive;
      if (isActive) {
        task.execute();
      } else {
        task.subscription?.cancel();
        task.subscription = null;
        if (task.overlay != null) task.overlay?.remove();
      }
      debugPrint('Task ${isActive ? 'activated' : 'deactivated'}: $name');
    }
  }

  runTasks() {
    for (var task in tasks.values) {
      if (task.isActive && task.subscription == null) {
        task.execute();
      }
    }
  }

  pauseAllTasks() {
    debugPrint('Pausing all tasks');
    for (var task in tasks.values) {
      task.subscription?.pause();
    }
  }

  resumeAllTasks() {
    debugPrint('Resuming all tasks');
    for (var task in tasks.values) {
      task.subscription?.resume();
    }
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('App lifecycle state: $state');
    state == AppLifecycleState.paused ? pauseAllTasks() : resumeAllTasks();
  }

  dispose() {
    for (var task in tasks.values) {
      task.subscription?.cancel();
      task.overlay?.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('Task manager disposed.');
  }

  _counterThreshold() {
    int count = 1;
    tasks['counterThreshold']?.subscription?.cancel();
    tasks['counterThreshold']?.subscription = Stream.periodic(const Duration(seconds: 5)).listen((_) {
      debugPrint('Counter: $count');
      count++;
    });
  }

  _lowBatteryMonitor() async {
    BatteryInfoPlugin batteryInfo = BatteryInfoPlugin();

    tasks['lowBatteryMonitor']?.subscription =
        batteryInfo.iosBatteryInfoStream.listen((IosBatteryInfo? iosBatteryInfo) {
          if(iosBatteryInfo == null){
            debugPrint('Error: iosBatteryInfo is null');
            return;
          }
      final batteryLevel = iosBatteryInfo.batteryLevel ?? 0;
      final batteryState = iosBatteryInfo.chargingStatus?.name ?? 'Unknown';
      debugPrint('Battery level: $batteryLevel%');
      debugPrint('Charging status: $batteryState');
      ref.read(batteryStateProvider.notifier).state = batteryState;
      ref.read(batteryLevelProvider.notifier).state = batteryLevel;
    }, onError: (error) {
      debugPrint('Error: $error');
    }, );
  }
}
