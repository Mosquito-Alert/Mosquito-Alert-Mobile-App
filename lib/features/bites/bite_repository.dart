import 'package:built_collection/built_collection.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/adapters/bite_report.dart';
import 'package:mosquito_alert_app/features/reports/report_repository.dart';

class BiteRepository extends ReportRepository<BitesApi> {
  BiteRepository({required MosquitoAlert apiClient})
      : super(apiClient: apiClient, itemApi: apiClient.getBitesApi());

  Future<Bite> create({required BiteReportRequest request}) async {
    final biteRequest = BiteRequest((b) => b
      ..createdAt = request.createdAt
      ..sentAt = DateTime.now().toUtc()
      ..location = request.location.toBuilder()
      ..note = request.note
      ..tags = request.tags != null
          ? BuiltList<String>(request.tags!).toBuilder()
          : null
      ..eventEnvironment = request.eventEnvironment
      ..eventMoment = request.eventMoment
      ..counts = request.counts.toBuilder());
    final response = await itemApi.create(biteRequest: biteRequest);
    return response.data!;
  }
}
