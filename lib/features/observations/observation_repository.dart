import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/models/photo.dart';
import 'package:mosquito_alert_app/core/repositories/report_repository.dart';

class ObservationRepository extends ReportRepository<ObservationsApi> {
  ObservationRepository({required MosquitoAlert apiClient})
      : super(itemApi: apiClient.getObservationsApi());

  Future<Observation> create({
    required DateTime createdAt,
    required LocationSource_Enum locationSource,
    required double locationLatitude,
    required double locationLongitude,
    required List<BaseUploadPhoto> photos,
    String? note,
    List<String>? tags,
    String? eventEnvironment,
    String? eventMoment,
  }) async {
    final locationRequest = LocationRequest((b) => b
      ..source_ = LocationRequestSource_Enum.valueOf(locationSource.name)
      ..point.latitude = locationLatitude
      ..point.longitude = locationLongitude);

    final List<MultipartFile> photosMultipart = [];
    for (final photo in photos) {
      photosMultipart.add(await photo.toMultipartFile());
    }
    final photosRequest = BuiltList<MultipartFile>(photosMultipart);

    final response = await itemApi.create(
      createdAt: createdAt,
      sentAt: DateTime.now().toUtc(),
      location: locationRequest,
      photos: photosRequest,
      note: note,
      tags: tags != null ? BuiltList<String>(tags) : null,
      eventEnvironment: eventEnvironment,
      eventMoment: eventMoment,
    );
    return response.data!;
  }
}
