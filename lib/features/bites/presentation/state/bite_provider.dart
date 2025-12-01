import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/adapters/bite_report.dart';
import 'package:mosquito_alert_app/features/reports/presentation/state/report_provider.dart';
import 'package:mosquito_alert_app/features/bites/bite_repository.dart';

class BiteProvider extends ReportProvider<BiteReport> {
  BiteProvider({required BiteRepository repository})
      : super(
            repository: repository,
            itemFactory: (item) => BiteReport(item as Bite));
}
