import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

/// Utility class for showing platform-adaptive dialogs throughout the app.
///
/// This class provides consistent dialog behavior across Android (Material)
/// and iOS (Cupertino) platforms. It replaces the older Utils.showAlert and
/// Utils.showAlertYesNo methods with a more maintainable approach.
class AppDialogs {
  /// Shows a simple alert dialog with a title, message, and OK button.
  ///
  /// The dialog adapts to the platform:
  /// - Android: Material AlertDialog
  /// - iOS: CupertinoAlertDialog
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing the dialog
  /// - [title]: Dialog title text
  /// - [message]: Dialog message/content text
  /// - [onPressed]: Optional callback when OK is pressed (defaults to closing dialog)
  /// - [barrierDismissible]: Whether tapping outside dismisses dialog (Android only, default: true)
  ///
  /// Returns a Future that completes when the dialog is dismissed.
  static Future<void> showAlert(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onPressed,
    bool barrierDismissible = true,
  }) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Text(message),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onPressed?.call();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Style.colorPrimary,
                ),
                child: Text(MyLocalizations.of(context, 'ok')),
              ),
            ],
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              title,
              style: const TextStyle(letterSpacing: -0.3),
            ),
            content: Column(
              children: <Widget>[
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(height: 1.2),
                ),
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  onPressed?.call();
                },
                child: Text(MyLocalizations.of(context, 'ok')),
              ),
            ],
          );
        },
      );
    }
  }

  /// Shows a confirmation dialog with Yes/No buttons.
  ///
  /// The dialog adapts to the platform:
  /// - Android: Material AlertDialog
  /// - iOS: CupertinoAlertDialog
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing the dialog
  /// - [title]: Dialog title text
  /// - [message]: Dialog message/content text
  /// - [onYesPressed]: Callback when Yes/Confirm is pressed
  /// - [onNoPressed]: Optional callback when No/Cancel is pressed
  /// - [barrierDismissible]: Whether tapping outside dismisses dialog (default: true)
  ///
  /// Returns a Future that completes when the dialog is dismissed.
  static Future<void> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onYesPressed,
    VoidCallback? onNoPressed,
    bool barrierDismissible = true,
  }) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Text(message),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onYesPressed();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Style.colorPrimary,
                ),
                child: Text(MyLocalizations.of(context, 'yes')),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onNoPressed?.call();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Style.colorPrimary,
                ),
                child: Text(MyLocalizations.of(context, 'no')),
              ),
            ],
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Column(
              children: <Widget>[
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  onYesPressed();
                },
                child: Text(MyLocalizations.of(context, 'yes')),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  onNoPressed?.call();
                },
                child: Text(MyLocalizations.of(context, 'no')),
              ),
            ],
          );
        },
      );
    }
  }
}
