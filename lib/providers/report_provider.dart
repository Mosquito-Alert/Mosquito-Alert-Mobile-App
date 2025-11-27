import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';

import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/providers/pagination_provider.dart';

abstract class ReportProvider<T> extends PaginationProvider<T> {
  ReportProvider({required super.apiClient});

  void _add({required T object}) {
    // Adding at the begginning to keep the most recent first
    objects.insert(0, object);
    notifyListeners();
  }

  Future<void> delete({required T object}) async {
    final uuid = (object as dynamic).uuid as String?;
    if (uuid == null) {
      throw Exception("Cannot delete report without uuid");
    }

    // Remove the deleted object from the list
    objects.removeWhere((obj) => (obj as dynamic).uuid == uuid);
    notifyListeners();
  }
}

class ObservationProvider extends ReportProvider<sdk.Observation> {
  late final sdk.ObservationsApi observationsApi;

  ObservationProvider({required super.apiClient}) {
    observationsApi = apiClient.getObservationsApi();
  }

  List<sdk.Observation> get observations => objects;

  Future<sdk.Observation> createObservation(
      {required DateTime createdAt,
      required sdk.LocationRequest location,
      required BuiltList<MultipartFile> photos,
      String? note,
      BuiltList<String>? tags,
      String? eventEnvironment,
      String? eventMoment}) async {
    final response = await observationsApi.create(
        createdAt: createdAt,
        sentAt: DateTime.now().toUtc(),
        location: location,
        photos: photos,
        note: note,
        tags: tags,
        eventEnvironment: eventEnvironment,
        eventMoment: eventMoment);

    final newObservation = response.data!;
    super._add(object: newObservation);
    return newObservation;
  }

  @override
  Future<Response<sdk.PaginatedObservationList>> fetchPage({
    required int page,
    required int pageSize,
  }) {
    return observationsApi.listMine(
      page: page,
      pageSize: pageSize,
      orderBy: BuiltList<String>([
        "-created_at",
      ]),
    );
  }

  @override
  Future<void> delete({required sdk.Observation object}) async {
    await observationsApi.destroy(uuid: object.uuid);
    super.delete(object: object);
  }
}

class BiteProvider extends ReportProvider<sdk.Bite> {
  late final sdk.BitesApi bitesApi;

  BiteProvider({required super.apiClient}) {
    bitesApi = apiClient.getBitesApi();
  }

  List<sdk.Bite> get bites => objects;

  Future<sdk.Bite> createBite(
      {required DateTime createdAt,
      required sdk.LocationRequest location,
      required sdk.BiteCountsRequest counts,
      String? note,
      BuiltList<String>? tags,
      sdk.BiteRequestEventEnvironmentEnum? eventEnvironment,
      sdk.BiteRequestEventMomentEnum? eventMoment}) async {
    final request = sdk.BiteRequest((b) => b
      ..createdAt = createdAt
      ..sentAt = DateTime.now().toUtc()
      ..location = location.toBuilder()
      ..note = note
      ..tags = tags?.toBuilder()
      ..eventEnvironment = eventEnvironment
      ..eventMoment = eventMoment
      ..counts = counts.toBuilder());

    final response = await bitesApi.create(biteRequest: request);

    final newBite = response.data!;
    super._add(object: newBite);
    return newBite;
  }

  @override
  Future<Response<sdk.PaginatedBiteList>> fetchPage({
    required int page,
    required int pageSize,
  }) {
    return bitesApi.listMine(
      page: page,
      pageSize: pageSize,
      orderBy: BuiltList<String>([
        "-created_at",
      ]),
    );
  }

  @override
  Future<void> delete({required sdk.Bite object}) async {
    await bitesApi.destroy(uuid: object.uuid);
    super.delete(object: object);
  }
}

class BreedingSiteProvider extends ReportProvider<sdk.BreedingSite> {
  late final sdk.BreedingSitesApi breedingSitesApi;

  BreedingSiteProvider({required super.apiClient}) {
    breedingSitesApi = apiClient.getBreedingSitesApi();
  }

  List<sdk.BreedingSite> get breedingSites => objects;

  Future<sdk.BreedingSite> createBreedingSite({
    required DateTime createdAt,
    required sdk.LocationRequest location,
    required BuiltList<MultipartFile> photos,
    String? note,
    BuiltList<String>? tags,
    String? siteType,
    bool? hasWater,
    bool? inPublicArea,
    bool? hasNearMosquitoes,
    bool? hasLarvae,
  }) async {
    final response = await breedingSitesApi.create(
        createdAt: createdAt,
        sentAt: DateTime.now().toUtc(),
        location: location,
        photos: photos,
        note: note,
        tags: tags,
        siteType: siteType,
        hasWater: hasWater,
        inPublicArea: inPublicArea,
        hasNearMosquitoes: hasNearMosquitoes,
        hasLarvae: hasLarvae);

    final newBreedingSite = response.data!;
    super._add(object: newBreedingSite);
    return newBreedingSite;
  }

  @override
  Future<Response<sdk.PaginatedBreedingSiteList>> fetchPage({
    required int page,
    required int pageSize,
  }) {
    return breedingSitesApi.listMine(
      page: page,
      pageSize: pageSize,
      orderBy: BuiltList<String>([
        "-created_at",
      ]),
    );
  }

  @override
  Future<void> delete({required sdk.BreedingSite object}) async {
    await breedingSitesApi.destroy(uuid: object.uuid);
    super.delete(object: object);
  }
}
