import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:language_picker/language_picker.dart';
import 'package:language_picker/languages.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/settings_pages/components/hashtag.dart';
import 'package:mosquito_alert_app/pages/settings_pages/components/settings_menu_widget.dart';
import 'package:mosquito_alert_app/providers/user_provider.dart';
import 'package:mosquito_alert_app/utils/Application.dart';
import 'package:mosquito_alert_app/utils/BackgroundTracking.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage();

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isBgTrackingEnabled = false;
  bool isBgTrackingLoading = false;
  var packageInfo;
  late int? numTagsAdded;
  bool isLoading = true;
  late UsersApi usersApi;

  final languageCodes = [
    Language('bg_BG', 'Bulgarian', 'Bulgarian'),
    Language('bn_BD', 'Bengali', 'Bengali'),
    Language('ca_ES', 'Catalan', 'Catalan'),
    Language('de_DE', 'German', 'German'),
    Language('el_GR', 'Greek', 'Greek'),
    Language('en_US', 'English', 'English'),
    Language('es_ES', 'Spanish', 'Spanish'),
    Language('es_UY', 'Spanish (Uruguay)', 'Spanish (Uruguay)'),
    Language('eu_ES', 'Basque', 'Basque'),
    Language('fr_FR', 'French', 'French'),
    Language('gl_ES', 'Galician', 'Galician'),
    Language('hr_HR', 'Croatian', 'Croatian'),
    Language('hu_HU', 'Hungarian', 'Hungarian'),
    Language('it_IT', 'Italian', 'Italian'),
    Language(
        'lb_LU', 'Luxembourgish (Luxembourg)', 'Luxembourgish (Luxembourg)'),
    Language('mk_MK', 'Macedonian (Former Yugoslav Republic of Macedonia)',
        'Macedonian (Former Yugoslav Republic of Macedonia)'),
    Language('nl_NL', 'Dutch', 'Dutch'),
    Language('pt_PT', 'Protuguese', 'Protuguese'),
    Language('ro_RO', 'Romanian', 'Romanian'),
    Language('sl_SI', 'Slovenian (Slovenia)', 'Slovenian (Slovenia)'),
    Language('sq_AL', 'Albanian', 'Albanian'),
    Language('sr_RS', 'Serbian', 'Serbian'),
    Language('sv_SE', 'Swedish', 'Swedish'),
    Language('tr_TR', 'Turkish (Turkey)', 'Turkish (Turkey)'),
  ];

  @override
  void initState() {
    super.initState();
    MosquitoAlert apiClient =
        Provider.of<MosquitoAlert>(context, listen: false);
    usersApi = apiClient.getUsersApi();
    _logScreenView();
    getPackageInfo();
    initializeBgTracking();
    initializeTagsNum();
  }

  Future<void> _logScreenView() async {
    await FirebaseAnalytics.instance.logScreenView(screenName: '/settings');
  }

  void initializeBgTracking() async {
    isBgTrackingEnabled = await BackgroundTracking.isEnabled();
  }

  void getPackageInfo() async {
    PackageInfo _packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = _packageInfo;
    });
  }

  void initializeTagsNum() async {
    var hashtags = await UserManager.getHashtags();
    setState(() {
      numTagsAdded = hashtags?.length ?? 0;
      isLoading = false;
    });
  }

  void updateTagsNum(int newValue) {
    setState(() {
      numTagsAdded = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: key,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: isLoading
              ? Container(
                  height: MediaQuery.sizeOf(context).height * 0.8,
                  child: Center(
                      child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Style.colorPrimary),
                  )),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      SettingsMenuWidget(
                          MyLocalizations.of(context, 'select_language_txt'),
                          () {
                        _openLanguagePickerDialog();
                      }),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.black.withValues(alpha: 0.1))),
                        child: SwitchListTile(
                          title: Style.body(MyLocalizations.of(
                              context, 'background_tracking_title')),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              MyLocalizations.of(
                                  context, 'background_tracking_subtitle'),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          value: isBgTrackingEnabled,
                          activeThumbColor: Style.colorPrimary,
                          secondary: isBgTrackingLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Style.colorPrimary),
                                )
                              : null,
                          onChanged: (bool value) async {
                            if (value) {
                              setState(() {
                                isBgTrackingLoading = true;
                                isBgTrackingEnabled = true;
                              });
                              await BackgroundTracking.start(shouldRun: true)
                                  .whenComplete(() {
                                setState(() {
                                  isBgTrackingLoading = false;
                                });
                              });
                            } else {
                              setState(() {
                                isBgTrackingEnabled = false;
                              });
                              await BackgroundTracking.stop();
                            }
                            bool trackingStatus =
                                await BackgroundTracking.isEnabled();
                            setState(() {
                              isBgTrackingEnabled = trackingStatus;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.black.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ExpansionTile(
                                initiallyExpanded: numTagsAdded! > 0,
                                title: Row(
                                  children: [
                                    Style.body(
                                      MyLocalizations.of(context,
                                          'auto_tagging_settings_title'),
                                    ),
                                    Spacer(flex: 1),
                                    if (numTagsAdded! > 0)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(left: 8.0),
                                        padding: const EdgeInsets.all(4.0),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                        ),
                                        child: Text(
                                          '$numTagsAdded',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: Text(
                                      MyLocalizations.of(
                                          context, 'enable_auto_hashtag_text'),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600]),
                                    ),
                                  ),
                                  StringMultilineTags(
                                      updateTagsNum: updateTagsNum),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
        ),
      ),
    );
  }

  void _openLanguagePickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
            data: Theme.of(context).copyWith(primaryColor: Style.colorPrimary),
            child: LanguagePickerDialog(
                languages: languageCodes
                    .map((language) => Language(
                        language.isoCode,
                        MyLocalizations.of(context, language.isoCode),
                        language.nativeName))
                    .toList()
                  ..sort((a, b) => a.name.compareTo(b.name)),
                titlePadding: const EdgeInsets.all(8.0),
                searchCursorColor: Style.colorPrimary,
                searchInputDecoration: InputDecoration(
                    hintText: MyLocalizations.of(context, 'search_txt')),
                isSearchable: true,
                title: Text(MyLocalizations.of(context, 'select_language_txt')),
                onValuePicked: (Language language) async {
                  await _selectLanguage(language);
                },
                itemBuilder: (Language language) {
                  return Row(
                    children: <Widget>[
                      Text(MyLocalizations.of(context, language.isoCode)),
                    ],
                  );
                })),
      );

  Future<void> _selectLanguage(Language language) async {
    final isoCodeParts = language.isoCode.split('_');
    final languageCode = isoCodeParts[0];
    final countryCode = isoCodeParts.length > 1 ? isoCodeParts[1] : null;
    final locale = Locale(languageCode, countryCode);

    Utils.language = locale;
    UserManager.setLanguage(languageCode);
    UserManager.setLanguageCountry(countryCode);
    application.onLocaleChanged(locale);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userUuid = userProvider.user?.uuid;

    if (userUuid == null) return;

    try {
      final localeEnum = PatchedUserRequestLocaleEnum.values.firstWhere(
          (e) => e.name == languageCode,
          orElse: () => PatchedUserRequestLocaleEnum.en);

      final patchedUserRequest =
          PatchedUserRequest((b) => b..locale = localeEnum);

      await usersApi.partialUpdate(
        uuid: userUuid,
        patchedUserRequest: patchedUserRequest,
      );
    } catch (e) {
      print('Error updating language to server: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update language on server.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
