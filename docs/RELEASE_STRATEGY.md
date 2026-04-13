# Release Strategy — v1.0 Free-Only

**Status:** v1.0 ships as a free-only app. All paid-tier code is preserved but hidden.
**Owner:** Jeanese
**Last updated:** 2026-04-11

---

## Summary

Habitra v1.0 is released as a free app with an optional Tip Jar. All features that
were previously behind `SubscriptionManager.isPro` remain in the codebase but are
hidden from the UI via `Services/FeatureAvailability.swift`. The subscription
infrastructure (`StoreKitManager`, `SubscriptionManager`, `PaywallView` internals)
is intact so paid tiers can be re-enabled cleanly later.

## Why two separate gate layers

| Gate | Purpose | v1.0 state |
|---|---|---|
| `SubscriptionManager.isPro` | Entitlement — does the user own Pro? | Unchanged. Still reads `StoreKitManager.isProUnlocked`. |
| `FeatureAvailability.*` | Availability — has the feature shipped? | All Pro features `false`. |

Keeping these separate means:
- The Pro code compiles and is testable (flip `FeatureAvailability` to `true` in a dev build).
- When paid tiers come back, we only touch `FeatureAvailability` — `SubscriptionManager` call sites across 20+ files stay untouched.
- The App Store reviewer only sees free features because entry points are hidden, not because features were deleted.

## Current Free vs Pro Split

### Free in v1.0 (shipping)
- Habit tracking (up to `freeHabitLimit = 5` habits)
- Streaks, XP, levels
- Today view + base stats
- Base streak themes (non-custom)
- Tip Jar (consumables: $1.99 / $4.99 / $9.99)
- Notifications, archived habits, CSV-less data export paths
- Base badges (non-seasonal)
- Privacy Policy, Terms of Use, Help Guide

### Pro (hidden in v1.0 via `FeatureAvailability`)
Source of truth: `Services/SubscriptionManager.swift`

| Flag | Feature |
|---|---|
| `canUseAINudges` | On-device AI nudges & coaching |
| `canUseMoodCheckin` | Mood check-in |
| `canUseHealthKit` | HealthKit auto-complete & dashboard |
| `canUseiCloudSync` | iCloud sync across devices |
| `canUseAllWidgets` | All widget sizes + StandBy |
| `canExportCSV` | CSV export |
| `canUseCustomThemes` | Custom streak themes |
| `canUseCategories` | Habit categories |
| `canUseQuests` | Quest tracker |
| `canUseCollections` | Badge collections |
| `canUseSeasonalBadges` | Seasonal badge engine |

### Unlimited habits
`freeHabitLimit = 5` remains the cap. When paid tiers return, `SubscriptionManager.habitLimit` already handles this correctly (`.max` for Pro users).

## App Store Connect state in v1.0

- **Removed from sale** (keep, do not delete):
  - `com.jeanese.habitra.pro.monthly`
  - `com.jeanese.habitra.pro.annual`
  - `com.jeanese.habitra.pro.lifetime`
- **Active:**
  - `com.jeanese.habitra.tip.small`
  - `com.jeanese.habitra.tip.medium`
  - `com.jeanese.habitra.tip.large`
- App description must not mention "Pro" or "Premium" tiers.
- Screenshots must only show free-tier features.
- "Coming Soon" section is allowed in-app but should NOT appear in App Store screenshots or metadata (Guideline 2.3.8).

## Where the hiding happens

Every hidden Pro entry point is marked with this comment:
```swift
// v1.0: hidden via FeatureAvailability — see docs/RELEASE_STRATEGY.md
```
Grep for `FeatureAvailability` or that comment to find every touchpoint.

Primary hide locations (as of v1.0):
- `Views/PulsrTabView.swift` — Coach tab hidden
- `Views/Settings/SettingsView.swift` — Pro upgrade card replaced with Roadmap section; HealthKit section gated
- `Views/Today/TodayView.swift` — habit limit alert copy updated; Quest/Collection `onAppear` setup gated
- `Views/Settings/CloudSyncSettingsView.swift` — Pro upsell removed
- `Views/Health/HealthDashboardView.swift` — Pro upsell removed
- `Views/AI/StreakThemeSelectorView.swift` — custom theme upsell removed
- `Views/Paywall/PaywallView.swift` — rewritten as Support + Roadmap (file name preserved so existing `PaywallView()` call sites still work)

## How to re-enable paid tiers

### 1. App Store Connect
- [ ] Subscription products → **Available for sale**:
  - `com.jeanese.habitra.pro.monthly`
  - `com.jeanese.habitra.pro.annual`
  - `com.jeanese.habitra.pro.lifetime`
- [ ] Update app description to mention Pro tiers
- [ ] Refresh screenshots to show Pro features

### 2. Code
- [ ] Flip desired flags in `Services/FeatureAvailability.swift` to `true`
- [ ] Grep for `FeatureAvailability` comment markers and un-hide entry points
- [ ] Restore `PaywallView` to the subscription-tier layout (see git tag `v1.0-free-only` for the original)
- [ ] Restore "Upgrade to Pro" copy in `TodayView` habit-limit alert (line ~130)
- [ ] Re-add Coach tab in `PulsrTabView.swift`
- [ ] Verify `SubscriptionManager.isPro` still reads from `StoreKitManager` (unchanged — should just work)

### 3. Testing checklist
- [ ] `Configuration.storekit` still contains all subscription + tip products
- [ ] Sandbox-purchase each tier and verify gates unlock
- [ ] Sandbox-purchase tips and verify they do NOT grant Pro
- [ ] Restore purchases flow works
- [ ] Free users still see the 5-habit limit
- [ ] Pro users see unlimited

## Git markers
- Tag the v1.0 commit: `git tag v1.0-free-only`
- When re-enabling Pro: `git diff v1.0-free-only main` shows every free-only change.

## Notes

- `StoreKitManager.isProUnlocked` has a `#if DEBUG` default of `true`. Leave this — dev builds still exercise the full Pro UI, which is useful for QA when flags are flipped.
- The Tip Jar code path in `SettingsView` currently shows only when `!storeKit.isProUnlocked`. In v1.0 this condition is always true in release builds, so tips are always visible — intentional.
