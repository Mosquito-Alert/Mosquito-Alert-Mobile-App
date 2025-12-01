import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/adapters/observation_report.dart';
import 'package:mosquito_alert_app/core/models/photo.dart';
import 'package:mosquito_alert_app/features/reports/presentation/state/report_provider.dart';
import 'package:mosquito_alert_app/features/observations/observation_repository.dart';

class ObservationProvider extends ReportProvider<ObservationReport> {
  ObservationProvider({required ObservationRepository repository})
      : super(
            repository: repository,
            itemFactory: (item) => ObservationReport(item as Observation));

  Future<ObservationReport> createObservation({
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
    final observation = await (repository as ObservationRepository).create(
      createdAt: createdAt,
      locationSource: locationSource,
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      photos: photos,
      note: note,
      tags: tags,
      eventEnvironment: eventEnvironment,
      eventMoment: eventMoment,
    );
    return ObservationReport(observation);
  }
}
