import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../pages/reports/adult/models/adult_report_data.dart';
import '../pages/reports/bite/models/bite_report_data.dart';
import '../pages/reports/sites/models/breeding_site_report_data.dart';
import '../utils/UserManager.dart';

const _pendingReportsKey = 'pending_reports_v1';
const _retryInterval = Duration(minutes: 1);

enum PendingReportType { adult, bite, breeding }

enum ReportSubmissionStatus { sent, queued }

class ReportSubmissionResult<T> {
  final ReportSubmissionStatus status;
  final T? data;

  const ReportSubmissionResult._(this.status, this.data);

  factory ReportSubmissionResult.sent(T? data) {
    return ReportSubmissionResult._(ReportSubmissionStatus.sent, data);
  }

  const ReportSubmissionResult.queued()
      : status = ReportSubmissionStatus.queued,
        data = null;
}

class PendingReport {
  final String id;
  final PendingReportType type;
  final Map<String, dynamic> payload;
  final List<String> attachments;
  final DateTime createdAt;

  PendingReport({
    required this.id,
    required this.type,
    required this.payload,
    required this.attachments,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'payload': payload,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PendingReport.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String;
    final type = PendingReportType.values.firstWhere(
      (element) => element.name == typeName,
      orElse: () => PendingReportType.bite,
    );

    final payload = Map<String, dynamic>.from(json['payload'] as Map);
    final attachments =
        (json['attachments'] as List).map((e) => e as String).toList();
    final parsedCreatedAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    final createdAt =
        parsedCreatedAt.isUtc ? parsedCreatedAt : parsedCreatedAt.toUtc();

    return PendingReport(
      id: json['id'] as String,
      type: type,
      payload: payload,
      attachments: attachments,
      createdAt: createdAt,
    );
  }
}

class ReportSyncService extends ChangeNotifier {
  ReportSyncService._(
    MosquitoAlert apiClient,
    this._prefs,
    this._attachmentsDir,
  )   : _observationsApi = apiClient.getObservationsApi(),
        _bitesApi = apiClient.getBitesApi(),
        _breedingSitesApi = apiClient.getBreedingSitesApi();

  final SharedPreferences _prefs;
  final Directory _attachmentsDir;

  final ObservationsApi _observationsApi;
  final BitesApi _bitesApi;
  final BreedingSitesApi _breedingSitesApi;

  final List<PendingReport> _queue = [];
  bool _isSyncing = false;
  Timer? _retryTimer;

