import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/features/fixes/services/permissions_manager.dart';
import 'package:mosquito_alert_app/core/localizations/MyLocalizations.dart';
import 'package:mosquito_alert_app/core/utils/style.dart';

class LocationInfoConsentPage extends StatelessWidget {
  final Future<void> Function()? onCompleted;

  const LocationInfoConsentPage({super.key, this.onCompleted});

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                MyLocalizations.of(context, 'tracking_perm_view_text'),
                style: TextStyle(
                    fontSize: 16, color: theme.textTheme.bodyMedium?.color),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColorDark,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(MyLocalizations.of(
                    context,
                    'turn_on_location_button',
                  )),
                  onPressed: () async {
                    await PermissionsManager.requestPermissions();
                    await onCompleted?.call();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
