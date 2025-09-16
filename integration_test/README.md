# Integration Tests

This directory contains integration tests for the Mosquito Alert mobile app.

## Bite Report Creation Test

The `bite_report_creation_test.dart` file contains a comprehensive integration test that verifies users can create bite reports successfully through the happy path flow.

### Test Coverage

The test covers the following scenarios:

1. **App Initialization**: Starts the app with test environment and mocks
2. **Consent Flow**: Handles user consent and privacy policy acceptance
3. **Navigation**: Navigates from home page to bite report creation
4. **Form Completion**: Fills out all required bite report questions:
   - Number of bites (using + button)
   - Body part selection (tapping body diagram)
   - Location (using GPS coordinates 0,0 via mock)
   - Additional questions (environment, timing, etc.)
5. **API Submission**: Submits the report and verifies `bitesApi.create` is called
6. **Verification**: Confirms the API received correct location data (0,0)

### Mock Setup

The test uses comprehensive mocking:

- **Location Services**: GPS returns coordinates (0, 0) consistently
- **Permission Handler**: All location permissions are granted automatically
- **API Client**: `MockBitesApi` tracks API calls and captures request data
- **Localizations**: Mock translations for consistent UI text

### Key Features

- ✅ **GPS Mocking**: Returns coordinates (0, 0) as requested in requirements
- ✅ **API Verification**: Confirms `bitesApi.create` is called with proper data
- ✅ **Permission Handling**: All permissions granted for happy path testing
- ✅ **Complete Flow**: From consent through submission
- ✅ **Error Handling**: Graceful handling of optional UI elements

### Running the Test

```bash
# Run the integration test
fvm flutter test integration_test/bite_report_creation_test.dart

# Run with verbose output
fvm flutter test integration_test/bite_report_creation_test.dart --verbose
```

### Expected Output

When the test runs successfully, you should see:

```
✅ Success message found
🎯 Test Results:
   📍 Location sent to API: (0.0, 0.0)
   📊 Bite count: 1
   📅 Created at: [timestamp]
   ✅ Bite report creation test completed successfully
```

### Test Structure

The test is organized into helper functions for maintainability:

- `handleConsentFlow()`: Manages user consent and permissions
- `fillBiteReportQuestions()`: Handles bite report form completion
- `handleLocationForm()`: Manages location selection with GPS
- `answerAdditionalQuestions()`: Completes remaining form questions

### Mock Files

The test relies on these mock files:

- `test/mocks/mock_bites_api.dart`: Mock API that tracks `create()` calls
- `test/mocks/mock_mosquito_alert.dart`: Mock API client
- `test/mocks/test_app.dart`: Test app initialization with mocks
- `test/mocks/mock_localizations.dart`: Mock translations

### Requirements Satisfied

✅ **Single Bite Report**: Creates a single bite report as requested  
✅ **GPS Coordinates (0,0)**: Location service mocked to return (0,0)  
✅ **All Permissions**: Location permissions granted in happy path  
✅ **API Call Verification**: Confirms `bitesApi.create` is called  
✅ **Happy Path Only**: Focuses on successful flow without error cases  

The test validates that users can successfully create bite reports and that the API integration works correctly with the expected location data.