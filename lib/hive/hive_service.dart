import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:mosquito_alert_app/features/bites/domain/models/bite_report.dart';
import 'package:mosquito_alert_app/features/breeding_sites/domain/models/breeding_site_report.dart';
import 'package:mosquito_alert_app/features/observations/domain/models/observation_report.dart';
import 'package:mosquito_alert_app/hive/hive_adapters.dart';
import 'package:mosquito_alert_app/hive/hive_registrar.g.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  Hive
    ..registerAdapter(BiteCountsAdapter())
    ..registerAdapter(BiteEventEnvironmentEnumAdapter())
    ..registerAdapter(BiteEventMomentEnumAdapter())
    ..registerAdapter(LocationAdapter())
    ..registerAdapter(ObservationEventEnvironmentEnumAdapter())
    ..registerAdapter(ObservationEventMomentEnumAdapter())
    ..registerAdapter(BreedingSiteSiteTypeEnumAdapter())
    ..registerAdapters();

  await Future.wait([
    // For ObservationRepository offline storage
    Hive.openBox<ObservationReport>('offline_observations'),
    // For BiteRepository offline storage
    Hive.openBox<BiteReport>('offline_bites'),
    // For BreedingSiteRepository offline storage
    Hive.openBox<BreedingSiteReport>('offline_breeding_sites'),
  ]);
}