  static Future<ReportSyncService> create({
    required MosquitoAlert apiClient,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final supportDir = await getApplicationSupportDirectory();
    final queueDir = Directory(p.join(supportDir.path, 'report_queue'));
    if (!await queueDir.exists()) {
      await queueDir.create(recursive: true);
    }

    final service = ReportSyncService._(apiClient, prefs, queueDir);
    await service._loadQueue();
    unawaited(service.syncPendingReports());
    return service;
  }

  int get pendingReports => _queue.length;

  Future<void> syncPendingReports() async {
    if (_isSyncing || _queue.isEmpty) {
      return;
    }

    _isSyncing = true;
    try {
      while (_queue.isNotEmpty) {
        final report = _queue.first;
        bool success = false;
        try {
          success = await _sendPendingReport(report);
        } catch (e, stack) {
          debugPrint('Failed to sync pending report ${report.id}: $e');
          debugPrintStack(stackTrace: stack);
          success = false;
        }
        if (success) {
          _queue.removeAt(0);
          await _persistQueue();
          await _deleteAttachments(report.attachments);
          notifyListeners();
        } else {
          break;
        }
      }
    } finally {
      _isSyncing = false;
      if (_queue.isNotEmpty) {
        _ensureRetryTimer();
      } else {
        _retryTimer?.cancel();
        _retryTimer = null;
      }
    }
  }

  Future<ReportSubmissionResult<Observation?>> submitAdultReport(
      AdultReportData reportData) async {
    try {
      final observation = await _sendAdultReport(reportData);
      if (observation != null) {
        return ReportSubmissionResult.sent(observation);
      }
    } catch (e) {
      debugPrint('Adult report submission failed: $e');
    }

    await _queueAdultReport(reportData);
    return const ReportSubmissionResult.queued();
  }

  Future<ReportSubmissionResult<void>> submitBiteReport(
      BiteReportData reportData) async {
    try {
      final response = await _sendBiteReport(reportData);
      if (response) {
        return ReportSubmissionResult.sent(null);
      }
    } catch (e) {
      debugPrint('Bite report submission failed: $e');
    }

    await _queueBiteReport(reportData);
    return const ReportSubmissionResult.queued();
  }

  Future<ReportSubmissionResult<void>> submitBreedingSiteReport(
      BreedingSiteReportData reportData) async {
    try {
      final response = await _sendBreedingReport(reportData);
      if (response) {
        return ReportSubmissionResult.sent(null);
      }
    } catch (e) {
      debugPrint('Site report submission failed: $e');
    }

    await _queueBreedingReport(reportData);
    return const ReportSubmissionResult.queued();
  }

  Future<void> _loadQueue() async {
    final stored = _prefs.getStringList(_pendingReportsKey) ?? [];
    var queueMutated = false;
    for (final entry in stored) {
      try {
        final map = jsonDecode(entry) as Map<String, dynamic>;
        final pending = PendingReport.fromJson(map);
        if (_normalizeQueuedReport(pending)) {
          queueMutated = true;
        }
        _queue.add(pending);
      } catch (e) {
        debugPrint('Failed to decode pending report: $e');
      }
    }

    if (_queue.isNotEmpty) {
      _ensureRetryTimer();
    }

    if (queueMutated) {
      await _persistQueue();
    }
  }

  Future<void> _persistQueue() async {
    final encoded = _queue.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_pendingReportsKey, encoded);
  }

  Future<void> _queueAdultReport(AdultReportData reportData) async {
    final id = const Uuid().v4();
    final attachments = await _storePhotoAttachments(reportData.photos, id);
    final payload = {
      'latitude': reportData.latitude,
      'longitude': reportData.longitude,
      'locationSource': reportData.locationSource.name,
      'environment': reportData.environmentAnswer?.name,
      'moment': reportData.eventMoment?.name,
      'notes': reportData.notes,
      'createdAt': reportData.createdAt.toUtc().toIso8601String(),
    };

    await _enqueue(PendingReport(
      id: id,
      type: PendingReportType.adult,
      payload: payload,
      attachments: attachments,
      createdAt: DateTime.now().toUtc(),
    ));
  }

  Future<void> _queueBiteReport(BiteReportData reportData) async {
    final id = const Uuid().v4();
    final payload = {
      'latitude': reportData.latitude,
      'longitude': reportData.longitude,
      'locationSource': reportData.locationSource.name,
      'environment': reportData.eventEnvironment?.name,
      'moment': reportData.eventMoment?.name,
      'notes': reportData.notes,
      'createdAt': reportData.createdAt.toUtc().toIso8601String(),
      'headBites': reportData.headBites,
      'leftHandBites': reportData.leftHandBites,
      'rightHandBites': reportData.rightHandBites,
      'chestBites': reportData.chestBites,
      'leftLegBites': reportData.leftLegBites,
      'rightLegBites': reportData.rightLegBites,
    };

    await _enqueue(PendingReport(
      id: id,
      type: PendingReportType.bite,
      payload: payload,
      attachments: const [],
      createdAt: DateTime.now().toUtc(),
    ));
  }

