# Habitra -- App Store Product Page (Free v1.0 Launch)

This is the free-only v1.0 product page strategy. The original Pro version is preserved at `app-store-product-page.md`. See `docs/RELEASE_STRATEGY.md` for the full free-vs-Pro breakdown and re-enable checklist.

**Key constraint:** "Coming Soon" is allowed in-app but NOT in App Store screenshots or metadata (Apple Guideline 2.3.8). The roadmap lives on the website and in the in-app Support view only.

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
| **Name** | Habitra - Habit Tracker |
| **Subtitle** | Build streaks. Track progress. Stay private. |
| **Category** | Health & Fitness |
| **Secondary Category** | Productivity |
| **Promotional Text** | Build habits that actually stick -- with streaks, smart reminders, and stats you can see at a glance. 100% free. 100% private. No accounts. No cloud. |
| **Keywords** | habit,streak,routine,wellness,productivity,private,offline,tracker,widget,reminder |

> **Keyword notes:** 100-char limit (this set is 80 chars). Removed `AI`, `coach`, `HealthKit`, `mood` since those features are hidden in v1.0. Added `widget`, `reminder` to fill space. Don't repeat words from the app name.

### Description

```
Build habits that actually stick.

Habitra is a free habit tracker built for people who want to build real habits -- without ads, accounts, or data collection. Everything runs on your device. Nothing leaves your phone.

TRACK YOUR WAY
- Track up to 5 habits with custom icons, colors, and schedules
- Set daily, weekday, weekend, or custom day frequencies
- Multi-completion habits: track "Drink Water 8x" or "Take Meds 3x" in a single habit
- Quick Add Templates: choose from 16 pre-built habits across Health, Mindfulness, Productivity, and Self-Care

BUILD STREAKS THAT MATTER
- Watch your streak count grow day by day
- Celebrate milestones at 7, 14, 21, 30, 50, 100, and 365 days with confetti animations
- Earn XP, level up, and collect milestone badges
- Share streak cards with custom gradient themes

SEE YOUR PROGRESS
- Calendar heatmap shows your consistency over time
- Completion rate charts and trend analysis
- Day-of-week breakdown reveals your strongest and weakest days
- Track your stats over 7 days, 30 days, 90 days, or all time

SMART REMINDERS
- Set custom reminder times for each habit
- Multi-completion habits get spaced interval reminders throughout the day
- Start a 10-minute Live Activity timer from any habit
- All notifications are local -- no internet required

WIDGETS
- Lock Screen streak widget shows your top streak at a glance
- Widgets update automatically when you complete habits

PRIVACY IS SACRED
- No accounts. No sign-up. No email required.
- No analytics, no crash reporting, no third-party SDKs
- All data stored locally using Apple's SwiftData framework
- The only network activity is Apple's StoreKit for optional tip purchases
- We literally cannot see your data. That's the point.

SUPPORT INDIE DEVELOPMENT
- Habitra is 100% free. No ads. No paywalls. No strings attached.
- If Habitra helps you, you can leave an optional tip ($1.99, $4.99, or $9.99) to support development.

Built by one developer who believes habit tracking should be private, beautiful, and free.
```

### What's New (v1.0)

