# Background Tracking Reference

## Historical Timeline

| Date (UTC) | Commit | Description |
| --- | --- | --- |
| 2020-07-13 | 6385b0a81b7ae6efde11a6a56b5fa275cba5b310 | First introduction of `flutter_background_geolocation`; Android-only `_bgTracking` listener scheduled continuous fixes with plugin-managed persistence. |
| 2022-04-01 | 266a19d605d7ed5aa579dcdc2aaf84abc70c2285 | Settings drawer still invoked `_bgTracking()` in `lib/pages/main/main_vc.dart`, confirming the plugin remained authoritative for background capture/masking (0.025° grid) and automatic retry. |
| 2024-04-11 | 7831ce40e3e78c755a8f09f968a840bf9bffa136 | Plugin removed; Workmanager + Geolocator periodic task added in `lib/main.dart`. Fix uploads became fire-and-forget HTTP calls, so offline devices silently dropped samples. |
| 2025-11-27 | (feature/offline-report-queue, uncommitted) | Completed migration to first-party tracking queue in `lib/utils/BackgroundTracking.dart` with SharedPreferences persistence, masking, and connectivity-aware retries. |

## Sampling Strategy Timeline

| Date Range | Mechanism | Notes |
| --- | --- | --- |
| 2020-07 → 2024-04 | `flutter_background_geolocation` with `locationUpdateInterval = 4h48m` | Deterministic cadence (~5 fixes/day) evenly spaced over 24h; plugin buffered offline data automatically. |
| 2024-04 → 2025-03 | `Workmanager.registerPeriodicTask('backgroundTracking', ...)` | Still deterministic 4h48m cadence, but fixes were only sent immediately; failures were dropped because no queue existed. |
| 2025-03 → 2025-11 | `BackgroundTracking.scheduleDailyTrackingTask` (fraction-of-day scaling) | Each midnight run sampled uniformly within the remaining portion of the day; enabling tracking late meant fewer than five runs could execute that day, mirroring legacy behavior users already saw. |
| 2025-11-XX → 2025-11-27 | Temporary "schedule all remaining slots" experiment | Always queued every unsent slot, removing the scaling heuristic but deviating from production expectations. |
| 2025-11-27 onward | Fractional scaling restored + offline persistence | Reinstated the scaling heuristic while keeping the new persistence, masking, and connectivity-aware retries. |

### How Fractional Scaling Works

- Let `tasksPerDay = 5` and `numScheduledTasks` be how many runs have already executed today.
- When tracking turns on, we compute the remaining fraction of the current day: `remaining = 1 - (elapsedSeconds / 86,400)`.
- Number of random slots to queue immediately = `max(1, ceil((tasksPerDay - numScheduledTasks) * remaining))`.
- Example: enabling at 14:00 (50,400 seconds elapsed) yields `remaining ≈ 0.4167`; with zero runs so far we schedule `ceil(5 * 0.4167) = 3` random fixes between 14:00 and 23:59.
- At midnight a new pass runs, resetting counts and sampling five fresh times across the full next day.

## Requirements To Restore Legacy Reliability

1. Capture exactly five fixes per day at random times whenever background tracking is enabled, regardless of connectivity.
2. Mask each fix immediately using the historical 0.025° grid.
3. Persist every masked fix locally until the API acknowledges ingestion.
4. Retry syncing automatically whenever the device regains connectivity; no dependency on the third-party plugin.

## Implementation Plan & Status (Nov 27 2025)

- [x] Centralize scheduling, masking, queueing, and sync logic in `lib/utils/BackgroundTracking.dart`.
- [x] Persist pending fixes as JSON in SharedPreferences and attach a deterministic `trackingUUID` so the server can group coverage windows.
- [x] Guarantee five random executions per calendar day (removed the fractional-day throttle so we always schedule the remaining slots).
- [x] Automatically register a Workmanager job that retries `syncPendingFixes()` once the OS reports the network is available.
- [x] Document verification steps (manual + automated) so we can regress-test after implementation.

## Implementation Notes – Nov 27 2025

- `lib/utils/BackgroundTracking.dart`
   - `scheduleDailyTrackingTask` once again scales the number of random samples by the remaining fraction of the day (matching legacy cadence expectations) while still giving each Workmanager task a unique ID.
   - Masked fixes are persisted immediately and, if syncing fails, we register a `syncPendingFixes` Workmanager one-off job that requires connectivity. Once the queue drains we cancel that job.
- `lib/main.dart`
   - `callbackDispatcher` now understands the new `syncPendingFixes` task and passes a `TimeOfDay` floor into each nightly scheduling run.
- Validation checklist:
   1. Toggle tracking on and confirm five `trackingTask` registrations appear for the current day.
   2. Trigger a tracking run while offline, verify the fix enters `_pendingFixes`, then come back online and confirm the `syncPendingFixes` job flushes it immediately.
   3. Run `fvm flutter analyze` + `fvm flutter test` before committing.

## Next Steps

1. Capture console logs/screenshots of the manual validation scenarios above for documentation.
2. Consider lightweight integration tests that stub Workmanager to assert scheduling counts.
3. Explore telemetry (e.g., Sentry breadcrumbs) for queued vs. synced fix counts to monitor production health.

(Keep this document updated as we implement and test the remaining steps.)
