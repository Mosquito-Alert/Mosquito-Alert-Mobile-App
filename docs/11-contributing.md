# Contributing Guide

## 🤝 Welcome Contributors

Thank you for your interest in contributing to the Mosquito Alert Mobile App! This citizen science project helps researchers and public health officials understand mosquito populations and disease risks. Your contributions help make a real difference in public health research.

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [Development Setup](#development-setup)
3. [Code Standards](#code-standards)
4. [Contribution Workflow](#contribution-workflow)
5. [Testing Guidelines](#testing-guidelines)
6. [Documentation](#documentation)
7. [Community Guidelines](#community-guidelines)
8. [Recognition](#recognition)

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.19.0 or later
- **Dart SDK**: >=3.3.0 <4.0.0
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Git**: For version control
- **FVM**: Flutter Version Management (recommended)

### Development Tools

```bash
# Install FVM (Flutter Version Management)
dart pub global activate fvm

# Install Flutter version for this project
fvm install 3.19.0
fvm use 3.19.0

# Verify installation
fvm flutter --version
```

### Project Setup

```bash
# Clone the repository
git clone https://github.com/Mosquito-Alert/Mosquito-Alert-Mobile-App.git
cd Mosquito-Alert-Mobile-App

# Install dependencies
fvm flutter pub get

# Run code generation (if needed)
fvm flutter packages pub run build_runner build

# Run the app
fvm flutter run
```

## 🛠️ Development Setup

### Environment Configuration

1. **Create environment files:**
   ```bash
   cp assets/config/dev.json.example assets/config/dev.json
   cp assets/config/test.json.example assets/config/test.json
   ```

2. **Configure API endpoints and keys:**
   ```json
   {
     "api_url": "https://dev-api.mosquitoalert.com/api/v1",
     "google_maps_api_key": "your_maps_key_here",
     "firebase": {
       "project_id": "mosquito-alert-dev"
     }
   }
   ```

3. **Set up Firebase:**
   - Add `google-services.json` for Android
   - Add `GoogleService-Info.plist` for iOS

### IDE Configuration

#### VS Code Setup

Create `.vscode/settings.json`:
```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "dart.lineLength": 100,
  "files.insertFinalNewline": true
}
```

Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "args": ["--flavor", "dev"]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "args": ["--flavor", "prod"]
    }
  ]
}
```

## 📏 Code Standards

### Dart Style Guide

We follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart) with the following specific rules:

#### Formatting
- **Line length**: 100 characters maximum
- **Indentation**: 2 spaces (no tabs)
- **Trailing commas**: Required for all function calls and declarations with multiple parameters

#### Naming Conventions
```dart
// Classes: PascalCase
class ReportDataProvider extends ChangeNotifier { }

// Functions and variables: camelCase
void submitReport() { }
final String reportId = 'mosquito_001';

// Constants: SCREAMING_SNAKE_CASE
static const String API_BASE_URL = 'https://api.mosquitoalert.com';

// Private members: _camelCase
String _privateField;
void _privateMethod() { }

// Files and directories: snake_case
// report_data_provider.dart
// screens/report_form/
```

### Code Organization

#### File Structure
```dart
// Standard file header
import 'package:flutter/material.dart';

// Third-party packages
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

// Internal imports (ordered by dependency)
import '../models/report.dart';
import '../services/api_client.dart';
import '../utils/constants.dart';

class ExampleWidget extends StatelessWidget {
  // Public static members first
  static const String routeName = '/example';
  
  // Public instance members
  final String title;
  final VoidCallback? onTap;
  
  // Constructor
  const ExampleWidget({
    Key? key,
    required this.title,
    this.onTap,
  }) : super(key: key);
  
  // Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // Private methods last
  void _handleTap() {
    onTap?.call();
  }
}
```

#### Documentation Standards

```dart
/// A service that handles mosquito report submission and synchronization.
///
/// This service manages the entire lifecycle of reports, from creation
/// to synchronization with the backend API. It handles offline scenarios
/// by storing reports locally and syncing when connectivity is restored.
///
/// Example usage:
/// ```dart
/// final reportService = ReportService();
/// await reportService.submitReport(report);
/// ```
class ReportService {
  /// Submits a mosquito report to the backend API.
  ///
  /// If the device is offline, the report will be stored locally
  /// and synchronized when connectivity is restored.
  ///
  /// Throws [ValidationException] if the report data is invalid.
  /// Throws [NetworkException] if the submission fails due to network issues.
  ///
  /// Returns the updated report with server-assigned ID and status.
  Future<Report> submitReport(Report report) async {
    // Implementation...
  }
}
```

### Architecture Patterns

#### Provider Pattern Usage
```dart
// ✅ Good: Separate concerns clearly
class ReportDataProvider with ChangeNotifier {
  List<Report> _reports = [];
  bool _isLoading = false;
  
  List<Report> get reports => List.unmodifiable(_reports);
  bool get isLoading => _isLoading;
  
  Future<void> loadReports() async {
    _setLoading(true);
    try {
      _reports = await _reportService.getReports();
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// ❌ Bad: Mixing UI logic with business logic
class BadReportProvider with ChangeNotifier {
  void showReportDialog(BuildContext context) {
    // Don't put UI logic in providers
  }
}
```

#### Service Layer Pattern
```dart
// ✅ Good: Clean service interface
abstract class LocationService {
  Future<Position?> getCurrentPosition();
  Stream<Position> getPositionStream();
  Future<String?> getAddressFromCoordinates(double lat, double lng);
}

class LocationServiceImpl implements LocationService {
  @override
  Future<Position?> getCurrentPosition() async {
    // Implementation details
  }
}
```

## 🔄 Contribution Workflow

### Branch Strategy

We use **Git Flow** with the following branches:

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: Individual features
- `hotfix/*`: Critical bug fixes
- `release/*`: Release preparation

### Step-by-Step Process

1. **Create an Issue**
   ```markdown
   ## Issue Template
   
   ### Description
   Brief description of the feature/bug
   
   ### Acceptance Criteria
   - [ ] Specific requirement 1
   - [ ] Specific requirement 2
   
   ### Technical Notes
   Any technical considerations
   ```

2. **Fork and Branch**
   ```bash
   # Fork the repository on GitHub
   # Clone your fork
   git clone https://github.com/YOUR_USERNAME/Mosquito-Alert-Mobile-App.git
   
   # Create feature branch
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

3. **Development**
   ```bash
   # Make changes
   # Run tests frequently
   fvm flutter test
   
   # Check code style
   fvm flutter analyze
   
   # Format code
   fvm flutter format .
   ```

4. **Commit Guidelines**
   
   We follow [Conventional Commits](https://www.conventionalcommits.org/):
   
   ```bash
   # Format: type(scope): description
   
   # Examples:
   git commit -m "feat(reports): add photo compression for mosquito reports"
   git commit -m "fix(location): handle location permission denied gracefully"
   git commit -m "docs(api): update authentication documentation"
   git commit -m "test(providers): add unit tests for ReportDataProvider"
   ```
   
   **Types:**
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation changes
   - `style`: Code style changes (formatting, etc.)
   - `refactor`: Code refactoring
   - `perf`: Performance improvements
   - `test`: Adding or modifying tests
   - `chore`: Build process or auxiliary tool changes

5. **Pull Request**
   
   Create a PR with this template:
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update
   
   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Integration tests added/updated
   - [ ] Manual testing completed
   
   ## Screenshots
   If applicable, add screenshots
   
   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Comments added for complex code
   - [ ] Documentation updated
   - [ ] No new warnings introduced
   ```

## 🧪 Testing Guidelines

### Test Coverage Requirements
- **Minimum**: 80% overall coverage
- **Critical paths**: 95% coverage (authentication, report submission)
- **New features**: Must include tests

### Testing Strategy

#### Unit Tests
```dart
// test/unit/providers/report_data_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('ReportDataProvider', () {
    late ReportDataProvider provider;
    
    setUp(() {
      provider = ReportDataProvider();
    });
    
    test('should start new report with correct type', () {
      // Given
      const reportType = ReportType.mosquito;
      
      // When
      provider.startNewReport(reportType);
      
      // Then
      expect(provider.currentDraft?.type, equals(reportType));
    });
  });
}
```

#### Widget Tests
```dart
// test/widget/components/report_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ReportCard displays report information', (tester) async {
    // Given
    final report = createTestReport();
    
    // When
    await tester.pumpWidget(MaterialApp(
      home: ReportCard(report: report),
    ));
    
    // Then
    expect(find.text(report.notes!), findsOneWidget);
  });
}
```

#### Integration Tests
```dart
// integration_test/report_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('complete report submission flow', (tester) async {
    // Test complete user journey
  });
}
```

### Running Tests

```bash
# Unit tests
fvm flutter test

# Widget tests
fvm flutter test test/widget/

# Integration tests
fvm flutter test integration_test/

# Coverage report
fvm flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📚 Documentation

### Code Documentation
- **Public APIs**: Must have comprehensive dartdoc comments
- **Complex algorithms**: Inline comments explaining logic
- **Architecture decisions**: Document in relevant files

### Documentation Updates
When contributing, update:
- README.md if installation/setup changes
- API documentation for new endpoints
- Architecture documentation for structural changes
- User guides for new features

### Documentation Style

```dart
/// Calculates the distance between two geographic points using the Haversine formula.
///
/// This method is accurate for most practical purposes and accounts for the
/// Earth's curvature. For very precise calculations over long distances,
/// consider using more sophisticated geodetic calculations.
///
/// Parameters:
/// - [lat1], [lon1]: Coordinates of the first point in decimal degrees
/// - [lat2], [lon2]: Coordinates of the second point in decimal degrees
///
/// Returns the distance in meters.
///
/// Example:
/// ```dart
/// final distance = calculateDistance(
///   lat1: 41.3851, lon1: 2.1734,  // Barcelona
///   lat2: 40.4168, lon2: -3.7038, // Madrid
/// );
/// print('Distance: ${distance / 1000} km');
/// ```
double calculateDistance({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  // Implementation...
}
```

## 🌟 Community Guidelines

### Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and community discussion
- **Pull Request Reviews**: Technical discussions about code changes

### Best Practices

#### Be Respectful
- Provide constructive feedback
- Be patient with new contributors
- Acknowledge different perspectives and experiences

#### Be Collaborative
- Share knowledge and help others learn
- Review pull requests promptly and thoroughly
- Participate in discussions constructively

#### Be Professional
- Keep discussions focused and relevant
- Use clear, professional language
- Respect project maintainers' decisions

### Getting Help

If you need help:

1. **Check existing documentation**: README, docs/, and inline comments
2. **Search existing issues**: Someone might have faced the same problem
3. **Create a discussion**: For questions that aren't bug reports
4. **Ask in pull requests**: For specific implementation questions

## 🏆 Recognition

### Contributor Recognition

We value all contributions and recognize them in several ways:

- **Contributors list**: Maintained in README.md
- **Release notes**: Notable contributions mentioned
- **Community highlights**: Regular recognition of outstanding contributions

### Types of Contributions

We appreciate all types of contributions:

- **Code**: New features, bug fixes, performance improvements
- **Documentation**: Writing, editing, translating documentation
- **Testing**: Writing tests, manual testing, bug reports
- **Design**: UI/UX improvements, mockups, user research
- **Community**: Helping other users, moderating discussions

### Contribution Recognition Levels

- **First-time contributor**: Welcome badge and guidance
- **Regular contributor**: Recognition in release notes
- **Core contributor**: Invitation to review process participation
- **Maintainer**: Commit access and project governance participation

### Attribution

All contributors are listed in:
- `CONTRIBUTORS.md`
- GitHub's contributor graphs
- Release notes for significant contributions

## 📞 Contact

For questions about contributing:

- **General questions**: Create a GitHub Discussion
- **Bug reports**: Create a GitHub Issue
- **Security concerns**: Email security@mosquitoalert.com
- **Project governance**: Email maintainers@mosquitoalert.com

---

Thank you for contributing to Mosquito Alert! Your efforts help advance scientific research and public health initiatives worldwide. 🦟🔬