```
Build habits that actually stick -- privately and beautifully.

- Track up to 5 habits with custom icons, colors, and schedules
- Streak tracking with milestone celebrations at 7, 14, 21, 30, 50, 100, and 365 days
- XP system with levels and collectible badges
- Smart reminders with interval spacing for multi-completion habits
- Lock Screen streak widget
- Calendar heatmap, trends, and day-of-week analysis
- Live Activity timer for focused habit sessions
- Share streak cards with gradient themes
- 100% private: no accounts, no cloud, no tracking
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

### Screenshot Sequence (8 Slots -- Free Features Only)

Each screenshot uses **dark mode** with Habitra brand background (#0D0D14), purple accent (#6C63FF), and clean white text overlays.

**IMPORTANT:** No "Coming Soon" or roadmap features in screenshots (Guideline 2.3.8).

#### Screenshot 1 -- Hero: Today View
- **Tagline:** "Your habits. Your rhythm. Your day."
- **What to show:** Today tab with 5 habits (Meditate, Exercise, Read, Journal, Drink Water). Progress ring at ~70%. Streak badges visible (21, 14, 30 days). Clean view without AI coaching banner.
- **Why first:** Conversion shot. Shows the core experience at a glance. The 5-habit display intentionally shows a full, satisfying free experience.

#### Screenshot 2 -- Streaks & Celebrations
- **Tagline:** "Every streak is a story of discipline."
- **What to show:** 30-day milestone celebration with confetti. Calendar heatmap glowing green. Streak badge prominently showing "30".
- **Why:** Streaks are the #1 motivator. Creates emotional aspiration.

#### Screenshot 3 -- XP, Levels & Badges
- **Tagline:** "Level up your life. One habit at a time."
- **What to show:** XP popup after completing a habit (+25 XP), level progress bar (Level 5), badge shelf showing earned milestone badges (7-day, 14-day, 30-day, Early Riser, etc.). Show the gamification layer.
- **Why:** Gamification is a strong hook for App Store browsers. Differentiates from basic habit trackers.

#### Screenshot 4 -- Stats & Progress
- **Tagline:** "See your progress. Know your patterns."
- **What to show:** Stats tab with calendar heatmap, completion rate chart, day-of-week analysis, trend badge showing "Improving". Remove AI Health Score grades (not available in free tier).
- **Why:** Data-driven users want analytics depth. The heatmap is visually striking.

#### Screenshot 5 -- Smart Reminders & Scheduling
- **Tagline:** "Never forget. Always on time."
- **What to show:** Habit creation/edit form with reminder toggle on, time picker visible. Below: Lock Screen notification preview. Frequency options visible (Daily, Weekdays, Custom).
- **Why:** Reminders are a core differentiator for daily habit tracking. Shows the app is practical, not just pretty.

#### Screenshot 6 -- Lock Screen Widget
- **Tagline:** "Your streaks. Right on your Lock Screen."
- **What to show:** iPhone Lock Screen with Habitra streak widget prominently displayed. Clean single-focus composition. Show the circular and rectangular Lock Screen widget variants.
- **Why:** Widgets drive daily engagement. Lock Screen visibility is compelling and free.

#### Screenshot 7 -- Privacy & Security
- **Tagline:** "100% private. Zero cloud. All yours."
- **What to show:** Shield/lock visual with callouts: "No accounts", "No trackers", "No data collection", "100% on-device", "No cloud storage". Privacy policy link visible.
- **Why:** Privacy is the #1 brand differentiator. This screenshot alone converts privacy-conscious users.

#### Screenshot 8 -- Streak Themes & Sharing
- **Tagline:** "Share your wins. Inspire your people."
- **What to show:** Streak share card with the Midnight gradient theme, social share sheet visible. Show the streak card with habit name, streak count, and gradient background.
- **Why:** Social sharing creates organic virality. Shows the app has polish and personality.

### Screenshot Design Specs

| Element | Specification |
|---------|-------------|
| **Background** | #0D0D14 (Habitra dark) or gradient from #0D0D14 to #1A1A2E |
| **Accent color** | #6C63FF (Habitra indigo) |
| **Tagline font** | SF Pro Display Bold, 72pt (iPhone), 96pt (iPad) |
| **Tagline color** | #FFFFFF |
| **Tagline position** | Top 20% of frame, centered |
| **Device frame** | Optional -- Apple allows frameless screenshots |
| **App screenshot** | Center-bottom, ~75% of frame height |
| **Safe zone** | Keep text 80px from edges (iPhone), 120px (iPad) |
| **Format** | PNG or JPEG, sRGB color space |

### Sample Data to Populate Before Capturing

| Habit | Icon | Color | Streak | Frequency |
|-------|------|-------|--------|-----------|
| Meditate | brain.head.profile | Purple | 21 days | Daily |
| Exercise | figure.run | Blue | 14 days | Weekdays |
| Read 30 min | book.fill | Cyan | 30 days | Daily |
| Journal | pencil.and.outline | Green | 7 days | Daily |
| Drink Water (8x) | drop.fill | Blue | 10 days | 8x daily |

> This is 5 habits -- the free maximum. Screenshots should show a full, realistic free experience.

---

## 3. CUSTOM PRODUCT PAGES

### CPP 1: Fitness & Wellness Focus

**Target audience:** Gym-goers, runners, fitness enthusiasts
**Ad channels:** Instagram fitness, Apple Search Ads (keywords: workout tracker, fitness habits, daily exercise)

| Field | Value |
|-------|-------|
| **Name** | Fitness & Wellness |
| **Promotional Text** | Build workout habits that stick. Track your exercise streak, set smart reminders, and see your consistency over time. 100% free. 100% private. |

**Screenshot order:**
1. Today View -- "Build fitness habits that stick."
2. Streaks -- "30 days strong. Keep going."
3. Stats -- "Track every workout. See every pattern."
4. Reminders -- "Never miss leg day again."
5. Lock Screen Widget -- "Fitness streaks at a glance."
6. Privacy -- "Your fitness data stays with you."

### CPP 2: Productivity & Routine Focus

**Target audience:** GTD enthusiasts, morning routine builders, productivity crowd
**Ad channels:** Twitter/X productivity, Apple Search Ads (keywords: daily routine, habit stacking, productivity tracker)

| Field | Value |
|-------|-------|
| **Name** | Productivity & Routines |
| **Promotional Text** | Custom schedules, multi-completion tracking, and streak milestones -- built for your actual routine, not a perfect one. Free forever. |

**Screenshot order:**
1. Today View -- "Your routine. Your rules."
2. Stats -- "See your patterns. Own your progress."
3. XP & Badges -- "Level up your productivity."
4. Reminders -- "Perfectly timed nudges."
5. Streaks -- "Consistency over perfection."
6. Lock Screen Widget -- "Your habits, always visible."

### CPP 3: Privacy-First Focus

**Target audience:** Privacy advocates, users searching for "no account" or "offline" apps
**Ad channels:** Reddit privacy communities, Apple Search Ads (keywords: private habit tracker, offline tracker, no cloud)

| Field | Value |
|-------|-------|
| **Name** | Privacy First |
| **Promotional Text** | Zero accounts. Zero cloud. Zero data collection. Habitra stores everything on your device. Your habits are nobody's business but yours. Free forever. |

**Screenshot order:**
1. Privacy -- "100% private. Zero cloud. All yours."
2. Today View -- "Track habits without giving up your data."
3. Stats -- "Your analytics. Stored locally. Always."
4. Streaks -- "Your streaks. Your device. Your privacy."
5. Reminders -- "Local reminders. No server required."
6. Lock Screen Widget -- "Private habits, visible only to you."

---

## 4. APP PREVIEW VIDEOS

### Video 1 -- "A Day with Habitra" (15 sec)

| Time | Screen | Text Overlay |
|------|--------|-------------|
| 0-2s | Lock Screen with streak widget | "Your habits start here." |
| 2-5s | Open app, Today tab (clean, no AI banner) | "Simple. Beautiful. Private." |
| 5-8s | Tap "Meditate" -- pulse animation, streak increments | "Every tap builds momentum." |
| 8-10s | Progress ring fills to 100%, confetti burst | "100% complete. Celebrate it." |
| 10-13s | XP popup, badge earned animation | "Level up. Earn badges." |
| 13-15s | End card: Habitra logo + tagline | "Your habits. Your rhythm." |

### Video 2 -- "From Zero to Streak" (20 sec)

| Time | Screen | Text Overlay |
|------|--------|-------------|
| 0-3s | Create habit "Read 20 min" from template | "Start with one habit." |
| 3-6s | Day 3: streak badge "3" | "Build momentum." |
| 6-9s | Day 7: milestone celebration with confetti | "Celebrate every milestone." |
| 9-12s | Day 21: Stats showing upward trend | "Watch yourself improve." |
| 12-15s | Day 30: share streak card with gradient | "Share your wins." |
| 15-18s | Heatmap fully green | "One month. All green." |
| 18-20s | End card | "Build habits that stick. Free." |

> **Removed from Pro version:** Video 2 "AI That Gets You" is removed entirely (AI Coach is hidden in v1.0).

---

## 5. APP REVIEW NOTES

Copy this into App Store Connect > App Review Information > Notes for Reviewer:

```
Thank you for reviewing Habitra!