  Future<void> _queueBreedingReport(BreedingSiteReportData reportData) async {
    final id = const Uuid().v4();
    final attachments = await _storePhotoAttachments(reportData.photos, id);
    final payload = {
      'siteType': reportData.siteType,
      'hasWater': reportData.hasWater,
      'hasLarvae': reportData.hasLarvae,
      'latitude': reportData.latitude,
      'longitude': reportData.longitude,
      'locationSource': reportData.locationSource.name,
      'notes': reportData.notes,
      'createdAt': reportData.createdAt.toUtc().toIso8601String(),
    };

    await _enqueue(PendingReport(
      id: id,
      type: PendingReportType.breeding,
      payload: payload,
      attachments: attachments,
      createdAt: DateTime.now().toUtc(),
    ));
  }

  Future<void> _enqueue(PendingReport report) async {
    _normalizeQueuedReport(report);
    _queue.add(report);
    await _persistQueue();
    _ensureRetryTimer();
    notifyListeners();
    unawaited(syncPendingReports());
  }

  bool _normalizeQueuedReport(PendingReport report) {
    bool mutated = false;

    final createdAtRaw = report.payload['createdAt'];
    if (createdAtRaw is String) {
      final parsed = DateTime.tryParse(createdAtRaw);
      if (parsed != null) {
        final normalized = parsed.isUtc ? parsed : parsed.toUtc();
        final normalizedString = normalized.toIso8601String();
        if (normalizedString != createdAtRaw) {
          report.payload['createdAt'] = normalizedString;
          mutated = true;
        }
      }
    } else if (createdAtRaw == null) {
      report.payload['createdAt'] = report.createdAt.toIso8601String();
      mutated = true;
    }

    return mutated;
  }

  void _ensureRetryTimer() {
    _retryTimer ??= Timer.periodic(_retryInterval, (_) {
      unawaited(syncPendingReports());
    });
  }

  Future<bool> _sendPendingReport(PendingReport report) async {
    switch (report.type) {
      case PendingReportType.adult:
        return _sendQueuedAdult(report);
      case PendingReportType.bite:
        return _sendQueuedBite(report);
      case PendingReportType.breeding:
        return _sendQueuedBreeding(report);
    }
  }

  Future<Observation?> _sendAdultReport(AdultReportData data) async {
    final location = _buildLocationRequest(
      latitude: data.latitude!,
      longitude: data.longitude!,
      source: data.locationSource,
    );

    final photos = await _buildPhotosFromBytes(data.photos);
    final userTags = await UserManager.getHashtags();
    final tags = userTags != null ? BuiltList<String>(userTags) : null;

    final response = await _observationsApi.create(
      createdAt: data.createdAt.toUtc(),
      sentAt: DateTime.now().toUtc(),
      location: location,
      photos: photos,
      note: data.notes?.trim().isNotEmpty == true ? data.notes!.trim() : '',
      eventEnvironment: data.environmentAnswer?.name ?? '',
      eventMoment: data.eventMoment?.name,
      tags: tags,
    );

    if (response.statusCode == 201) {
      return response.data;
    }

    throw Exception('Unexpected status code ${response.statusCode}');
  }

  Future<bool> _sendBiteReport(BiteReportData data) async {
    final location = _buildLocationRequest(
      latitude: data.latitude!,
      longitude: data.longitude!,
      source: data.locationSource,
    );

    final counts = BiteCountsRequest((b) => b
      ..head = data.headBites
      ..leftArm = data.leftHandBites
      ..rightArm = data.rightHandBites
      ..chest = data.chestBites
      ..leftLeg = data.leftLegBites
      ..rightLeg = data.rightLegBites);

    final userTags = await UserManager.getHashtags();

    final biteRequest = BiteRequest((b) => b
      ..createdAt = data.createdAt.toUtc()
      ..sentAt = DateTime.now().toUtc()
      ..location.replace(location)
      ..note = data.notes
      ..eventEnvironment = data.eventEnvironment
      ..eventMoment = data.eventMoment
      ..tags = userTags != null ? ListBuilder<String>(userTags) : null
      ..counts.replace(counts));

    final response = await _bitesApi.create(biteRequest: biteRequest);
    if (response.statusCode == 201) {
      return true;
    }

    throw Exception('Unexpected status code ${response.statusCode}');
  }

