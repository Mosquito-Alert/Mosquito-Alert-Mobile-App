import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/features/breeding_sites/data/models/breeding_site_report_request.dart';
import 'package:mosquito_alert_app/features/breeding_sites/domain/models/breeding_site_report.dart';
import 'package:mosquito_alert_app/features/reports/data/report_repository.dart';

class BreedingSiteRepository
    extends
        ReportRepository<
          BreedingSiteReport,
          BreedingSite,
          BreedingSitesApi,
          BreedingSiteCreateRequest
        > {
  BreedingSiteRepository({required MosquitoAlert apiClient})
    : super(
        apiClient: apiClient,
        itemApi: apiClient.getBreedingSitesApi(),
        itemFactory: (item) => BreedingSiteReport.fromSdkBreedingSite(item),
        createRequestFactory: (json) =>
            BreedingSiteCreateRequest.fromJson(json),
        createRequestFromReport: (site) =>
            BreedingSiteCreateRequest.fromModel(site),
        createReportFromRequest: (request) =>
            BreedingSiteReport.fromCreateRequest(request),
        box: Hive.box<BreedingSiteReport>('offline_breeding_sites'),
      );

  @override
  String get repoName => 'breeding_sites';

  @override
  Future<BreedingSiteReport> sendCreateToApi({
    required BreedingSiteCreateRequest request,
  }) async {
    final List<MultipartFile> photosMultipart = [];
    for (final photo in request.photos) {
      photosMultipart.add(await photo.toMultipartFile());
    }
    final photosRequest = BuiltList<MultipartFile>(photosMultipart);

    final site_type_serializer =
        BreedingSiteSiteTypeEnum.serializer
            as PrimitiveSerializer<BreedingSiteSiteTypeEnum>;

    final response = await itemApi.create(
      createdAt: request.createdAt,
      sentAt: DateTime.now().toUtc(),
      location: request.location,
      photos: photosRequest,
      note: request.note,
      tags: request.tags != null ? BuiltList<String>(request.tags!) : null,
      siteType:
          (site_type_serializer.serialize(
                serializers,
                request.siteType,
                specifiedType: const FullType(BreedingSiteSiteTypeEnum),
              )
              as String),
      hasWater: request.hasWater,
      inPublicArea: request.inPublicArea,
      hasNearMosquitoes: request.hasNearMosquitoes,
      hasLarvae: request.hasLarvae,
    );
    return itemFactory(response.data!);
  }
}
