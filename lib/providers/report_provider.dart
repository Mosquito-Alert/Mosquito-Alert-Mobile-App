import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';

import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/providers/pagination_provider.dart';

abstract class ReportProvider<T> extends PaginationProvider<T> {
  ReportProvider({required super.apiClient});
}

class ObservationProvider extends ReportProvider<sdk.Observation> {
  late final sdk.ObservationsApi observationsApi;

  ObservationProvider({required super.apiClient}) {
    observationsApi = apiClient.getObservationsApi();
  }

  List<sdk.Observation> get observations => objects;

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
}

class BiteProvider extends ReportProvider<sdk.Bite> {
  late final sdk.BitesApi bitesApi;

  BiteProvider({required super.apiClient}) {
    bitesApi = apiClient.getBitesApi();
  }

  List<sdk.Bite> get bites => objects;

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
}

class BreedingSiteProvider extends ReportProvider<sdk.BreedingSite> {
  late final sdk.BreedingSitesApi breedingSitesApi;

  BreedingSiteProvider({required super.apiClient}) {
    breedingSitesApi = apiClient.getBreedingSitesApi();
  }

  List<sdk.BreedingSite> get breedingSites => objects;

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
}
