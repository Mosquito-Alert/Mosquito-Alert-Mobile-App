# Tech Debt Solutions - Implementation Guide

This document provides solutions and implementation steps for the technical debt identified in `TECH_DEBT.md`.

## Quick Wins (Already Implemented)

### ✅ 1. Fixed forEach Async Anti-pattern

**File:** `lib/utils/BackgroundTracking.dart`

**Problem:** Using `forEach` with async callbacks doesn't wait for completion.

**Solution:** Replaced with `for-in` loop:
```dart
// Before (WRONG):
randomTimes.forEach((time) async {
  await Workmanager().registerOneOffTask(...);
});

// After (CORRECT):
for (final time in randomTimes) {
  await Workmanager().registerOneOffTask(...);
}
```

**Impact:** Background tracking tasks now reliably schedule all tasks.

### ✅ 2. Removed Duplicate InAppReviewManager

**Files Affected:**
- ❌ Removed: `lib/pages/reports/shared/utils/InAppReviewManager.dart`
- ✅ Updated: `lib/pages/reports/shared/utils/report_dialogs.dart` (import fixed)
- ✅ Kept: `lib/utils/InAppReviewManager.dart` (canonical location)

**Impact:** Single source of truth, easier maintenance.

### ✅ 3. Added Linting Configuration

**File:** `analysis_options.yaml` (new)

**Added Rules:**
- `avoid_function_literals_in_foreach_calls` - Prevents async forEach issues
- `avoid_print` - Encourages proper logging
- `prefer_const_constructors` - Performance optimization
- `file_names` - Enforces snake_case file naming
- 50+ other quality rules

**Usage:**
```bash
# Run analysis
fvm flutter analyze

# Fix auto-fixable issues
fvm dart fix --apply
```

### ✅ 4. Added flutter_lints Dependency

**File:** `pubspec.yaml`

**Added:**
```yaml
dev_dependencies:
  flutter_lints: ^5.0.0
```

## Pending High-Priority Fixes

### 📋 1. Rename Files to snake_case

**Manual Steps Required:**

```bash
# In lib/utils/
mv Application.dart application.dart
mv BackgroundTracking.dart background_tracking.dart
mv InAppReviewManager.dart in_app_review_manager.dart
mv MessageNotification.dart message_notification.dart
mv MyLocalizations.dart my_localizations.dart
mv MyLocalizationsDelegate.dart my_localizations_delegate.dart
mv ObserverUtils.dart observer_utils.dart
mv PushNotificationsManager.dart push_notifications_manager.dart
mv UserManager.dart user_manager.dart
mv Utils.dart utils.dart
```

**IMPORTANT:** Use IDE refactoring instead (right-click → Refactor → Rename) to automatically update all imports.

### 📋 2. Implement Centralized Logging

**Step 1:** Add logger dependency
```yaml
# pubspec.yaml
dependencies:
  logger: ^2.0.0
```

**Step 2:** Create logging utility
```dart
// lib/utils/app_logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: Level.debug, // Change to Level.warning for production
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
```

**Step 3:** Replace all `print()` statements

```bash
# Find all print statements
grep -r "print(" lib --include="*.dart"

# Replace pattern:
# print('message') → AppLogger.info('message')
# print('Error: $e') → AppLogger.error('Error', e)
```

### 📋 3. Extract Duplicated Initialization Logic

