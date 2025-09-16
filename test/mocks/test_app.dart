import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mosquito_alert_app/app_config.dart';
import 'package:mosquito_alert_app/pages/main/drawer_and_header.dart';
import 'package:mosquito_alert_app/providers/auth_provider.dart';
import 'package:mosquito_alert_app/providers/device_provider.dart';
import 'package:mosquito_alert_app/providers/user_provider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'mock_api_service.dart';
import 'mock_mosquito_alert.dart';
import 'mock_localizations.dart';

/// Test version of the main app with mocks injected
class TestApp extends StatelessWidget {
  final MockMosquitoAlert mockApiClient;
  final AuthProvider authProvider;
  final UserProvider userProvider;
  final DeviceProvider deviceProvider;

  TestApp({
    required this.mockApiClient,
    required this.authProvider,
    required this.userProvider,
    required this.deviceProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: mockApiClient),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: deviceProvider),
      ],
      child: OverlaySupport(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mosquito Alert Test',
          theme: ThemeData(
            primarySwatch: Colors.orange,
            scaffoldBackgroundColor: Colors.white,
          ),
          localizationsDelegates: [
            MockMyLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en'),
          ],
          home: MainVC(), // Use MainVC like the real app
        ),
      ),
    );
  }
}

/// Initialize the test app with mocks
Future<TestApp> initializeTestApp() async {
  await AppConfig.setEnvironment('test');

  final authProvider = AuthProvider();
  await authProvider.init();

  final mockApiService = await MockApiService.init(authProvider: authProvider);
  final mockApiClient = mockApiService.mockClient;

  authProvider.setApiClient(mockApiClient);
  final userProvider = UserProvider(apiClient: mockApiClient);
  final deviceProvider = await DeviceProvider.create(apiClient: mockApiClient);

  return TestApp(
    mockApiClient: mockApiClient,
    authProvider: authProvider,
    userProvider: userProvider,
    deviceProvider: deviceProvider,
  );
}