  Future<bool> _sendBreedingReport(BreedingSiteReportData data) async {
    final location = _buildLocationRequest(
      latitude: data.latitude!,
      longitude: data.longitude!,
      source: data.locationSource,
    );

    final photos = await _buildPhotosFromBytes(data.photos);
    final userTags = await UserManager.getHashtags();
    final tags = userTags != null ? BuiltList<String>(userTags) : null;

    final response = await _breedingSitesApi.create(
      createdAt: data.createdAt.toUtc(),
      sentAt: DateTime.now().toUtc(),
      location: location,
      photos: photos,
      note: data.notes,
      tags: tags,
      siteType: data.siteType,
      hasWater: data.hasWater,
      hasLarvae: data.hasLarvae,
    );

    if (response.statusCode == 201) {
      return true;
    }

    throw Exception('Unexpected status code ${response.statusCode}');
  }

  Future<bool> _sendQueuedAdult(PendingReport report) async {
    final payload = report.payload;
    final latitude = (payload['latitude'] as num).toDouble();
    final longitude = (payload['longitude'] as num).toDouble();
    final source = payload['locationSource'] as String?;
    final parsedCreatedAt = DateTime.parse(payload['createdAt'] as String);
    final createdAt =
        parsedCreatedAt.isUtc ? parsedCreatedAt : parsedCreatedAt.toUtc();

    final photos = await _buildPhotosFromFiles(report.attachments);
    if (photos.isEmpty) {
      debugPrint(
          'Missing queued adult attachments, dropping report ${report.id}');
      return true;
    }

    final location = _buildLocationRequest(
      latitude: latitude,
      longitude: longitude,
      source: _sourceFromString(source),
    );

    final userTags = await UserManager.getHashtags();
    final tags = userTags != null ? BuiltList<String>(userTags) : null;

    final response = await _observationsApi.create(
      createdAt: createdAt,
      sentAt: DateTime.now().toUtc(),
      location: location,
      photos: photos,
      note: payload['notes'] as String? ?? '',
      eventEnvironment: payload['environment'] as String? ?? '',
      eventMoment: payload['moment'] as String?,
      tags: tags,
    );

    return response.statusCode == 201;
  }

  Future<bool> _sendQueuedBite(PendingReport report) async {
    final payload = report.payload;
    final latitude = (payload['latitude'] as num).toDouble();
    final longitude = (payload['longitude'] as num).toDouble();
    final source = _sourceFromString(payload['locationSource'] as String?);

    final location = _buildLocationRequest(
      latitude: latitude,
      longitude: longitude,
      source: source,
    );

    final counts = BiteCountsRequest((b) => b
      ..head = payload['headBites'] as int
      ..leftArm = payload['leftHandBites'] as int
      ..rightArm = payload['rightHandBites'] as int
      ..chest = payload['chestBites'] as int
      ..leftLeg = payload['leftLegBites'] as int
      ..rightLeg = payload['rightLegBites'] as int);

    final environment = payload['environment'] as String?;
    final moment = payload['moment'] as String?;

    BiteRequestEventEnvironmentEnum? eventEnvironment;
    BiteRequestEventMomentEnum? eventMoment;

    if (environment != null) {
      try {
        eventEnvironment = BiteRequestEventEnvironmentEnum.valueOf(environment);
      } catch (_) {
        eventEnvironment = null;
      }
    }

    if (moment != null) {
      try {
        eventMoment = BiteRequestEventMomentEnum.valueOf(moment);
      } catch (_) {
        eventMoment = null;
      }
    }

    final userTags = await UserManager.getHashtags();

    final biteCreatedAt = DateTime.parse(payload['createdAt'] as String);
    final biteRequest = BiteRequest((b) => b
      ..createdAt = biteCreatedAt.isUtc ? biteCreatedAt : biteCreatedAt.toUtc()
      ..sentAt = DateTime.now().toUtc()
      ..location.replace(location)
      ..note = payload['notes'] as String?
      ..eventEnvironment = eventEnvironment
      ..eventMoment = eventMoment
      ..tags = userTags != null ? ListBuilder<String>(userTags) : null
      ..counts.replace(counts));

    final response = await _bitesApi.create(biteRequest: biteRequest);
    return response.statusCode == 201;
  }