**Create:** `lib/services/app_initializer.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/providers/auth_provider.dart';
import 'package:mosquito_alert_app/providers/device_provider.dart';
import 'package:mosquito_alert_app/providers/user_provider.dart';
import 'package:mosquito_alert_app/services/api_service.dart';

class InitializationResult {
  final AuthProvider authProvider;
  final MosquitoAlert apiClient;
  final UserProvider userProvider;
  final DeviceProvider deviceProvider;

  InitializationResult({
    required this.authProvider,
    required this.apiClient,
    required this.userProvider,
    required this.deviceProvider,
  });
}

class AppInitializer {
  static Future<InitializationResult> initialize() async {
    try {
      await Firebase.initializeApp();
    } catch (err) {
      AppLogger.error('Firebase initialization failed', err);
    }

    final authProvider = AuthProvider();
    await authProvider.init();

    final apiService = await ApiService.init(authProvider: authProvider);
    final apiClient = apiService.client;

    authProvider.setApiClient(apiClient);
    
    final userProvider = UserProvider(apiClient: apiClient);
    final deviceProvider = await DeviceProvider.create(apiClient: apiClient);

    return InitializationResult(
      authProvider: authProvider,
      apiClient: apiClient,
      userProvider: userProvider,
      deviceProvider: deviceProvider,
    );
  }

  static Future<void> authenticateUser(
    AuthProvider authProvider,
    UserProvider userProvider,
    DeviceProvider deviceProvider,
  ) async {
    final username = authProvider.username;
    final password = authProvider.password;
    
    if (username == null || password == null) {
      throw Exception('No user credentials available');
    }

    await authProvider.login(username: username, password: password);
    await userProvider.fetchUser();
    
    await deviceProvider.registerDevice();
    if (deviceProvider.device != null) {
      await authProvider.setDevice(deviceProvider.device!);
    }
  }
}
```

**Usage in main.dart:**
```dart
Future<void> main({String env = 'prod'}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.setEnvironment(env);

  final result = await AppInitializer.initialize();
  
  final appConfig = await AppConfig.loadConfig();
  if (appConfig.useAuth) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<MosquitoAlert>.value(value: result.apiClient),
        ChangeNotifierProvider<AuthProvider>.value(value: result.authProvider),
        ChangeNotifierProvider<UserProvider>.value(value: result.userProvider),
        ChangeNotifierProvider<DeviceProvider>.value(value: result.deviceProvider),
      ],
      child: MyApp(),
    ),
  );
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final result = await AppInitializer.initialize();
    
    try {
      await AppInitializer.authenticateUser(
        result.authProvider,
        result.userProvider,
        result.deviceProvider,
      );
    } catch (e) {
      AppLogger.error('Authentication failed in background task', e);
      return Future.value(false);
    }

    BackgroundTracking.configure(apiClient: result.apiClient);
    
    switch (task) {
      case 'trackingTask':
        return BackgroundTracking.sendLocationUpdate();
      case 'scheduleDailyTasks':
        int numTaskAlreadyScheduled = inputData?['numTaskAlreadyScheduled'] ?? 0;
        return BackgroundTracking.scheduleDailyTrackingTask(
            numScheduledTasks: numTaskAlreadyScheduled);
      default:
        return Future.value(true);
    }
  });
}
```

## Testing Improvements

### 📋 1. Add Test Coverage

**Step 1:** Add coverage tooling
```yaml
# pubspec.yaml
dev_dependencies:
  coverage: ^1.6.0
```

**Step 2:** Run tests with coverage
```bash
# Generate coverage
fvm flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Step 3:** Add unit tests for critical paths
```dart
// test/utils/background_tracking_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mosquito_alert_app/utils/background_tracking.dart';

void main() {
  group('BackgroundTracking', () {
    test('scheduleDailyTrackingTask creates correct number of tasks', () async {
      // Test implementation
    });

    test('sendLocationUpdate fails when permission denied', () async {
      // Test implementation
    });
  });
}
```

## Architecture Improvements

### 📋 1. Convert Static Classes to Instances

**Example: BackgroundTracking**

```dart
// Before (static):
class BackgroundTracking {
  static late FixesApi _fixesApi;
  
  static void configure({required MosquitoAlert apiClient}) {
    _fixesApi = apiClient.getFixesApi();
  }
}

// After (instance):
class BackgroundTracking {
  final FixesApi fixesApi;
  final SharedPreferences prefs;
  
  BackgroundTracking({
    required this.fixesApi,
    required this.prefs,
  });
  
