import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/my_reports_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/campaign_tutorial_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/settings_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:package_info/package_info.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  var packageInfo;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getPackageInfo();
  }

  void getPackageInfo() async {
    var _packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = _packageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          ListTile(
            title: Text(MyLocalizations.of(context, 'guide_tab')),
            leading: Icon(Icons.science),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CampaignTutorialPage()),
              );
            },
          ),
          ListTile(
            title: Text(MyLocalizations.of(context, 'settings_title')),
            leading: Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage()),
              );
            },
          ),
          ListTile(
            title: Text(MyLocalizations.of(context, 'info_tab')),
            leading: Icon(Icons.info),
            onTap: () {
              // TODO: About page
            },
          ),
          SizedBox(
            height: 100,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Style.bodySmall(
                  packageInfo != null
                      ? 'version ${packageInfo.version} (build ${packageInfo.buildNumber})'
                      : '',
                  fontSize: 8,
                  textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildListTile({required Widget title, required Widget leading, required int index, required Function onTap}) {
    return ListTile(
      title: title,
      leading: leading,
      tileColor: _selectedIndex == index ? Colors.orange : null,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        onTap();
      },
    );
  }


  Widget _uuidWithClipboard(){
    return FutureBuilder(
      future: UserManager.getUUID(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        print(snapshot.data);
        return Row(
          children: [
            Text(snapshot.data ?? '',
              style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 9
              )
            ),
            GestureDetector(
              child: Icon(
                Icons.copy_rounded,
                size: 18,
              ),
              onTap: () {
                final data = snapshot.data;
                if (data != null) {
                  Clipboard.setData(ClipboardData(text: data));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied to Clipboard'),
                    ),
                  );
                } else {
                  // Display an error message for troubleshooting
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: Unable to copy to clipboard. Data is null.'),
                    ),
                  );
                }
              },
            )
          ],            
        );
      }
    );
  }
}