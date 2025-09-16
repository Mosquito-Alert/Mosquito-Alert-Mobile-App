import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

// Mock MyLocalizations for testing
class MockMyLocalizations extends MyLocalizations {
  MockMyLocalizations() : super(const Locale('en'));

  @override
  String translate(String? key) {
    switch (key) {
      case 'notifications_title':
        return 'Notifications';
      case 'no_notifications_yet_txt':
        return 'No notifications yet';
      case 'no_reports_yet_txt':
        return 'No registered reports';
      case 'single_bite':
        return 'Bite';
      case 'plural_bite':
        return 'Bites';
      case 'no_bites':
        return 'No bites';
      case 'bite_report_bodypart_head':
        return 'Head';
      case 'bite_report_bodypart_chest':
        return 'Chest';
      case 'bite_report_bodypart_leftarm':
        return 'Left arm';
      case 'bite_report_bodypart_rightarm':
        return 'Right arm';
      case 'bite_report_bodypart_leftleg':
        return 'Left leg';
      case 'bite_report_bodypart_rightleg':
        return 'Right leg';
      case 'unknown':
        return 'Unknown';
      case 'continue_txt':
        return 'Continue';
      case 'current_location_txt':
        return 'Current Location';
      case 'select_location_txt':
        return 'Select Location';
      case 'send_report_txt':
        return 'Send Report';
      case 'save_report_ok_txt':
        return 'Report saved successfully';
      case 'save_report_ko_txt':
        return 'Error saving report';
      case 'biting_report_txt':
        return 'Bite Report';
      case 'question_1':
        return 'How many bites did you receive?';
      case 'question_2':
        return 'In which part of the body did you get bitten?';
      case 'question_3':
        return 'What time of day were you bitten?';
      case 'question_4':
        return 'Where were you when you got bitten?';
      case 'question_5':
        return 'When did you get bitten?';
      case 'question_14':
        return 'Location of the bite';
      case 'app_name':
        return 'Mosquito Alert';
      case 'NSLocationWhenInUseUsageDescription':
        return 'This app needs location access to record bite reports';
      default:
        return key ?? '';
    }
  }

  static MockMyLocalizations of(BuildContext context) {
    return MockMyLocalizations();
  }
}

class MockMyLocalizationsDelegate
    extends LocalizationsDelegate<MyLocalizations> {
  const MockMyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MyLocalizations> load(Locale locale) async {
    return MockMyLocalizations();
  }

  @override
  bool shouldReload(MockMyLocalizationsDelegate old) => false;
}