  Future<bool> sendLocationUpdate() async {
    // Use this.fixesApi instead of static _fixesApi
  }
}

// Usage with Provider:
Provider<BackgroundTracking>(
  create: (context) => BackgroundTracking(
    fixesApi: context.read<MosquitoAlert>().getFixesApi(),
    prefs: context.read<SharedPreferences>(),
  ),
)
```

### 📋 2. Add Documentation

**Template for public classes:**
```dart
/// Manages background location tracking for mosquito habitat monitoring.
///
/// This service handles permission requests, task scheduling, and location
/// data submission to the API. It uses the WorkManager plugin to ensure
/// reliable background execution.
///
/// Usage:
/// ```dart
/// final tracker = BackgroundTracking(
///   fixesApi: apiClient.getFixesApi(),
///   prefs: await SharedPreferences.getInstance(),
/// );
/// 
/// await tracker.start(shouldRun: true, requestPermissions: true);
/// ```
class BackgroundTracking {
  /// Creates a new [BackgroundTracking] instance.
  ///
  /// [fixesApi] is used to submit location fixes to the backend.
  /// [prefs] stores tracking state and scheduled task information.
  BackgroundTracking({
    required this.fixesApi,
    required this.prefs,
  });
}
```

## Migration Checklist

### Phase 1: Quick Fixes (1-2 days)
- [x] Fix forEach async anti-pattern
- [x] Remove duplicate InAppReviewManager
- [x] Add analysis_options.yaml
- [x] Add flutter_lints dependency
- [ ] Run `dart fix --apply` to auto-fix issues
- [ ] Fix remaining lint warnings manually

### Phase 2: Code Quality (3-5 days)
- [ ] Rename files to snake_case (use IDE refactoring)
- [ ] Implement centralized logging (AppLogger)
- [ ] Replace all print() statements
- [ ] Extract duplicated initialization logic
- [ ] Add const constructors where applicable

### Phase 3: Architecture (5-7 days)
- [ ] Convert static utility classes to instances
- [ ] Implement dependency injection
- [ ] Add comprehensive documentation
- [ ] Improve error handling consistency

### Phase 4: Testing (5-7 days)
- [ ] Add unit tests for providers
- [ ] Add unit tests for services
- [ ] Add widget tests for key flows
- [ ] Set up test coverage reporting
- [ ] Add integration tests for critical paths

### Phase 5: Localization (3-5 days)
- [ ] Identify all hardcoded strings
- [ ] Create localization keys
- [ ] Update UI to use MyLocalizations
- [ ] Remove (HC) markers

## Verification Steps

After each phase:

1. **Run static analysis:**
   ```bash
   fvm flutter analyze
   ```

2. **Run tests:**
   ```bash
   fvm flutter test
   ```

3. **Build the app:**
   ```bash
   fvm flutter build appbundle --debug
   ```

4. **Manual testing:**
   - Test background tracking
   - Test report submission
   - Test settings changes
   - Test app startup flow

## Maintenance Guidelines

To prevent new tech debt:

1. **Always run analysis before committing:**
   ```bash
   fvm flutter analyze
   fvm flutter test
   ```

2. **Use pre-commit hooks:**
   - Already configured in `.pre-commit-config.yaml`
   - Enforces code formatting

3. **Code review checklist:**
   - [ ] No print() statements (use AppLogger)
   - [ ] No forEach with async callbacks
   - [ ] No hardcoded strings (use localization)
   - [ ] Tests added for new features
   - [ ] Documentation added for public APIs
   - [ ] File names use snake_case
   - [ ] No duplicate code

4. **Regular tech debt reviews:**
   - Monthly review of TODOs
   - Quarterly codebase health check
   - Update TECH_DEBT.md as needed

## Additional Resources

- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Best Practices](https://docs.flutter.dev/testing/best-practices)
- [Dart Linter Rules Reference](https://dart.dev/tools/linter-rules)
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
