# Tech Debt Tracking Issues

This document lists GitHub issues that should be created to track the remaining technical debt items identified in the analysis.

## Critical Priority

None - All critical items have been addressed in this PR.

## High Priority Issues

### Issue 1: Rename Files to Follow snake_case Convention

**Title:** Refactor: Rename utility files to follow Dart snake_case convention

**Labels:** `tech-debt`, `refactoring`, `good-first-issue`

**Description:**
Multiple utility files use PascalCase instead of the recommended snake_case naming convention.

**Files to rename:**
- [ ] `lib/utils/Application.dart` → `application.dart`
- [ ] `lib/utils/BackgroundTracking.dart` → `background_tracking.dart`
- [ ] `lib/utils/InAppReviewManager.dart` → `in_app_review_manager.dart`
- [ ] `lib/utils/MessageNotification.dart` → `message_notification.dart`
- [ ] `lib/utils/MyLocalizations.dart` → `my_localizations.dart`
- [ ] `lib/utils/MyLocalizationsDelegate.dart` → `my_localizations_delegate.dart`
- [ ] `lib/utils/ObserverUtils.dart` → `observer_utils.dart`
- [ ] `lib/utils/PushNotificationsManager.dart` → `push_notifications_manager.dart`
- [ ] `lib/utils/UserManager.dart` → `user_manager.dart`
- [ ] `lib/utils/Utils.dart` → `utils.dart`

**How to fix:**
Use IDE refactoring (right-click → Refactor → Rename) to automatically update all imports.

**Estimated effort:** 1 day

**Reference:** See `TECH_DEBT.md` section 1.1

---

### Issue 2: Implement Centralized Logging System

**Title:** Feature: Replace print() statements with centralized logging

**Labels:** `tech-debt`, `enhancement`, `logging`

**Description:**
The codebase uses 40+ `print()` statements for logging. We should implement a centralized logging system.

**Tasks:**
- [ ] Add `logger` package to dependencies
- [ ] Create `lib/utils/app_logger.dart` utility
- [ ] Replace all `print()` statements with `AppLogger.info/warning/error()`
- [ ] Configure log levels for debug vs production builds
- [ ] Update documentation

**Benefits:**
- Control over log levels
- Ability to disable logs in production
- Better debugging experience
- Can route logs to monitoring services

**Estimated effort:** 2 days

**Reference:** See `TECH_DEBT.md` section 2.1 and `TECH_DEBT_SOLUTIONS.md`

---

### Issue 3: Extract Duplicated Initialization Logic

**Title:** Refactor: Extract duplicated initialization logic into AppInitializer service

**Labels:** `tech-debt`, `refactoring`

**Description:**
The initialization logic in `main()` and `callbackDispatcher()` is largely duplicated (~50 lines).

**Tasks:**
- [ ] Create `lib/services/app_initializer.dart`
- [ ] Extract common initialization logic
- [ ] Create `InitializationResult` class
- [ ] Update `main()` to use `AppInitializer`
- [ ] Update `callbackDispatcher()` to use `AppInitializer`
- [ ] Add tests for initialization logic

**Estimated effort:** 1-2 days

**Reference:** See `TECH_DEBT.md` section 3.2 and `TECH_DEBT_SOLUTIONS.md`

---

### Issue 4: Localize Hardcoded UI Strings

**Title:** i18n: Localize hardcoded UI strings marked with (HC)

**Labels:** `tech-debt`, `i18n`, `localization`

**Description:**
Many UI strings are hardcoded with `(HC)` prefix indicating they need localization.

**Examples:**
- '(HC) Take Photos'
- '(HC) Select Location'
- '(HC) Notes & Submit'
- '(HC) Please indicate where you spotted the mosquito:'

**Tasks:**
- [ ] Audit all hardcoded strings in the codebase
- [ ] Create localization keys in translation files
- [ ] Replace hardcoded strings with `MyLocalizations` calls
- [ ] Remove `(HC)` markers
- [ ] Test with different languages

**Estimated effort:** 3 days

**Reference:** See `TECH_DEBT.md` section 5.1

---

## Medium Priority Issues

### Issue 5: Add Comprehensive Test Coverage

**Title:** Testing: Improve unit and integration test coverage

**Labels:** `tech-debt`, `testing`, `quality`

**Description:**
Current test coverage is low. We should expand testing for critical functionality.

