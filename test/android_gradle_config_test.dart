import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android Gradle Configuration Tests', () {
    late File gradlePropertiesFile;

    setUpAll(() {
      gradlePropertiesFile = File('android/gradle.properties');
    });

    test('gradle.properties should not contain deprecated android.enableR8 setting', () {
      expect(gradlePropertiesFile.existsSync(), isTrue, 
        reason: 'gradle.properties file should exist');
      
      final content = gradlePropertiesFile.readAsStringSync();
      expect(content.contains('android.enableR8'), isFalse,
        reason: 'android.enableR8 was removed in Android Gradle Plugin 7.0 and should not be present');
    });

    test('gradle.properties should not contain deprecated buildconfig setting', () {
      expect(gradlePropertiesFile.existsSync(), isTrue, 
        reason: 'gradle.properties file should exist');
      
      final content = gradlePropertiesFile.readAsStringSync();
      expect(content.contains('android.defaults.buildfeatures.buildconfig'), isFalse,
        reason: 'android.defaults.buildfeatures.buildconfig is deprecated and should not be present');
    });

    test('gradle.properties should contain required settings', () {
      expect(gradlePropertiesFile.existsSync(), isTrue, 
        reason: 'gradle.properties file should exist');
      
      final content = gradlePropertiesFile.readAsStringSync();
      
      // Check for required settings
      expect(content.contains('android.useAndroidX=true'), isTrue,
        reason: 'android.useAndroidX should be enabled');
      expect(content.contains('android.enableJetifier=true'), isTrue,
        reason: 'android.enableJetifier should be enabled');
      expect(content.contains('org.gradle.jvmargs='), isTrue,
        reason: 'Gradle JVM args should be configured');
    });

    test('Android Gradle Plugin version should support compileSdk 35', () {
      final settingsFile = File('android/settings.gradle');
      expect(settingsFile.existsSync(), isTrue, 
        reason: 'settings.gradle file should exist');
      
      final content = settingsFile.readAsStringSync();
      final agpVersionMatch = RegExp(r'com\.android\.application.*version\s+["\']([0-9]+\.[0-9]+\.[0-9]+)["\']')
          .firstMatch(content);
      
      expect(agpVersionMatch, isNotNull, 
        reason: 'Should find Android Gradle Plugin version in settings.gradle');
      
      final versionString = agpVersionMatch!.group(1)!;
      final versionParts = versionString.split('.').map(int.parse).toList();
      
      // AGP 8.5.0+ supports compileSdk 35
      final isVersionSupported = versionParts[0] > 8 || 
          (versionParts[0] == 8 && versionParts[1] >= 5);
      
      expect(isVersionSupported, isTrue,
        reason: 'Android Gradle Plugin version $versionString should support compileSdk 35 (requires 8.5.0+)');
    });
  });
}