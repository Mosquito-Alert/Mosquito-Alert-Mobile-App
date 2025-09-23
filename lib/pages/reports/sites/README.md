# Breeding Site Report Flow

This module implements a conditional multi-step form for reporting mosquito breeding sites.

## Key Components

### BreedingSiteReportData
- Data model that holds all form state
- Includes conditional validation: `hasLarvae` only required if `hasWater == true`
- Provides user-friendly status descriptions

### BreedingSiteReportController  
- Main controller implementing step-by-step navigation
- Uses conditional logic to show/hide larvae question based on water status
- Dynamically generates step titles and progress indicators

### Pages
- `SiteTypeSelectionPage`: Choose between storm drain or other site type
- `PhotoSelectionPage`: Take 1-3 photos of the site
- `WaterQuestionPage`: Answer "Is there water?" (question_10)
- `LarvaeQuestionPage`: Answer "Can you see mosquito larvae?" (question_17) - **conditional**
- `LocationSelectionPage`: Select location on map
- `NotesAndSubmitPage`: Add optional notes and submit

## Conditional Flow Logic

### When user answers "Yes" to water question:
```
Site Type → Photos → Water (Yes) → Larvae → Location → Notes & Submit
Steps: 0     1       2           3       4         5
Titles: [Site Type, Photos, Water Status, Larvae Check, Location, Notes & Submit]
```

### When user answers "No" to water question:  
```
Site Type → Photos → Water (No) → Location → Notes & Submit
Steps: 0     1       2          3         4
Titles: [Site Type, Photos, Water Status, Location, Notes & Submit]
```

## Key Implementation Details

1. **Step Management**: Uses `_currentStep` index with conditional logic in `_currentPage` getter
2. **State Management**: `_nextStepAfterWater()` clears `hasLarvae` when water is absent
3. **Validation**: Data model enforces larvae answer only when water is present
4. **UI Updates**: Progress indicator and app bar title update automatically via `_stepTitles` getter

## Localization

- Water question uses `question_10` key
- Larvae question uses `question_17` key ("Can you see mosquito larvae?")
- Answer options use `question_10_answer_101` (Yes) and `question_10_answer_102` (No)