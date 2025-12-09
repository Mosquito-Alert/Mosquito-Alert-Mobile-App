import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/app.dart';
import 'package:mosquito_alert_app/app_config.dart';
import 'package:mosquito_alert_app/features/bites/bite_repository.dart';
import 'package:mosquito_alert_app/features/breeding_sites/breeding_site_repository.dart';
import 'package:mosquito_alert_app/features/fixes/services/tracking_service.dart';
import 'package:mosquito_alert_app/features/observations/observation_repository.dart';
import 'package:mosquito_alert_app/features/settings/presentation/state/settings_provider.dart';
import 'package:mosquito_alert_app/features/auth/presentation/state/auth_provider.dart';
import 'package:mosquito_alert_app/features/device/presentation/state/device_provider.dart';
import 'package:mosquito_alert_app/features/notifications/presentation/state/notification_provider.dart';
import 'package:mosquito_alert_app/features/notifications/notification_repository.dart';
import 'package:mosquito_alert_app/features/observations/presentation/state/observation_provider.dart';
import 'package:mosquito_alert_app/features/bites/presentation/state/bite_provider.dart';
import 'package:mosquito_alert_app/features/breeding_sites/presentation/state/breeding_site_provider.dart';
import 'package:mosquito_alert_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:country_codes/country_codes.dart';

import 'features/user/presentation/state/user_provider.dart';

Future<void> main({String env = 'prod'}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await AppConfig.setEnvironment(env);

  try {
    await Firebase.initializeApp();
  } catch (err) {
    print('$err');
  }

  await CountryCodes.init();

  final authProvider = AuthProvider();
  await authProvider.init();

  final ApiService apiService =
      await ApiService.init(authProvider: authProvider);
  final MosquitoAlert apiClient = apiService.client;

  authProvider.setApiClient(apiClient);
  final userProvider = await UserProvider.create(apiClient: apiClient);
  final deviceProvider = await DeviceProvider.create(apiClient: apiClient);

  final appConfig = await AppConfig.loadConfig();
  if (appConfig.useAuth) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<MosquitoAlert>.value(value: apiClient),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider()),
        ChangeNotifierProvider<DeviceProvider>.value(value: deviceProvider),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(
              repository: NotificationRepository(apiClient: apiClient)),
        ),
        ChangeNotifierProvider<ObservationProvider>(
          create: (_) => ObservationProvider(
              repository: ObservationRepository(apiClient: apiClient)),
        ),
        ChangeNotifierProvider<BiteProvider>(
          create: (_) =>
              BiteProvider(repository: BiteRepository(apiClient: apiClient)),
        ),
        ChangeNotifierProvider<BreedingSiteProvider>(
          create: (_) => BreedingSiteProvider(
              repository: BreedingSiteRepository(apiClient: apiClient)),
        )
      ],
      child: MyApp(),
    ),
  );
}

@pragma('vm:entry-point') // Mandatory if the App is using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Firebase.initializeApp();
    } catch (err) {
      print('$err');
    }

    final authProvider = AuthProvider();
    await authProvider.init();

    final ApiService apiService =
        await ApiService.init(authProvider: authProvider);
    final MosquitoAlert apiClient = apiService.client;

    authProvider.setApiClient(apiClient);

    final userProvider = await UserProvider.create(apiClient: apiClient);
    final deviceProvider = await DeviceProvider.create(apiClient: apiClient);
    String? username = authProvider.username;
    String? password = authProvider.password;
    if (username == null && password == null) {
      return Future.value(
          false); // No user credentials available, cannot proceed
    }
    try {
      await authProvider.login(username: username!, password: password!);
      await userProvider.fetchUser();
    } catch (e) {
      print('Error logging in: $e');
      return Future.value(false); // Login failed, cannot proceed
    }
    try {
      await deviceProvider.registerDevice();
      if (deviceProvider.device != null) {
        await authProvider.setDevice(deviceProvider.device!);
      }
    } catch (e) {
      print('Error registering device: $e');
    }

    await TrackingService.configure(apiClient: apiClient);
    // Support 3 possible outcomes:
    // - Future.value(true): task is successful
    // - Future.value(false): task failed and needs to be retried
    // - Future.error(): task failed.

    switch (task) {
      case 'trackingTask':
        // NOTE: do not use await, it should return a Future value
        try {
          await TrackingService.sendLocationNow();
        } catch (e) {
          return Future.error(e);
        }
        return Future.value(true);
      case 'scheduleDailyTasks':
        try {
          await TrackingService.scheduleDailyTasks();
        } catch (e) {
          return Future.error(e);
        }
        return Future.value(true);
      default:
        // If the task doesn't match, return true as a fallback
        return Future.value(true);
    }
  });
}
