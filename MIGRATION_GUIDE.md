# Dialog Utilities Migration Guide

## Summary

This PR introduces a new `AppDialogs` utility class to replace the older `Utils.showAlert` and `Utils.showAlertYesNo` methods. The new approach provides better maintainability, consistency, and follows modern Flutter best practices.

## Changes Made

### 1. Created `lib/utils/app_dialogs.dart`

A new utility class with two main methods:

- **`AppDialogs.showAlert()`** - Replaces `Utils.showAlert()`
  - Shows a simple alert dialog with a title, message, and OK button
  - Platform-adaptive (Material for Android, Cupertino for iOS)
  - Named parameters for better clarity
  - Optional callback when OK is pressed
  
- **`AppDialogs.showConfirmation()`** - Replaces `Utils.showAlertYesNo()`
  - Shows a confirmation dialog with Yes/No buttons
  - Platform-adaptive (Material for Android, Cupertino for iOS)
  - Named parameters for better clarity
  - Required callback for Yes, optional for No

### 2. Migrated `lib/pages/my_reports_pages/components/reports_list_bites.dart`

Updated to use the new `AppDialogs` methods:

**Before:**
```dart
await Utils.showAlert(
  MyLocalizations.of(context, 'app_name'),
  MyLocalizations.of(context, 'save_report_ko_txt'),
  context,
);
```

**After:**
```dart
await AppDialogs.showAlert(
  context,
  title: MyLocalizations.of(context, 'app_name'),
  message: MyLocalizations.of(context, 'save_report_ko_txt'),
);
```

**Before:**
```dart
Utils.showAlertYesNo(
  MyLocalizations.of(context, 'delete_report_title'),
  MyLocalizations.of(context, 'delete_report_txt'),
  onDelete,
  context,
);
```

**After:**
```dart
AppDialogs.showConfirmation(
  context,
  title: MyLocalizations.of(context, 'delete_report_title'),
  message: MyLocalizations.of(context, 'delete_report_txt'),
  onYesPressed: onDelete,
);
```

### 3. Deprecated old methods in `lib/utils/Utils.dart`

Added `@deprecated` annotations to:
- `Utils.showAlert()`
- `Utils.showAlertYesNo()`

These methods remain functional but will show warnings encouraging migration to `AppDialogs`.

### 4. Added comprehensive tests

Created `test/unit/app_dialogs_test.dart` with tests covering:
- Alert dialog display and dismissal
- Confirmation dialog with Yes/No options
- Callback execution
- Proper dialog dismissal

## Benefits of the New Approach

### 1. **Better API Design**
- **Named parameters**: More readable and self-documenting
- **Context-first**: Follows Flutter conventions (context is the first parameter)
- **Clearer method names**: `showConfirmation` is more descriptive than `showAlertYesNo`

### 2. **Improved Maintainability**
- **Dedicated file**: Dialog utilities are in their own file, not mixed with unrelated utilities
- **Consistent styling**: Uses `Style.colorPrimary` for button colors consistently
- **Better documentation**: Comprehensive inline documentation

### 3. **Modern Flutter Practices**
- **Null safety**: Proper use of nullable types
- **VoidCallback**: Uses standard Flutter callback types
- **Platform adaptation**: Clear separation of Android/iOS implementations

### 4. **Consistency with Existing Code**
- Similar to `ReportDialogs` class in `lib/pages/reports/shared/utils/report_dialogs.dart`
- Follows the same patterns used in newer report controllers
- Positions the codebase for future dialog unification

## Migration Path for Other Code

If you have code using `Utils.showAlert` or `Utils.showAlertYesNo`, migrate using these examples:

### Migrating `showAlert`

**Old code:**
```dart
Utils.showAlert(
  'Title',
  'Message',
  context,
  onPressed: () {
    // do something
  },
  barrierDismissible: false,
);
```

**New code:**
```dart
AppDialogs.showAlert(
  context,
  title: 'Title',
  message: 'Message',
  onPressed: () {
    // do something
  },
  barrierDismissible: false,
);
```

### Migrating `showAlertYesNo`

**Old code:**
```dart
Utils.showAlertYesNo(
  'Title',
  'Message',
  () {
    // yes action
  },
  context,
);
```

**New code:**
```dart
AppDialogs.showConfirmation(
  context,
  title: 'Title',
  message: 'Message',
  onYesPressed: () {
    // yes action
  },
);
```

## Future Work

The following improvements could be considered in future PRs:

1. **Unify dialog utilities**: Consider merging `AppDialogs` and `ReportDialogs` into a single comprehensive dialog utility
2. **Remove deprecated methods**: After all code has migrated, remove `Utils.showAlert` and `Utils.showAlertYesNo`
3. **Add more dialog types**: Success, error, warning dialogs with standardized styling
4. **Extract localization**: Move common button labels (OK, Yes, No) to a dialog utility helper

## Testing

The implementation includes:
- Unit tests for both `showAlert` and `showConfirmation` methods
- Tests for callback execution
- Tests for dialog dismissal behavior
- Tests for both with and without optional callbacks

All existing tests continue to pass as the changes are backward-compatible.