**Tasks:**
- [ ] Add `coverage` package for reporting
- [ ] Write unit tests for providers (AuthProvider, UserProvider, DeviceProvider)
- [ ] Write unit tests for services (ApiService, BackgroundTracking)
- [ ] Add widget tests for key user flows
- [ ] Set up coverage reporting in CI
- [ ] Target 70%+ coverage for critical paths

**Estimated effort:** 5 days

**Reference:** See `TECH_DEBT.md` section 6

---

### Issue 6: Convert Static Utility Classes to Instances

**Title:** Architecture: Refactor static utility classes to support dependency injection

**Labels:** `tech-debt`, `architecture`, `testability`

**Description:**
Several utility classes use static methods exclusively, making them difficult to test and tightly coupled.

**Classes to refactor:**
- [ ] `BackgroundTracking`
- [ ] `UserManager`
- [ ] `InAppReviewManager`
- [ ] `PushNotificationsManager`

**Benefits:**
- Easier to test (can mock dependencies)
- Better dependency injection
- More flexible architecture

**Estimated effort:** 5 days

**Reference:** See `TECH_DEBT.md` section 4.2 and `TECH_DEBT_SOLUTIONS.md`

---

### Issue 7: Improve Error Handling Consistency

**Title:** Refactor: Standardize error handling patterns

**Labels:** `tech-debt`, `error-handling`

**Description:**
Error handling is inconsistent across the codebase (some rethrow, some return false, some silently fail).

**Tasks:**
- [ ] Establish error handling guidelines
- [ ] Create custom exception classes
- [ ] Standardize error patterns:
  - Rethrow for unexpected errors
  - Return Result/Either types for expected errors
  - Always provide user feedback for UI operations
- [ ] Update existing code to follow patterns
- [ ] Document guidelines

**Estimated effort:** 3 days

**Reference:** See `TECH_DEBT.md` section 2.2

---

### Issue 8: Add Code Documentation

**Title:** Documentation: Add dartdoc comments to public APIs

**Labels:** `tech-debt`, `documentation`

**Description:**
Most classes and public methods lack documentation comments.

**Tasks:**
- [ ] Add dartdoc comments to all public classes
- [ ] Add dartdoc comments to all public methods
- [ ] Document complex algorithms
- [ ] Generate API documentation
- [ ] Add examples to documentation

**Estimated effort:** 3 days

**Reference:** See `TECH_DEBT.md` section 9.1 and `TECH_DEBT_SOLUTIONS.md`

---

## Low Priority Issues

### Issue 9: Convert TODOs to GitHub Issues

**Title:** Cleanup: Convert TODO comments to tracked GitHub issues

**Labels:** `tech-debt`, `cleanup`, `good-first-issue`

**Description:**
Several TODO comments exist in the codebase that should be tracked as proper issues.

**TODOs found:**
1. `lib/utils/InAppReviewManager.dart`: "Get a single api endpoint to retrieve report count?"
2. `lib/pages/my_reports_pages/components/reports_list_bites.dart`: "Handle pagination like in notifications page"

**Task:**
Create individual GitHub issues for each TODO and remove the comments.

**Estimated effort:** 1 hour

**Reference:** See `TECH_DEBT.md` section 7.2

---

### Issue 10: Add const Constructors Where Applicable

**Title:** Performance: Add const constructors to improve performance

**Labels:** `tech-debt`, `performance`, `good-first-issue`

**Description:**
Many widget constructors that could be `const` are not marked as such.

**Tasks:**
- [ ] Enable `prefer_const_constructors` lint rule (already in analysis_options.yaml)
- [ ] Run `dart fix --apply` to auto-fix many instances
- [ ] Manually fix remaining instances
- [ ] Verify builds still work

**Benefits:**
- Reduced memory usage
- Better rebuild performance
- Compile-time optimizations

**Estimated effort:** 1 day

**Reference:** See `TECH_DEBT.md` section 3.4

---

## Creating These Issues

To create these issues in GitHub:

1. Navigate to the repository's Issues page
2. Click "New Issue"
3. Copy the title, labels, and description from above
4. Add any additional context or team members
5. Assign to appropriate milestone/project
6. Create the issue

## Tracking Progress

Consider creating a GitHub Project board to track technical debt remediation:

- **Backlog:** All identified issues
- **Prioritized:** High-priority items for next sprint
- **In Progress:** Currently being worked on
- **Review:** Awaiting code review
- **Done:** Completed and merged

---

**Note:** These issues are organized by priority, but the team should re-evaluate priorities based on current business needs and development capacity.
