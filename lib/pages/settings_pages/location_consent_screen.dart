import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/BackgroundTracking.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class LocationConsentScreen extends StatelessWidget {
  const LocationConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Style.title(
          MyLocalizations.of(context, 'enable_background_tracking'),
          fontSize: 16,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MyLocalizations.of(context, 'tutorial_title_13'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.primaryColorDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              MyLocalizations.of(context, 'tutorial_info_13'),
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColorDark,
                      side: BorderSide(color: theme.primaryColorDark),
                    ),
                    child: Text("No, thanks"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await BackgroundTracking.start(
                          shouldRun: true, requestPermissions: true);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColorDark,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(MyLocalizations.of(context, 'ok')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