  Future<bool> _sendQueuedBreeding(PendingReport report) async {
    final payload = report.payload;
    final latitude = (payload['latitude'] as num).toDouble();
    final longitude = (payload['longitude'] as num).toDouble();
    final source = _sourceFromString(payload['locationSource'] as String?);

    final photos = await _buildPhotosFromFiles(report.attachments);
    if (photos.isEmpty) {
      debugPrint(
          'Missing queued breeding attachments, dropping report ${report.id}');
      return true;
    }

    final location = _buildLocationRequest(
      latitude: latitude,
      longitude: longitude,
      source: source,
    );

    final userTags = await UserManager.getHashtags();
    final tags = userTags != null ? BuiltList<String>(userTags) : null;

    final breedingCreatedAt = DateTime.parse(payload['createdAt'] as String);
    final response = await _breedingSitesApi.create(
      createdAt: breedingCreatedAt.isUtc
          ? breedingCreatedAt
          : breedingCreatedAt.toUtc(),
      sentAt: DateTime.now().toUtc(),
      location: location,
      photos: photos,
      note: payload['notes'] as String?,
      tags: tags,
      siteType: payload['siteType'] as String?,
      hasWater: payload['hasWater'] as bool?,
      hasLarvae: payload['hasLarvae'] as bool?,
    );

    return response.statusCode == 201;
  }

  LocationRequest _buildLocationRequest({
    required double latitude,
    required double longitude,
    required LocationRequestSource_Enum source,
  }) {
    return LocationRequest((b) => b
      ..source_ = source
      ..point.latitude = latitude
      ..point.longitude = longitude);
  }

  LocationRequestSource_Enum _sourceFromString(String? source) {
    if (source == null) {
      return LocationRequestSource_Enum.auto;
    }
    try {
      return LocationRequestSource_Enum.valueOf(source);
    } catch (_) {
      return LocationRequestSource_Enum.auto;
    }
  }

  Future<List<String>> _storePhotoAttachments(
      List<Uint8List> photos, String id) async {
    final filenames = <String>[];
    for (var i = 0; i < photos.length; i++) {
      final filename = '${id}_$i.jpg';
      final file = File(p.join(_attachmentsDir.path, filename));
      await file.writeAsBytes(photos[i], flush: true);
      filenames.add(filename);
    }
    return filenames;
  }

  Future<BuiltList<MultipartFile>> _buildPhotosFromBytes(
      List<Uint8List> photos) async {
    final uuid = const Uuid();
    final files = <MultipartFile>[];
    for (final photo in photos) {
      files.add(await MultipartFile.fromBytes(
        photo,
        filename: '${uuid.v4()}.jpg',
        contentType: DioMediaType('image', 'jpeg'),
      ));
    }
    return BuiltList<MultipartFile>(files);
  }

  Future<BuiltList<MultipartFile>> _buildPhotosFromFiles(
      List<String> attachments) async {
    final files = <MultipartFile>[];
    for (final attachment in attachments) {
      final file = File(p.join(_attachmentsDir.path, attachment));
      if (!await file.exists()) {
        continue;
      }
      final bytes = await file.readAsBytes();
      files.add(await MultipartFile.fromBytes(
        bytes,
        filename: attachment,
        contentType: DioMediaType('image', 'jpeg'),
      ));
    }
    return BuiltList<MultipartFile>(files);
  }

  Future<void> _deleteAttachments(List<String> attachments) async {
    for (final attachment in attachments) {
      final file = File(p.join(_attachmentsDir.path, attachment));
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }
}