KEY INFO
- No user accounts or sign-in required. All data is stored locally on-device using SwiftData.
- Habitra is a free habit tracker with streaks, XP/badges, stats, widgets, and a Tip Jar.
- There is no subscription paywall. All features in this build are free.

HOW TO TEST

1. ONBOARDING
   - Launch the app. You'll see a quick-tour onboarding flow.
   - Complete onboarding to reach the main Today view.

2. CORE HABIT TRACKING
   - Tap the "+" button to create a habit.
   - Fill in a name (e.g., "Exercise"), pick an icon and color, set frequency.
   - Save the habit. It appears on the Today tab.
   - Tap the habit's circle to mark it complete. You'll see a pulse animation and streak increment.
   - Create 2-3 more habits to see the progress ring update.
   - You can also use "Quick Add Template" to create from 16 pre-built habits.

3. HABIT LIMIT
   - Free users can track up to 5 habits. Attempting to create a 6th shows an informational alert.
   - This is a design choice, not a broken paywall -- there is no upgrade path in this version.

4. STREAKS & MILESTONES
   - Streaks increment each consecutive day a habit is completed.
   - Milestone celebrations trigger at 7, 14, 21, 30, 50, 100, 200, and 365 days.
   - For review purposes, streaks will show "1" after first completion.

