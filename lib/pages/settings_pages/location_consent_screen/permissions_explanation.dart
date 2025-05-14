import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/BackgroundTracking.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BackgroundTrackingInfoScreen extends StatelessWidget {
  const BackgroundTrackingInfoScreen({super.key});

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
            children: [
              Text(
                "(Hardcoded) By turning on the background tracking, we are going to request the permission to always access your location in the background. Your phone settings may be opened to enable it.",
                style: TextStyle(
                    fontSize: 16, color: theme.textTheme.bodyMedium?.color),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("(HC) Previous"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Show loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );

                        // Start background tracking
                        await BackgroundTracking.start(
                          shouldRun: true,
                          requestPermissions: true,
                        );

                        if (context.mounted) {
                          Navigator.pop(context); // Close loading dialog
                          Navigator.pop(context); // Back to previous screen
                          Navigator.pop(context); // Back to HomePage
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColorDark,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("(HC) Turn on"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
