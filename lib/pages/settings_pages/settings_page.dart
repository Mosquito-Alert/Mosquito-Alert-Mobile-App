import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_picker/language_picker.dart';

import 'package:language_picker/languages.dart';
import 'package:mosquito_alert_app/pages/info_pages/info_page_webview.dart';
import 'package:mosquito_alert_app/pages/settings_pages/campaign_tutorial_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/components/hashtag.dart';
import 'package:mosquito_alert_app/pages/settings_pages/components/settings_menu_widget.dart';
import 'package:mosquito_alert_app/pages/settings_pages/partners_page.dart';
import 'package:mosquito_alert_app/utils/Application.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:package_info/package_info.dart';
import 'package:workmanager/workmanager.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage();

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isBgTrackingEnabled = false;
  var packageInfo;
  late int? numTagsAdded;
  bool isLoading = true;
  late String userUuid;
  int userScore = 0;

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
    Language('lb_LU', 'Luxembourgish (Luxembourg)', 'Luxembourgish (Luxembourg)'),
    Language('mk_MK', 'Macedonian (Former Yugoslav Republic of Macedonia)', 'Macedonian (Former Yugoslav Republic of Macedonia)'),
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
    getPackageInfo();
    initializeBgTracking();
    initializeTagsNum();
    initializeUser();
  }

  void initializeBgTracking() async {
    isBgTrackingEnabled = await UserManager.getTracking();
  }

  void getPackageInfo() async {
    var _packageInfo = await PackageInfo.fromPlatform();
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

  void initializeUser() async {
    var _userUuid = await UserManager.getUUID();
    var _userScore = await UserManager.getUserScores();
    setState((){
      userUuid = _userUuid ?? '';
      userScore = _userScore ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(
          "Account (Hardcoded)",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
          child: isLoading
            ? _buildLoadingIndicator(context)
            : _buildAccountContent(context),          
        ),
      ),
    );
  }

  void _openLanguagePickerDialog() => showDialog(
    context: context,
    builder: (context) => Theme(
      data: Theme.of(context).copyWith(primaryColor: Style.colorPrimary),
      child: LanguagePickerDialog(
        languages: languageCodes.map(
          (language) => Language(
            language.isoCode,
            MyLocalizations.of(context, language.isoCode),
            language.nativeName,
          )).toList()..sort(
                  (a, b) => a.name.compareTo(b.name)
                ),
        titlePadding: EdgeInsets.all(8.0),
        searchCursorColor: Style.colorPrimary,
        searchInputDecoration: InputDecoration(
            hintText: MyLocalizations.of(context, 'search_txt')),
        isSearchable: true,
        title:
            Text(MyLocalizations.of(context, 'select_language_txt')),
        onValuePicked: (Language language) => setState(() {
              var languageCodes = language.isoCode.split('_');

              Utils.language =
                  Locale(languageCodes[0], languageCodes[1]);
              UserManager.setLanguage(languageCodes[0]);
              UserManager.setLanguageCountry(languageCodes[1]);
              application.onLocaleChanged(
                  Locale(languageCodes[0], languageCodes[1]));
            }),
        itemBuilder: (Language language) {
          return Row(
            children: <Widget>[
              Text(MyLocalizations.of(context, language.isoCode)),
            ],
          );
        })),
  );

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildAccountContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildProfileHeader(context),
        SizedBox(height: 10),
        Divider(),
        _buildSettingsSection(context),
        Divider(),
        _buildSupportSection(context),
        Divider(),
        _buildLegalSection(context),
        Divider(),
        uuidWithCopyToClipboard(),
        versionNumber(),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        _buildAvatar(),
        _buildUserName(),
        _buildUserScore(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black,
              width: 6,
            ),
          ),
          child: CircleAvatar(
            radius: 25,
            child: Icon(Icons.person, size: 40),
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildUserName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Anonymous',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildUserScore() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.star,
          color: Colors.orange,
          size: 15,
        ),
        SizedBox(width: 5),
        Text('$userScore'),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(MyLocalizations.of(context, "settings_title").toUpperCase()),
        SettingsMenuWidget(
          MyLocalizations.of(context, 'select_language_txt'),
          _openLanguagePickerDialog,
        ),
        _buildBackgroundTrackingSwitch(context),
        _buildAutoTaggingSettings(context),
      ],
    );
  }

  Widget _buildBackgroundTrackingSwitch(BuildContext context) {
    return SwitchListTile(
      title: Style.body(MyLocalizations.of(context, 'background_tracking_title')),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          MyLocalizations.of(context, 'background_tracking_subtitle'),
          style: TextStyle(fontSize: 11),
        ),
      ),
      value: isBgTrackingEnabled,
      activeColor: Colors.orange,
      onChanged: (bool value) async {
        await UserManager.setTracking(value);
        var trackingStatus = await UserManager.getTracking();
        setState(() {
          isBgTrackingEnabled = trackingStatus;
        });
        if (!isBgTrackingEnabled) {
          await Workmanager().cancelByTag('trackingTask');
        }
      },
    );
  }

  Widget _buildAutoTaggingSettings(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ExpansionTile(
            initiallyExpanded: numTagsAdded! > 0,
            title: Row(
              children: [
                Text(
                  MyLocalizations.of(context, 'auto_tagging_settings_title'),
                  style: TextStyle(fontSize: 14),
                ),
                Spacer(),
                if (numTagsAdded! > 0)
                  Container(
                    margin: EdgeInsets.only(left: 8.0),
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: Text(
                      '$numTagsAdded',
                      style: TextStyle(
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
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  MyLocalizations.of(context, 'enable_auto_hashtag_text'),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
              StringMultilineTags(updateTagsNum: updateTagsNum),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SUPPORT (Hardcoded)"),
        SettingsMenuWidget(
          MyLocalizations.of(context, 'info_scores_txt'),
          () => _navigateToWebview(context, 'url_scoring_1'),
        ),
        SettingsMenuWidget(
          MyLocalizations.of(context, 'about_the_project_txt'),
          () => _navigateToWebview(context, 'url_about_project'),
        ),
        SettingsMenuWidget(
          MyLocalizations.of(context, 'partners_txt'),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PartnersPage()),
          ),
        ),
        SettingsMenuWidget(
          MyLocalizations.of(context, 'coordination_txt'),
          () => _navigateToWebview(context, 'url_about_us'),
        ),
        SettingsMenuWidget(
          MyLocalizations.of(context, 'mailing_mosquito_samples'),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CampaignTutorialPage()),
          ),
          addDivider: false,
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("LEGAL (Hardcoded)"),
        SettingsMenuWidget(
          MyLocalizations.of(context, 'terms_of_use_txt'),
          () => _navigateToWebview(context, 'terms_link'),
        ),
        SettingsMenuWidget(
          MyLocalizations.of(context, 'privacy_txt'),
          () => _navigateToWebview(context, 'privacy_link'),
        ),
        SettingsMenuWidget(
          MyLocalizations.of(context, 'license_txt'),
          () => _navigateToWebview(context, 'lisence_link'),
          addDivider: false,
        ),
      ],
    );
  }

  void _navigateToWebview(BuildContext context, String urlKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoPageInWebview(MyLocalizations.of(context, urlKey)),
      ),
    );
  }

  Widget uuidWithCopyToClipboard(){
    return FutureBuilder(
      future: UserManager.getUUID(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        return Center(
          child: Row(
            mainAxisSize:MainAxisSize.min,
            children: [
              Text(
                'UUID: ',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
              Text(
                snapshot.data ?? '',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              GestureDetector(
                child: Icon(
                  Icons.copy_rounded,
                  size: 11,
                ),
                onTap: () {
                  final data = snapshot.data;
                  if (data != null) {
                    Clipboard.setData(ClipboardData(text: data));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(MyLocalizations.of(context, 'copied_to_clipboard_success')),
                      ),
                    );
                  } else {
                    // Display an error message for troubleshooting
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(MyLocalizations.of(context, 'copied_to_clipboard_error')),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        );
      }
    );
  }

  Widget versionNumber(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Text(
          packageInfo != null
            ? 'version ${packageInfo.version} (build ${packageInfo.buildNumber})'
            : '',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 11.0,                  
          ),
        ),
      ),
    );
  }
}