5. XP & BADGES
   - Completing habits earns XP. XP drives level-ups.
   - Badges are earned for streak milestones and special achievements.
   - The badge shelf is accessible from the Stats tab.

6. STATS & ANALYTICS
   - The Stats tab shows completion rates, calendar heatmaps, trends, and day-of-week analysis.
   - Use the time range picker (7D, 30D, 90D, All) to adjust the view.

7. WIDGETS
   - Long-press the Home Screen > tap "+" > search "Habitra".
   - The Lock Screen streak widget shows your top streak.
   - Widgets update when habits are completed.

8. IN-APP PURCHASES (TIP JAR ONLY)
   - There are NO subscriptions in this version.
   - The Tip Jar offers three one-time consumable purchases:
     - Small Tip: $1.99
     - Medium Tip: $4.99
     - Large Tip: $9.99
   - Tips do not unlock any features. They are purely optional support.
   - The Tip Jar is accessible from Settings > Support & Roadmap.

9. IN-APP ROADMAP
   - The Support & Roadmap section in Settings shows a "Coming Soon" list.
   - These are planned features, not broken or gated features.
   - No purchase is required or possible for these items.

PRIVACY NOTE
This app collects NO user data. No analytics SDKs, no crash reporting, no third-party tracking. The only network activity is Apple's StoreKit for optional tip purchases. All data is stored locally on-device.

PLATFORMS
- iPhone (primary)
- iPad (supported)

