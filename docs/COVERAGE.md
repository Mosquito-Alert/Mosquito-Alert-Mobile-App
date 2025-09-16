# Code Coverage Guide

This document explains how to work with code coverage in the Mosquito Alert Mobile App project.

## Overview

The project uses Flutter's built-in coverage tools combined with Codecov for reporting and visualization.

## Generating Coverage Locally

### Prerequisites
- Flutter SDK (managed via FVM)
- All dependencies installed (`fvm flutter pub get`)

### Running Tests with Coverage

```bash
# Generate coverage for all tests
fvm flutter test --coverage

# Generate coverage for specific test directories
fvm flutter test test/unit/ --coverage
fvm flutter test test/widget/ --coverage
```

### Viewing Coverage Results

After running tests with coverage, you'll find:
- `coverage/lcov.info` - LCOV format coverage data
- HTML reports can be generated using tools like `genhtml`

### Generating HTML Coverage Report (Optional)

If you have lcov tools installed:

```bash
# Install lcov (Ubuntu/Debian)
sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

## CI/CD Integration

### Automatic Coverage Reporting

Coverage is automatically generated and uploaded to Codecov when:
- Pull requests are created
- Code is pushed to the `main` branch

### GitHub Actions Workflow

The coverage process runs in `.github/workflows/analyze_and_test.yml`:

1. **Static Analysis**: `flutter analyze`
2. **Unit Tests**: `flutter test test/unit/`  
3. **Widget Tests**: `flutter test test/widget/`
4. **Coverage Generation**: `flutter test --coverage`
5. **Upload to Codecov**: Automated upload of `coverage/lcov.info`

## Coverage Badge

The README.md displays a live coverage badge showing the current coverage percentage from the main branch.

## Configuration

### codecov.yml

The project includes a `codecov.yml` configuration file that:
- Sets coverage precision to 2 decimal places
- Defines coverage range as 70-100%
- Excludes test files and generated files from coverage calculations
- Configures status checks to be informational

### Excluded Files

The following files/directories are excluded from coverage:
- `test/**/*` - Test files themselves
- `integration_test/**/*` - Integration test files  
- `**/*.g.dart` - Generated files
- `**/*.freezed.dart` - Freezed generated files
- `**/*.config.dart` - Configuration files
- `lib/generated/**/*` - Generated source files

## Best Practices

### Writing Testable Code

1. **Dependency Injection**: Use constructor injection for dependencies
2. **Pure Functions**: Prefer stateless functions when possible
3. **Separation of Concerns**: Keep UI logic separate from business logic
4. **Mock External Dependencies**: Use mocks for external services, APIs, etc.

### Coverage Goals

- **Unit Tests**: Aim for 80%+ coverage on business logic
- **Widget Tests**: Focus on critical UI components
- **Integration Tests**: Cover complete user workflows

### Improving Coverage

1. **Identify Gaps**: Use coverage reports to find untested code
2. **Prioritize Critical Paths**: Focus on core functionality first
3. **Add Unit Tests**: Prefer fast unit tests over slow integration tests
4. **Test Edge Cases**: Include error conditions and boundary cases

## Troubleshooting

### Coverage Not Generated

If `flutter test --coverage` doesn't create coverage files:
1. Ensure you have test files in the project
2. Check that tests are actually running and passing
3. Verify Flutter version compatibility

### Missing Coverage Data

If some files don't appear in coverage:
1. Ensure the files are imported/used by your application
2. Check that files aren't excluded in `codecov.yml`
3. Verify tests actually exercise the code paths

### Low Coverage Warnings

Low coverage warnings can indicate:
1. Missing tests for new functionality
2. Dead code that should be removed
3. Code that's difficult to test (consider refactoring)

## Integration with IDEs

### VS Code

Install the "Coverage Gutters" extension to view coverage directly in the editor:
1. Install the extension
2. Run tests with coverage
3. Use Command Palette: "Coverage Gutters: Display Coverage"

### Android Studio/IntelliJ

Use built-in coverage tools:
1. Run tests with coverage from the IDE
2. View coverage in the Coverage tool window
3. Navigate to uncovered lines directly