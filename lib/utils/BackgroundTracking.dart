import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundTracking {
  static late FixesApi _fixesApi;

  static String _scheduledTasksPrefsKey = 'scheduledTrackingEpochs';
  static String _isEnabledPrefsKey = 'trackingEnabled';
  static int tasksPerDay = 5;
  static const String _pendingFixesPrefsKey = 'pending_fixes_v1';
  static const double _gridSize = 0.025;
  static const String _syncTaskUniqueName = 'sync_pending_fixes_task';
  static const String _syncTaskTag = 'syncPendingFixes';

  static final List<_PendingFix> _pendingFixes = [];
  static SharedPreferences? _prefs;
  static bool _pendingFixesLoaded = false;
  static bool _isSyncingFixes = false;

  static void configure({required MosquitoAlert apiClient}) {
    _fixesApi = apiClient.getFixesApi();
  }

  static Future<void> start(
      {bool shouldRun = false, bool requestPermissions = true}) async {
    bool hasPermissions = await BackgroundTracking._checkPermissions(
        requestPermissions: requestPermissions);
    if (!hasPermissions) {
      print('Location Always permission denied. Tracking not enabled.');
      await BackgroundTracking.stop();
      return;
    }

    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(BackgroundTracking._isEnabledPrefsKey, true);

    int alreadyRunTasks = 0;
    if (shouldRun) {
      try {
        await BackgroundTracking.sendLocationUpdate();
        alreadyRunTasks++;
      } catch (e) {
        print(e);
      }
    }

    // Schedule tasks now.
    try {
      await BackgroundTracking.scheduleDailyTrackingTask(
          numScheduledTasks: alreadyRunTasks, earliestTime: TimeOfDay.now());
    } catch (e) {
      print(e);
    }

    // Start background tracking at next midnight
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
    Duration timeUntilMidnight = nextMidnight.difference(now);

    // Register the periodic task, being schedule every night
    print(
        "Nightly scheduler for background tracking starting at ${nextMidnight} (in ${timeUntilMidnight})");
    await Workmanager().registerPeriodicTask(
      'scheduleDailyTasks',
      'scheduleDailyTasks', // ignored on iOS where you should use [uniqueName]
      tag: 'scheduleDailyTasks',
      frequency: Duration(days: 1),
      initialDelay: timeUntilMidnight + Duration(minutes: 5),
    );

    await BackgroundTracking.syncPendingFixes();
  }

  static Future<void> stop() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(BackgroundTracking._isEnabledPrefsKey, false);

    if (Platform.isAndroid) {
      await Workmanager()
          .cancelByTag('trackingTask'); // Method available only for Android
      await Workmanager().cancelByTag('scheduleDailyTasks');
    } else if (Platform.isIOS) {
      await Workmanager().cancelAll();
    }

    BackgroundTracking._clearSchedulerTaskQueue();
  }

  static Future<bool> isEnabled() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool(BackgroundTracking._isEnabledPrefsKey) ?? false;
  }

  static Future<bool> _hasLocationAlwaysPermission() async {
    PermissionStatus permStatus = await Permission.locationAlways.status;
    return permStatus.isGranted;
  }

  static Future<bool> _checkPermissions(
      {bool requestPermissions = true}) async {
    if (!requestPermissions) {
      return await BackgroundTracking._hasLocationAlwaysPermission();
    }

    // Step 1: Check the status of locationWhenInUse permission and request if necessary.
    if (!await Permission.locationWhenInUse.request().isGranted) {
      await openAppSettings(); // Open app settings for the user to manually enable the permission
    }

    if (await Permission.locationWhenInUse.request().isGranted) {
      // The locationAlways permission can not be requested directly, the user
      // has to request the locationWhenInUse permission first. Accepting this
      // permission by clicking on the 'Allow While Using App' gives the user
      // the possibility to request the locationAlways permission.
      if (!await Permission.locationAlways.request().isGranted) {
        await openAppSettings();
      }

      return await BackgroundTracking._hasLocationAlwaysPermission();
    }

    return false;
  }

  static List<TimeOfDay> _getRandomTimes(int numSamples,
      {TimeOfDay? minTime, TimeOfDay? maxTime}) {
    // Default values if minTime or maxTime are not provided
    minTime ??= TimeOfDay(hour: 0, minute: 0);
    maxTime ??= TimeOfDay(hour: 23, minute: 59);

    // Convert minTime and maxTime to minutes since midnight
    int minMinutes = minTime.hour * 60 + minTime.minute;
    int maxMinutes = maxTime.hour * 60 + maxTime.minute;

    var random = Random();
    var randomTimes = <TimeOfDay>[];
    for (var i = 0; i < numSamples; i++) {
      int randomMinutes =
          random.nextInt(maxMinutes - minMinutes + 1) + minMinutes;
      int randomHour = randomMinutes ~/ 60;
      int randomMinute = randomMinutes % 60;

      randomTimes.add(TimeOfDay(hour: randomHour, minute: randomMinute));
    }

    return randomTimes;
  }

  static Future<bool> canScheduleAt(DateTime datetime) async {
    List<String> schedulerTaskQueue =
        await BackgroundTracking._getSchedulerTaskQueue();
    String schedulerId = await BackgroundTracking._getSchedulerId(datetime);
    return !schedulerTaskQueue.contains(schedulerId);
  }

  static Future<bool> scheduleDailyTrackingTask(
      {int numScheduledTasks = 0, TimeOfDay? earliestTime}) async {
    try {
      // Ensure background tracking is enabled
      if (!await BackgroundTracking.isEnabled()) {
        throw Exception('Background tracking is not enabled.');
      }

      DateTime now = DateTime.now();

      // Ensure scheduling is allowed at the current time
      if (!await BackgroundTracking.canScheduleAt(now)) {
        throw Exception('Scheduling is not allowed at this time.');
      }

      await BackgroundTracking._appendScheduledDateTimeTaskQueue(now);

      int numTaskToSchedule =
          BackgroundTracking.tasksPerDay - numScheduledTasks;
      if (numTaskToSchedule <= 0) {
        throw Exception('All tasks for today have already been scheduled.');
      }

      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      double fractionOfDayElapsed =
          now.difference(startOfDay).inSeconds / Duration.secondsPerDay;
      double remainingFractionOfDay = 1 - fractionOfDayElapsed;

      int numTasks =
          max(1, (numTaskToSchedule * remainingFractionOfDay).ceil());

      final TimeOfDay minTime = earliestTime ?? TimeOfDay.now();
      List<TimeOfDay> randomTimes = _getRandomTimes(numTasks, minTime: minTime)
        ..sort((a, b) {
          final int aMinutes = a.hour * 60 + a.minute;
          final int bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });

      // Schedule tasks asynchronously
      for (var i = 0; i < randomTimes.length; i++) {
        final time = randomTimes[i];
        DateTime scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        print('Scheduled new tracking task to be run at ${scheduledTime}');

        await Workmanager().registerOneOffTask(
          'tracking_task_${scheduledTime.millisecondsSinceEpoch}_$i',
          'trackingTask',
          initialDelay: scheduledTime.difference(now),
          tag: 'trackingTask',
          constraints: Constraints(networkType: NetworkType.not_required),
        );
      }

      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  static Future<bool> sendLocationUpdate() async {
    try {
      // Check location permission
      if (await Geolocator.checkPermission() != LocationPermission.always) {
        throw Exception("Location permission is not set to 'always'.");
      }

      // Ensure background tracking is enabled
      if (!await BackgroundTracking.isEnabled()) {
        throw Exception("Background tracking is disabled.");
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      int batteryLevel = await Battery().batteryLevel;
      final maskedFix = _PendingFix(
        latitude: _maskCoordinate(position.latitude),
        longitude: _maskCoordinate(position.longitude),
        power: batteryLevel / 100.0,
        createdAt: DateTime.now().toUtc(),
      );

      await _enqueueMaskedFix(maskedFix);
      await BackgroundTracking.syncPendingFixes();
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  static Future<String> _getTrackingUUID() async {
    var prefs = await SharedPreferences.getInstance();
    String? trackingUuid = prefs.getString('trackingUUID');
    if (trackingUuid == null || trackingUuid.isEmpty) {
      trackingUuid = Uuid().v4();
      await prefs.setString('trackingUUID', trackingUuid);
    }
    return trackingUuid;
  }

  static Future<List<String>> _getSchedulerTaskQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getStringList(BackgroundTracking._scheduledTasksPrefsKey) ??
        [];
  }

  static Future<void> _clearSchedulerTaskQueue() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove(BackgroundTracking._scheduledTasksPrefsKey);
  }

  static Future<void> _appendScheduledDateTimeTaskQueue(
      DateTime datetime) async {
    List<String> taskQueue = await BackgroundTracking._getSchedulerTaskQueue();
    String currentId = await BackgroundTracking._getSchedulerId(datetime);

    if (!taskQueue.contains(currentId)) {
      // Prevent duplicates
      taskQueue.add(currentId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      prefs.setStringList(
          BackgroundTracking._scheduledTasksPrefsKey, taskQueue);
    }
  }

  static Future<String> _getSchedulerId(DateTime datetime) async {
    DateTime date = DateTime(datetime.year, datetime.month, datetime.day);
    return date.millisecondsSinceEpoch.toString();
  }

  static double _maskCoordinate(double value) {
    final masked = ((value / _gridSize).roundToDouble()) * _gridSize;
    return double.parse(masked.toStringAsFixed(6));
  }

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<void> _ensurePendingFixesLoaded() async {
    if (_pendingFixesLoaded) {
      return;
    }
    final prefs = await _getPrefs();
    final stored = prefs.getStringList(_pendingFixesPrefsKey) ?? [];
    _pendingFixes
      ..clear()
      ..addAll(stored.map((raw) {
        try {
          return _PendingFix.fromJson(jsonDecode(raw));
        } catch (e) {
          return null;
        }
      }).whereType<_PendingFix>());
    _pendingFixesLoaded = true;
  }

  static Future<void> _persistPendingFixes() async {
    final prefs = await _getPrefs();
    final encoded = _pendingFixes.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_pendingFixesPrefsKey, encoded);
  }

  static Future<void> _enqueueMaskedFix(_PendingFix fix) async {
    await _ensurePendingFixesLoaded();
    _pendingFixes.add(fix);
    await _persistPendingFixes();
  }

  static Future<void> syncPendingFixes() async {
    await _ensurePendingFixesLoaded();

    if (_pendingFixes.isEmpty) {
      await _cancelConnectivitySyncTask();
      return;
    }

    if (_isSyncingFixes) {
      return;
    }

    _isSyncingFixes = true;
    var allFixesSynced = true;
    try {
      while (_pendingFixes.isNotEmpty) {
        final nextFix = _pendingFixes.first;
        final success = await _sendPendingFix(nextFix);
        if (!success) {
          allFixesSynced = false;
          break;
        }
        _pendingFixes.removeAt(0);
        await _persistPendingFixes();
      }
    } finally {
      _isSyncingFixes = false;
    }

    if (_pendingFixes.isEmpty && allFixesSynced) {
      await _cancelConnectivitySyncTask();
    } else {
      await _scheduleConnectivitySyncTask();
    }
  }

  static Future<void> _scheduleConnectivitySyncTask() async {
    await Workmanager().registerOneOffTask(
      _syncTaskUniqueName,
      'syncPendingFixes',
      tag: _syncTaskTag,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Future<void> _cancelConnectivitySyncTask() async {
    try {
      await Workmanager().cancelByUniqueName(_syncTaskUniqueName);
    } catch (_) {}

    if (Platform.isAndroid) {
      try {
        await Workmanager().cancelByTag(_syncTaskTag);
      } catch (_) {}
    }
  }

  static Future<bool> _sendPendingFix(_PendingFix fix) async {
    try {
      final trackingUuid = await BackgroundTracking._getTrackingUUID();
      final response = await _fixesApi.create(
        fixRequest: FixRequest((b) => b
          ..coverageUuid = trackingUuid
          ..createdAt = fix.createdAt
          ..sentAt = DateTime.now().toUtc()
          ..point.replace(FixLocationRequest((p) => p
            ..latitude = fix.latitude
            ..longitude = fix.longitude))
          ..power = fix.power),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Failed to sync background fix: $e');
      return false;
    }
  }
}

class _PendingFix {
  final double latitude;
  final double longitude;
  final double power;
  final DateTime createdAt;

  _PendingFix({
    required this.latitude,
    required this.longitude,
    required this.power,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'power': power,
        'createdAt': createdAt.toIso8601String(),
      };

  factory _PendingFix.fromJson(Map<String, dynamic> json) {
    return _PendingFix(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      power: (json['power'] as num).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }
}