Thank you for your time!
```

---

## 6. PRODUCT PAGE OPTIMIZATION (PPO) TESTS

### Test 1: Hero Screenshot

**Hypothesis:** Leading with the streak celebration screenshot will convert better than the Today view because it creates emotional aspiration.

| Variant | Screenshot 1 |
|---------|-------------|
| Control (Default) | Today View -- "Your habits. Your rhythm. Your day." |
| Treatment A | Streak Celebration -- "Every streak is a story of discipline." |
| Treatment B | XP & Badges -- "Level up your life. One habit at a time." |

**Run for:** 7 days minimum, or until 90% confidence

### Test 2: Tagline Style

**Hypothesis:** Benefit-focused taglines convert better than feature-focused ones for a free app.

| Variant | Screenshot 1 Tagline |
|---------|---------------------|
| Control | "Your habits. Your rhythm. Your day." |
| Treatment A | "Build habits that actually stick." |
| Treatment B | "The free habit tracker that respects your privacy." |

### Test 3: Privacy Emphasis

**Hypothesis:** Leading with privacy messaging converts better in Health & Fitness category where data concerns are high.

| Variant | Screenshot 1 |
|---------|-------------|
| Control | Today View (default) |
| Treatment A | Privacy screenshot first -- "100% private. Zero cloud." |

---

## 7. DEVICE MATRIX

### Per-Screenshot Capture Matrix

| Screenshot | iPhone 6.9" | iPhone 6.7" | iPad 13" | iPad 12.9" |
|-----------|------------|------------|---------|-----------|
| 1. Today View | [ ] | [ ] | [ ] | [ ] |
| 2. Streaks & Celebration | [ ] | [ ] | [ ] | [ ] |
| 3. XP, Levels & Badges | [ ] | [ ] | [ ] | [ ] |
| 4. Stats & Progress | [ ] | [ ] | [ ] | [ ] |
| 5. Reminders & Scheduling | [ ] | [ ] | [ ] | [ ] |
| 6. Lock Screen Widget | [ ] | [ ] | [ ] | [ ] |
| 7. Privacy & Security | [ ] | [ ] | [ ] | [ ] |
| 8. Streak Themes & Sharing | [ ] | [ ] | [ ] | [ ] |

**Total screenshots needed:** 8 screens x 4 device sizes = 32 images (reduced to 24 if using 6.7" fallback for 6.5")

---

## 8. PRODUCTION CHECKLIST

### Before Submission

- [ ] All 8 default screenshots captured for iPhone 6.9" and 6.7"
- [ ] All 8 default screenshots captured for iPad 13" and 12.9"
- [ ] Screenshots framed with taglines using consistent design template
- [ ] App preview video recorded (Video 1: "A Day with Habitra")
- [ ] Custom product page 1 (Fitness) created with reordered screenshots
- [ ] Custom product page 2 (Productivity) created with reordered screenshots
- [ ] Custom product page 3 (Privacy) created with reordered screenshots
- [ ] App Review notes pasted into App Store Connect
- [ ] Promotional text entered
- [ ] Description entered (NO Pro/AI/HealthKit/iCloud/Mood mentions)
- [ ] Keywords entered (verify 100-char limit, NO AI/coach/HealthKit/mood keywords)
- [ ] What's New text entered
- [ ] Privacy Policy URL live and accessible
- [ ] Support URL live and accessible
- [ ] Subscription products marked "Removed from Sale" in App Store Connect
- [ ] Tip Jar products active in App Store Connect
- [ ] Verify NO "Coming Soon" language in any App Store metadata field

### After Launch (Week 1)

- [ ] Verify listing displays correctly on App Store
- [ ] Test all custom product page URLs
- [ ] Set up PPO Test 1 (Hero Screenshot)
- [ ] Monitor App Store Connect Analytics for impressions/conversion
- [ ] Respond to first reviews within 24 hours
- [ ] Share custom product page URLs in targeted ad campaigns

### Ongoing Optimization

- [ ] Review PPO test results weekly
- [ ] Update promotional text for seasonal events (no new build needed)
- [ ] Refresh screenshots with each major feature update
- [ ] When Pro tier returns: create new screenshots for Pro features, update all metadata, restore subscription products

---

## APPENDIX: CUSTOM PRODUCT PAGE URLs

After creating CPPs in App Store Connect:

```
Default:       https://apps.apple.com/app/habitra-habit-tracker/id[APP_ID]
Fitness:       https://apps.apple.com/app/habitra-habit-tracker/id[APP_ID]?ppid=fitness
Productivity:  https://apps.apple.com/app/habitra-habit-tracker/id[APP_ID]?ppid=productivity
Privacy:       https://apps.apple.com/app/habitra-habit-tracker/id[APP_ID]?ppid=privacy
```

## APPENDIX: CHANGES FROM PRO VERSION

| Section | Pro Version | Free v1.0 |
|---------|------------|-----------|
| Name | Habitra - AI Habit Tracker | Habitra - Habit Tracker |
| Keywords | includes AI, coach, HealthKit, mood | replaced with widget, reminder |
| Screenshots 3, 5, 8 | AI Coach, Mood Tracking, HealthKit | XP/Badges, Reminders, Streak Sharing |
| CPP promotional text | references AI, HealthKit, mood | references streaks, reminders, privacy |
| Videos | 3 videos (one AI-focused) | 2 videos (removed AI video) |
| App Review notes | sections for AI, Mood, HealthKit, iCloud | removed; added sections for Habit Limit, XP, Tip Jar |
| PPO tests | Treatment B = AI Coach | Treatment B = XP & Badges |
