# Habitra -- App Store Product Page Strategy

A complete guide for building the default product page, custom product pages, screenshot production, and App Review notes.

---

## TABLE OF CONTENTS

1. [Default Product Page](#1-default-product-page)
2. [Screenshot Production Plan](#2-screenshot-production-plan)
3. [Custom Product Pages](#3-custom-product-pages)
4. [App Preview Videos](#4-app-preview-videos)
5. [App Review Notes](#5-app-review-notes)
6. [Product Page Optimization (PPO) Tests](#6-product-page-optimization-ppo-tests)
7. [Device Matrix](#7-device-matrix)
8. [Production Checklist](#8-production-checklist)

---

## 1. DEFAULT PRODUCT PAGE

### Metadata (enter in App Store Connect)

| Field | Value |
|-------|-------|
| **Name** | Habitra - AI Habit Tracker |
| **Subtitle** | Build habits that actually stick |
| **Category** | Health & Fitness |
| **Secondary Category** | Productivity |
| **Promotional Text** | AI-powered habit tracking that learns your patterns. Predict your streaks, not your privacy. 100% on-device. No accounts. No data collection. |
| **Keywords** | habit,streak,routine,wellness,productivity,private,offline,AI,coach,HealthKit,mood,widget,tracker |

> **Keyword notes:** 100-char limit. Don't repeat words from the app name (Apple indexes those automatically). Avoid plurals if the singular is included. Separate with commas, no spaces.

### Description

Use the full description from `docs/apple-store-connect-guide.md` Section 7. It covers:
- Smart Habit Tracking
- AI-Powered Insights (Pro)
- Mood & Wellness Tracking (Pro)
- Apple Health Integration (Pro)
- Advanced Analytics & Insights
- Home Screen Widgets
- Privacy Is Sacred
- Flexible Pricing

### What's New (v1.0)

```
Build habits that actually stick -- with AI that understands YOUR patterns, not your data.

- Smart habit tracking with streaks and milestone celebrations
- AI-powered predictions: know when you're at risk of breaking a streak
- Mood tracking with journal entries and sentiment analysis
- Apple Health integration for steps, sleep, heart rate, and more
- Beautiful home screen and lock screen widgets
- Weekly AI-generated coaching recaps
- Badges, quests, and XP leveling system
- 100% private: everything runs on your device
```

---

## 2. SCREENSHOT PRODUCTION PLAN

### Required Device Sizes

| Device Class | Resolution | Simulator Target | Required |
|-------------|-----------|-----------------|----------|
| iPhone 6.9" | 1320 x 2868 | iPhone 16 Pro Max | Yes |
| iPhone 6.7" | 1290 x 2796 | iPhone 15 Pro Max | Yes |
| iPhone 6.5" | 1242 x 2688 | iPhone 11 Pro Max | Optional (use 6.7" fallback) |
| iPhone 5.5" | 1242 x 2208 | iPhone 8 Plus | Only if min deploy < iOS 16 |
| iPad 13" | 2064 x 2752 | iPad Pro 13" (M4) | Yes (app targets iPad) |
| iPad 12.9" | 2048 x 2732 | iPad Pro 12.9" (6th gen) | Yes |

> You can check "Use 6.7-inch screenshots for 6.5-inch" in App Store Connect to reduce work.

### Screenshot Sequence (10 slots, use 8)

Each screenshot should use **dark mode** with the Habitra brand background (#0D0D14), purple accent (#6C63FF), and clean white text overlays.

#### Screenshot 1 -- Hero: Today View
- **Tagline:** "Your habits. Your rhythm. Your day."
- **What to show:** Today tab with 4-5 habits (Meditate, Exercise, Read, Journal, Drink Water). Progress ring at ~70%. One habit with a streak badge showing "21". AI coaching banner visible at top.
- **Why first:** This is your conversion shot. Shows the core experience at a glance.

#### Screenshot 2 -- Streaks & Celebrations
- **Tagline:** "Every streak tells a story."
- **What to show:** 30-day milestone celebration with confetti. Calendar heatmap glowing green. Streak badge prominently showing "30".
- **Why:** Streaks are the #1 motivator. This creates emotional pull.

#### Screenshot 3 -- AI Coach
- **Tagline:** "AI that learns you, not the other way around."
- **What to show:** Coach tab with prediction cards (78% chance, At Risk badge), pattern insight ("You skip Fridays 80% of the time"), and mood check-in button.
- **Why:** Differentiator. No other privacy-first habit app has on-device AI predictions.

#### Screenshot 4 -- Stats & Analytics
- **Tagline:** "See your progress. Know your patterns."
- **What to show:** Stats tab with calendar heatmap, completion rate chart, day-of-week analysis, trend badge showing "Improving".
- **Why:** Data-driven users want to see analytics depth.

#### Screenshot 5 -- Mood Tracking
- **Tagline:** "How you feel shapes what you do."
- **What to show:** Mood check-in UI with 5 mood levels, mood trend sparkline over 30 days, journal entry with sentiment badge.
- **Why:** Unique feature. Mood-habit correlation is a strong differentiator.

#### Screenshot 6 -- Widgets & Lock Screen
- **Tagline:** "Streaks on your Lock Screen. Progress at a glance."
- **What to show:** Composite image: iPhone Lock Screen with Habitra streak widget + Home Screen with Habit Grid and Progress Bar widgets.
- **Why:** Widgets drive daily engagement. Seeing them on the Lock Screen is compelling.

#### Screenshot 7 -- Privacy & Security
- **Tagline:** "100% private. Zero cloud. All yours."
- **What to show:** Shield/lock visual with callouts: "No accounts", "No trackers", "No data collection", "On-device AI", "HealthKit read-only". Privacy policy link visible.
- **Why:** Privacy is the #1 brand differentiator. This screenshot alone converts privacy-conscious users.

#### Screenshot 8 -- HealthKit Integration
- **Tagline:** "Connect your health. Unlock hidden patterns."
- **What to show:** Health Dashboard with correlation cards ("Workout habit is 40% more likely with 7+ hrs sleep"), steps/sleep/HRV metric tiles.
- **Why:** Appeals to fitness and Apple Watch audience.

### Screenshot Design Specs

| Element | Specification |
|---------|-------------|
| **Background** | #0D0D14 (Habitra dark) or gradient from #0D0D14 to #1A1A2E |
| **Accent color** | #6C63FF (Habitra indigo) |
| **Tagline font** | SF Pro Display Bold, 72pt (iPhone), 96pt (iPad) |
| **Tagline color** | #FFFFFF |
| **Tagline position** | Top 20% of frame, centered |
| **Device frame** | Optional -- Apple allows frameless screenshots. If using frames, use official Apple device frames from developer.apple.com |
| **App screenshot** | Center-bottom, ~75% of frame height |
| **Safe zone** | Keep text 80px from edges (iPhone), 120px (iPad) |
| **Format** | PNG or JPEG, sRGB color space |

### How to Capture Screenshots

**Simulator method (recommended):**
1. Open Xcode > Product > Destination > select target device
2. Build and run (Cmd+R)
3. Populate the app with sample data (create 5 habits, complete some, build streaks)
4. Navigate to target screen
5. Cmd+S to save screenshot to Desktop
6. Repeat for each screen and device size

**Frame and annotate with:**
- Figma (free) -- best for teams
- RocketSim -- automates App Store screenshot framing directly in Xcode
- Screenshots Pro (Mac App Store) -- drag-and-drop framing
- Canva -- quick and easy with templates

### Sample Data to Populate Before Capturing

Create these habits for realistic screenshots:

| Habit | Icon | Color | Streak | Frequency |
|-------|------|-------|--------|-----------|
| Meditate | brain.head.profile | Purple | 21 days | Daily |
| Exercise | figure.run | Blue | 14 days | Weekdays |
| Read 30 min | book.fill | Cyan | 30 days | Daily |
| Journal | pencil.and.outline | Green | 7 days | Daily |
| Drink Water (8x) | drop.fill | Blue | 10 days | 8x daily |

Set mood entries for the past 30 days (mix of Good/Great with occasional Okay) for the mood trend screenshot.

---

## 3. CUSTOM PRODUCT PAGES

Apple allows up to **35 custom product pages** (CPPs). Each can have unique screenshots, promotional text, and app preview videos. They get unique URLs you can link to from specific ad campaigns or audiences.

### CPP 1: Fitness & Health Focus

**Target audience:** Apple Watch users, gym-goers, runners, fitness enthusiasts
**Ad channels:** Instagram fitness, Apple Search Ads (keywords: workout tracker, fitness habits, Apple Health)

| Field | Value |
|-------|-------|
| **Name** | Fitness & Health |
| **Promotional Text** | Your workouts auto-complete your habits. Connect Apple Health, track multiple workout types per habit, and see how sleep and steps affect your consistency. |

**Screenshot order (reorder from default set + swap taglines):**
1. HealthKit Integration -- "Your workouts. Auto-tracked."
2. Today View -- "Build fitness habits that stick."
3. AI Coach -- "AI predicts your workout consistency."
4. Stats -- "Track every rep, every step, every streak."
5. Widgets -- "Fitness streaks on your Lock Screen."
6. Streaks -- "30 days strong. Keep going."

### CPP 2: Productivity & Routine Focus

**Target audience:** GTD enthusiasts, morning routine builders, Notion/journaling crowd
**Ad channels:** Twitter/X productivity, Apple Search Ads (keywords: daily routine, habit stacking, productivity tracker)

| Field | Value |
|-------|-------|
| **Name** | Productivity & Routines |
| **Promotional Text** | Custom schedules, multi-completion tracking, and AI coaching -- built for your actual routine, not a perfect one. Weekday habits, 3x daily habits, whatever fits YOUR life. |

**Screenshot order:**
1. Today View -- "Your routine. Your rules."
2. Stats -- "See your patterns. Own your progress."
3. AI Coach -- "AI learns YOUR productivity patterns."
4. Mood Tracking -- "Track energy. Optimize your day."
5. Streaks -- "Consistency over perfection."
6. Widgets -- "Your habits, always visible."

### CPP 3: Privacy-First Focus

**Target audience:** Privacy advocates, users searching for "no account" or "offline" apps
**Ad channels:** Reddit privacy communities, Apple Search Ads (keywords: private habit tracker, offline tracker, no cloud)

| Field | Value |
|-------|-------|
| **Name** | Privacy First |
| **Promotional Text** | Zero accounts. Zero cloud. Zero data collection. Habitra runs 100% on your device with on-device AI. Your habits are nobody's business but yours. |

**Screenshot order:**
1. Privacy -- "100% private. Zero cloud. All yours."
2. Today View -- "Track habits without giving up your data."
3. AI Coach -- "On-device AI. No data leaves your phone."
4. Stats -- "Your analytics. Stored locally. Always."
5. Streaks -- "Your streaks. Your device. Your privacy."
6. Widgets -- "Private habits, visible only to you."

---

## 4. APP PREVIEW VIDEOS

Up to 3 app preview videos per product page. 15-30 seconds each. Must be screen recordings of the actual app.

### Video 1 -- "A Day with Habitra" (15 sec)

| Time | Screen | Text Overlay |
|------|--------|-------------|
| 0-2s | Lock Screen with streak widget | "Your habits start here." |
| 2-5s | Open app, Today tab with AI banner | "AI coaching, right when you need it." |
| 5-8s | Tap "Meditate" -- pulse animation, streak increments | "Every tap builds momentum." |
| 8-10s | Quick mood check-in (tap happy face) | "Track how you feel." |
| 10-13s | Progress ring fills to 100%, confetti burst | "100% complete. Every. Single. Day." |
| 13-15s | End card: Habitra logo + tagline | "Your habits. Your rhythm." |

**Resolution:** Match screenshot device size
**Audio:** App sounds only (no voiceover required, but recommended)

### Video 2 -- "AI That Gets You" (20 sec)

| Time | Screen | Text Overlay |
|------|--------|-------------|
| 0-3s | Coach tab overview | "Meet your AI habit coach." |
| 3-7s | Prediction card: "78% chance tomorrow" | "It predicts your streaks." |
| 7-10s | Pattern insight: "You skip Fridays" | "It learns your patterns." |
| 10-14s | Health correlation: "Sleep + workout" | "It connects the dots." |
| 14-17s | Weekly recap generating | "Weekly coaching. Zero cloud." |
| 17-20s | End card: "Intelligence on your device." | Habitra logo |

### Video 3 -- "From Zero to Streak" (20 sec)

| Time | Screen | Text Overlay |
|------|--------|-------------|
| 0-3s | Create habit "Read 20 min" | "Start with one habit." |
| 3-6s | Day 3: streak badge "3" | "Build momentum." |
| 6-9s | Day 7: milestone celebration | "Celebrate every milestone." |
| 9-12s | Day 21: Stats showing upward trend | "Watch yourself improve." |
| 12-15s | Day 30: share streak card | "Share your wins." |
| 15-18s | Heatmap fully green | "One month. All green." |
| 18-20s | End card | "Build habits that stick." |

---

## 5. APP REVIEW NOTES

Copy this into App Store Connect > App Review Information > Notes for Reviewer:

```
Thank you for reviewing Habitra!

KEY INFO
- No user accounts or sign-in required. All data is stored locally on-device using SwiftData.
- The app is a habit tracker with on-device AI coaching, mood tracking, HealthKit integration, and widgets.

HOW TO TEST

1. ONBOARDING
   - Launch the app. You'll see a 3-screen onboarding flow.
   - Complete onboarding to reach the main Today view.

2. CORE HABIT TRACKING
   - Tap the "+" button to create a habit.
   - Fill in a name (e.g., "Exercise"), pick an icon and color, set frequency.
   - Save the habit. It appears on the Today tab.
   - Tap the habit's circle to mark it complete. You'll see a pulse animation and streak increment.
   - Create 2-3 more habits to see the progress ring update.

3. STREAKS & MILESTONES
   - Streaks increment each consecutive day a habit is completed.
   - Milestone celebrations trigger at 7, 14, 21, 30, 50, 100, 200, and 365 days.
   - For review purposes, streaks will show "1" after first completion.

4. AI FEATURES (PRO)
   - The AI prediction engine requires ~7 days of habit data to train.
   - On first launch, the Coach tab shows general motivational messages.
   - After sufficient data, it generates predictions like "78% chance of completing Exercise tomorrow."
   - All AI processing uses Core ML on-device. No network calls.

5. MOOD TRACKING (PRO)
   - From the Coach tab, tap the mood check-in button.
   - Select a mood level (1-5) and optionally write a journal entry.
   - Mood trends appear after 3+ entries.

6. HEALTHKIT INTEGRATION (PRO)
   - Grant Health permissions when prompted in Settings > HealthKit.
   - The app reads: steps, sleep, heart rate, HRV, active energy, workouts.
   - Health correlations appear in the Coach tab after sufficient data.
   - All HealthKit data stays on-device. Read-only access.

7. WIDGETS
   - Long-press the Home Screen > tap "+" > search "Habitra".
   - Available widgets: Streak, Habit Grid, Progress Bar, Live Activity.
   - Widgets update when habits are completed.

8. IN-APP PURCHASES
   - Use a Sandbox account to test subscriptions.
   - Available tiers: Pro Monthly ($2.99), Pro Annual ($29.99 with 14-day trial), Pro Lifetime ($39.99).
   - Tip jar: Small ($1.99), Medium ($4.99), Large ($9.99).
   - Restore Purchases button is on the paywall screen and in Settings.

9. iCLOUD SYNC (PRO)
   - Optional. Disabled by default. Enable in Settings > Cloud Sync.
   - Uses CloudKit to sync habits and completions across devices signed into the same Apple ID.

PRIVACY NOTE
This app collects NO user data. No analytics SDKs, no crash reporting, no third-party tracking. The only network activity is Apple's StoreKit for subscription validation and optional CloudKit sync. All AI processing uses Core ML on-device.

PLATFORMS
- iPhone (primary)
- iPad (supported)
- Apple Vision Pro (supported)

Thank you for your time!
```

---

## 6. PRODUCT PAGE OPTIMIZATION (PPO) TESTS

After launch, use App Store Connect's built-in A/B testing to optimize conversion. You can test up to 3 treatments against the default.

### Test 1: Hero Screenshot

**Hypothesis:** Leading with the streak celebration screenshot will convert better than the Today view because it creates emotional aspiration.

| Variant | Screenshot 1 |
|---------|-------------|
| Control (Default) | Today View -- "Your habits. Your rhythm. Your day." |
| Treatment A | Streak Celebration -- "Every streak tells a story." |
| Treatment B | AI Coach -- "AI that learns you, not the other way around." |

**Run for:** 7 days minimum, or until 90% confidence

### Test 2: Tagline Style

**Hypothesis:** Benefit-focused taglines ("Build habits that stick") convert better than feature-focused ones ("AI-powered habit tracking").

| Variant | Screenshot 1 Tagline |
|---------|---------------------|
| Control | "Your habits. Your rhythm. Your day." |
| Treatment A | "Build habits that actually stick." |
| Treatment B | "The last habit app you'll ever need." |

### Test 3: Privacy Emphasis

**Hypothesis:** Leading with privacy messaging converts better in Health & Fitness category where data concerns are high.

| Variant | Screenshot 1 |
|---------|-------------|
| Control | Today View (default) |
| Treatment A | Privacy screenshot first -- "100% private. Zero cloud." |

---

## 7. DEVICE MATRIX

### Screenshot Capture Checklist

| Device | Size | Simulator | Captured? |
|--------|------|-----------|-----------|
| iPhone 16 Pro Max | 6.9" (1320x2868) | iPhone 16 Pro Max | [ ] |
| iPhone 15 Pro Max | 6.7" (1290x2796) | iPhone 15 Pro Max | [ ] |
| iPhone 11 Pro Max | 6.5" (1242x2688) | Use 6.7" fallback | [ ] |
| iPad Pro 13" M4 | 13" (2064x2752) | iPad Pro 13-inch (M4) | [ ] |
| iPad Pro 12.9" | 12.9" (2048x2732) | iPad Pro 12.9-inch (6th) | [ ] |

### Per-Screenshot Capture Matrix

| Screenshot | iPhone 6.9" | iPhone 6.7" | iPad 13" | iPad 12.9" |
|-----------|------------|------------|---------|-----------|
| 1. Today View | [ ] | [ ] | [ ] | [ ] |
| 2. Streaks | [ ] | [ ] | [ ] | [ ] |
| 3. AI Coach | [ ] | [ ] | [ ] | [ ] |
| 4. Stats | [ ] | [ ] | [ ] | [ ] |
| 5. Mood | [ ] | [ ] | [ ] | [ ] |
| 6. Widgets | [ ] | [ ] | [ ] | [ ] |
| 7. Privacy | [ ] | [ ] | [ ] | [ ] |
| 8. HealthKit | [ ] | [ ] | [ ] | [ ] |

**Total screenshots needed:** 8 screens x 4 device sizes = 32 images (reduced to 24 if using 6.7" fallback for 6.5")

---

## 8. PRODUCTION CHECKLIST

### Before Submission

- [ ] All 8 default screenshots captured for iPhone 6.9" and 6.7"
- [ ] All 8 default screenshots captured for iPad 13" and 12.9"
- [ ] Screenshots framed with taglines using consistent design template
- [ ] App preview video recorded (at least Video 1: "A Day with Habitra")
- [ ] Custom product page 1 (Fitness) created with reordered screenshots
- [ ] Custom product page 2 (Productivity) created with reordered screenshots
- [ ] Custom product page 3 (Privacy) created with reordered screenshots
- [ ] App Review notes pasted into App Store Connect
- [ ] Promotional text entered (can be updated post-launch without new build)
- [ ] Description entered
- [ ] Keywords entered (verify 100-char limit)
- [ ] What's New text entered
- [ ] Privacy Policy URL live and accessible
- [ ] Support URL live and accessible

### After Launch (Week 1)

- [ ] Verify listing displays correctly on App Store
- [ ] Test all custom product page URLs
- [ ] Set up PPO Test 1 (Hero Screenshot)
- [ ] Monitor App Store Connect Analytics for impressions/conversion
- [ ] Respond to first reviews within 24 hours
- [ ] Share custom product page URLs in targeted ad campaigns

### Ongoing Optimization

- [ ] Review PPO test results weekly
- [ ] Update promotional text based on seasonal events or new features
- [ ] Refresh screenshots with each major feature update
- [ ] Add localized product pages for top markets (after analyzing geographic download data)
- [ ] Create new custom product pages for emerging audience segments

---

## APPENDIX: CUSTOM PRODUCT PAGE URLs

After creating CPPs in App Store Connect, you'll receive unique URLs like:

```
Default:     https://apps.apple.com/app/habitra-ai-habit-tracker/id[APP_ID]
Fitness:     https://apps.apple.com/app/habitra-ai-habit-tracker/id[APP_ID]?ppid=fitness
Productivity: https://apps.apple.com/app/habitra-ai-habit-tracker/id[APP_ID]?ppid=productivity
Privacy:     https://apps.apple.com/app/habitra-ai-habit-tracker/id[APP_ID]?ppid=privacy
```

Use these in:
- Apple Search Ads campaigns (match CPP to ad group keywords)
- Social media ads (link fitness CPP from fitness-focused posts)
- Email campaigns (segment by audience interest)
- QR codes at events or in print materials
