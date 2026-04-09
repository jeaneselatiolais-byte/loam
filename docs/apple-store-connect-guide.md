# Habitra -- Apple App Store Connect Submission Guide

A step-by-step guide to adding Habitra to App Store Connect, including screenshots, metadata, and review preparation.

---

## TABLE OF CONTENTS

1. [Prerequisites](#1-prerequisites)
2. [Create the App in App Store Connect](#2-create-the-app-in-app-store-connect)
3. [App Information](#3-app-information)
4. [Pricing and Availability](#4-pricing-and-availability)
5. [In-App Purchases & Subscriptions](#5-in-app-purchases--subscriptions)
6. [Prepare Screenshots](#6-prepare-screenshots)
7. [App Store Listing Metadata](#7-app-store-listing-metadata)
8. [App Privacy Details](#8-app-privacy-details)
9. [Build & Upload](#9-build--upload)
10. [App Review Preparation](#10-app-review-preparation)
11. [Submit for Review](#11-submit-for-review)
12. [Post-Submission](#12-post-submission)

---

## 1. PREREQUISITES

Before you start, make sure you have:

- [ ] **Apple Developer Account** ($99/year) -- enrolled and active at [developer.apple.com](https://developer.apple.com)
- [ ] **App Store Connect access** -- sign in at [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- [ ] **Bundle ID registered** -- `com.jeanese.habitra` in Certificates, Identifiers & Profiles
- [ ] **Provisioning profile** -- Distribution profile created for the bundle ID
- [ ] **App icon** -- 1024x1024 PNG (no alpha/transparency) -- you have this at `Assets.xcassets/AppIcon.appiconset/AppIcon_1024.png`
- [ ] **Xcode** -- Latest version with your signing certificates configured
- [ ] **Screenshots** -- Prepared for required device sizes (see Section 6)

---

## 2. CREATE THE APP IN APP STORE CONNECT

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Click **"My Apps"**
3. Click the **"+"** button → **"New App"**
4. Fill in:

| Field | Value |
|-------|-------|
| **Platforms** | iOS |
| **Name** | Habitra - AI Habit Tracker |
| **Primary Language** | English (U.S.) |
| **Bundle ID** | com.jeanese.habitra |
| **SKU** | habitra-habit-tracker (any unique string) |
| **User Access** | Full Access |

5. Click **"Create"**

> **Note:** The app name must be unique on the App Store and ≤30 characters. "Habitra - AI Habit Tracker" is 26 characters.

---

## 3. APP INFORMATION

Navigate to **App Store → App Information** in the sidebar.

### General Information

| Field | Value |
|-------|-------|
| **Name** | Habitra - AI Habit Tracker |
| **Subtitle** | Build habits that actually stick |
| **Category (Primary)** | Health & Fitness |
| **Category (Secondary)** | Productivity |
| **Content Rights** | Does not contain third-party content |
| **Age Rating** | 4+ (no objectionable content) |

### Age Rating Questionnaire
Answer **"None"** or **"No"** to all categories:
- Cartoon/Fantasy Violence: None
- Realistic Violence: None
- Sexual Content: None
- Profanity: None
- Drugs/Alcohol/Tobacco: None
- Gambling: No
- Horror/Fear: None
- Medical/Treatment: No
- Contests: No
- Unrestricted Web Access: No

Result should be: **Rated 4+**

---

## 4. PRICING AND AVAILABILITY

Navigate to **App Store → Pricing and Availability**.

| Field | Value |
|-------|-------|
| **Price** | Free |
| **Availability** | Available in all territories (or select specific countries) |
| **Pre-Order** | Optional -- enable if you want pre-orders before launch |

---

## 5. IN-APP PURCHASES & SUBSCRIPTIONS

Navigate to **Features → In-App Purchases** (for non-consumables/consumables) and **Features → Subscriptions** (for auto-renewable).

### Step 5a: Create Subscription Group

1. Go to **Subscriptions** → Click **"+"** to create a group
2. **Subscription Group Name:** "Habitra Pro"
3. **Reference Name:** habitra_pro_group

### Step 5b: Add Auto-Renewable Subscriptions

For each subscription, click **"+"** under the group:

#### Monthly Subscription
| Field | Value |
|-------|-------|
| **Reference Name** | Pro Monthly Rate|
| **Product ID** | `com.jeanese.habitra.pro.monthlyrate` |
| **Subscription Duration** | 1 Month |
| **Price** | $4.99 (Tier -- select the tier closest to $2.99) |
| **Display Name** | Habitra Pro Monthly |
| **Description** | Unlimited habits, AI coaching, mood tracking, HealthKit integration, iCloud sync, all widgets, CSV export, and all streak card themes. |
| **Family Sharing** | Yes |

#### Annual Subscription
| Field | Value |
|-------|-------|
| **Reference Name** | Pro Annual |
| **Product ID** | `com.jeanese.habitra.pro.annual` |
| **Subscription Duration** | 1 Year |
| **Price** | $29.99 |
| **Free Trial** | 2 Weeks |
| **Display Name** | Habitra Pro Annual |
| **Description** | All Pro features for a full year. Save 16% vs monthly. Includes 2-week free trial. |
| **Family Sharing** | Yes |
| **Promotional Offer** | Optional -- set up later |

### Step 5c: Add Non-Consumable (Lifetime)

Go to **In-App Purchases** → Click **"+"**:

| Field | Value |
|-------|-------|
| **Type** | Non-Consumable |
| **Reference Name** | Pro Lifetime |
| **Product ID** | `com.jeanese.habitra.pro.lifetime` |
| **Price** | $39.99 |
| **Display Name** | Habitra Pro Lifetime |
| **Description** | One-time purchase. All Pro features forever. No recurring charges. |
| **Family Sharing** | Yes |

### Step 5d: Add Consumables (Tip Jar)

For each tip, create a **Consumable** IAP:

| Reference Name | Product ID | Price | Display Name | Description |
|---------------|-----------|-------|-------------|-------------|
| Small Tip | `com.jeanese.habitra.tip.small` | $1.99 | Small Tip | Buy the developer a coffee |
| Medium Tip | `com.jeanese.habitra.tip.medium` | $4.99 | Medium Tip | Buy the developer lunch |
| Large Tip | `com.jeanese.habitra.tip.large` | $9.99 | Large Tip | Go big -- support indie development |

### Step 5e: Screenshot for Each IAP

Each IAP requires **at least one screenshot** for review. This should show the IAP as it appears in your app (the paywall/purchase screen). Take a simulator screenshot of your subscription view.

### Step 5f: Review Information for IAP

For each IAP, Apple may ask for a **Review Note**. Example:
> "This unlocks Habitra Pro features including unlimited habits, AI coaching, mood tracking, HealthKit integration, iCloud sync, all widgets, CSV export, and all streak card themes."

---

## 6. PREPARE SCREENSHOTS

### Required Sizes

You need screenshots for **at minimum** these device sizes:

| Device | Size (pixels) | Required? |
|--------|--------------|-----------|
| **iPhone 6.9" Display** (iPhone 16 Pro Max) | 1320 x 2868 | Yes (if supporting latest) |
| **iPhone 6.7" Display** (iPhone 14 Pro Max / 15 Pro Max) | 1290 x 2796 | Yes |
| **iPhone 6.5" Display** (iPhone 11 Pro Max / XS Max) | 1242 x 2688 | Yes |
| **iPhone 5.5" Display** (iPhone 8 Plus) | 1242 x 2208 | Yes (if supporting older devices) |
| **iPad Pro 12.9" (6th gen)** | 2048 x 2732 | Only if you support iPad |

> **Tip:** You can upload the 6.7" screenshots and check "Use 6.7" Display screenshots for 6.5" Display" to avoid creating both sizes.

### How to Take Screenshots

**Option A: Xcode Simulator**
1. Open Xcode → Product → Destination → Choose device (e.g., iPhone 15 Pro Max)
2. Build and run (Cmd+R)
3. Navigate to the screen you want
4. Press **Cmd+S** to save screenshot (saves to Desktop)
5. Repeat for each screen and device size

**Option B: Physical Device**
1. Run the app on your device
2. Press **Side Button + Volume Up** simultaneously
3. Transfer screenshots to Mac via AirDrop or Photos
4. Verify they match required dimensions

### Recommended Screenshots (in order)

You can upload **up to 10 screenshots**. Here are the recommended 6-8:

| # | Screen | Caption Text Overlay |
|---|--------|---------------------|
| 1 | **Today View** (with habits, streak counts, AI coaching message visible) | "Build habits that actually stick" |
| 2 | **AI Prediction Card** (showing risk levels: On Track / Needs Attention / At Risk) | "AI predicts when you'll break your streak" |
| 3 | **Mood Check-in** (mood selection with journal entry) | "Track your mood. Find the patterns." |
| 4 | **Stats/Analytics** (calendar heatmap + completion charts) | "See your progress at a glance" |
| 5 | **Weekly Recap** (AI-generated weekly summary) | "Weekly AI coaching, 100% on-device" |
| 6 | **Widgets** (home screen with Habitra widgets) | "Habits on your home screen" |
| 7 | **Health Dashboard** (HealthKit correlation data) | "See how sleep and steps affect your habits" |
| 8 | **Streak Celebration** (milestone celebration screen) | "Celebrate every milestone" |

### Screenshot Design Tips

- Add **text captions** above or below the device frame for context
- Use **Habitra purple (#6C63FF)** as the background color
- Use a tool like **Figma**, **Canva**, or **Screenshots Pro** to add frames and text
- Keep text **large and readable** -- people browse quickly
- Show **real-looking data** (not empty states)
- Populate habits with relatable examples: "Meditate", "Exercise", "Read", "Journal", "Drink Water"
- Use dark mode screenshots (your default theme looks better)

### App Preview Video (Optional but Recommended)

- Up to **30 seconds**, showing app in use
- Must be screen recording of actual app (no external footage)
- Size: same as screenshot dimensions
- Record with **Cmd+R** in simulator, then use QuickTime or screen recording
- Show: creating a habit → completing it → seeing streak → AI prediction → weekly recap

---

## 7. APP STORE LISTING METADATA

Navigate to **App Store → [Version] → App Store Listing**.

### Promotional Text (170 chars, can be updated without new version)
```
AI-powered habit tracking that learns your patterns. Predict your streaks, not your privacy. 100% on-device. No accounts. No data collection.
```

### Description (4000 chars max)
```
Build habits that actually stick — with AI that understands YOUR patterns, not your data.

Habitra is the intelligent habit tracker powered by on-device AI that predicts when you're at risk of breaking a streak and coaches you toward lasting change. Everything happens locally. No cloud. No accounts. No data collection. Just habits that work.

SMART HABIT TRACKING
• Create habits with custom icons, colors, and descriptions
• Flexible scheduling: daily, weekdays, weekends, or custom patterns
• Satisfying tap-to-complete with haptic feedback
• Persistent streaks with milestone celebrations (7, 14, 21, 30, 50, 100, 200, 365 days)
• Visual progress indicators and completion history

AI-POWERED INSIGHTS (PRO)
• On-device machine learning learns YOUR personal patterns
• Daily predictions: will you complete your habit tomorrow?
• Risk assessment: On Track, Needs Attention, or At Risk
• Personalized motivational nudges at your optimal time
• Learns from day-of-week patterns, mood, sleep, and activity

MOOD & WELLNESS TRACKING (PRO)
• Quick 5-point mood check-ins throughout the day
• Optional journal entries with sentiment analysis
• Visual mood trends and patterns over time
• Discover how emotions correlate with habit consistency
• Export mood history for reflection or therapy

APPLE HEALTH INTEGRATION (PRO)
• Real-time insights: how steps, sleep, and heart rate affect your habits
• Sleep stage analysis and sleep quality correlation
• Active energy and movement patterns
• Heart rate variability (HRV) insights
• Read-only access — your health data never leaves your device

ADVANCED ANALYTICS & INSIGHTS
• Beautiful calendar heatmap of habit completion
• Completion rate charts with 7-day, 30-day, and custom ranges
• Day-of-week analysis: identify your strongest and weakest days
• AI-generated weekly coaching recaps with personalized advice
• Export data to CSV for deeper analysis

HOME SCREEN WIDGETS
• Habit grid widget for at-a-glance status
• Progress ring widget for focused tracking
• Streak countdown widget for motivation
• Multiple sizes: small, medium, large, and lock screen

PRIVACY IS SACRED
• 100% on-device processing using Apple's Core ML framework
• No user accounts, no sign-in required
• Zero data collection or transmission
• No analytics, no crash reporting, no tracking
• No third-party SDKs accessing your data
• Export your complete data to CSV anytime
• Works entirely offline

FLEXIBLE PRICING
• Free: Track up to 3 habits with basic streak features
• Pro Monthly: $2.99/month — unlimited habits, AI, mood tracking, HealthKit, iCloud sync, widgets, CSV export
• Pro Annual: $29.99/year with 2-week free trial — save 16% vs. monthly
• Pro Lifetime: $39.99 one-time purchase — all features forever, no recurring charges
• Tip jar available to support indie development

Perfect for: building routines, habit stacking, breaking bad habits, productivity, wellness, fitness goals, meditation, journaling, hydration, exercise, reading, or any habit you want to master.

Made by an indie developer with your privacy as the first principle. Your habits are personal. Keep them that way.
```

### Keywords (100 chars max, comma-separated)
```
habit,AI,productivity,wellness,health,routine,tracker,mood,goals,tracker
```
(Character count: 77 chars - optimize for search relevance and App Store ranking)

### Support URL
```
https://[your-domain]/support
```
(Use the support page from your docs/ folder -- you'll need to host it)

### Marketing URL (optional)
```
https://[your-domain]
```
(Use the landing page from your docs/ folder)

### Privacy Policy URL (required)
```
https://[your-domain]/privacy
```
(Use the privacy policy from your docs/ folder -- **this is required before submission**)

### What's New in This Version
```
Initial release! Build habits that actually stick with on-device AI coaching.

• Smart habit tracking with streaks and milestones
• AI-powered predictions -- know when you're at risk
• Mood tracking with journal entries
• Apple Health integration
• Beautiful home screen widgets
• Weekly AI-generated recaps
• 100% private -- everything runs on your device
```

---

## 8. APP PRIVACY DETAILS

Navigate to **App Store → App Privacy**.

This is **required** and must accurately reflect your data practices. Based on Habitra's code:

### Data Collection Declaration

Click **"Get Started"** and answer:

**"Do you or your third-party partners collect data from this app?"**
→ **Yes** (HealthKit data is read, even though it stays on-device)

### Data Types

For each data type, specify:

#### Health & Fitness
- **Health** (HealthKit data: steps, sleep, heart rate, HRV, active energy)
  - **Usage:** App Functionality
  - **Linked to User:** No
  - **Used for Tracking:** No
  - **Data is processed only on the device:** Yes

#### Diagnostics (if using crash reporting)
- If you use **no** crash reporting or analytics SDKs, you can skip this
- If you add any later (e.g., Firebase Crashlytics), update this section

### Summary

Your privacy nutrition label should show:
- **Data Not Collected** (if no analytics/crash reporting)
- OR **Data Used to Track You: None** + **Data Linked to You: None** + **Data Not Linked to You: Health** (if HealthKit only)

> **Important:** Apple takes privacy labels seriously. Since Habitra processes everything on-device with no accounts, your label should be very clean. This is a selling point.

---

## 9. BUILD & UPLOAD

### Step 9a: Archive the App

1. In Xcode, select your **physical device** or **"Any iOS Device (arm64)"** as the build destination
2. Ensure your **signing certificate** and **provisioning profile** are set to Distribution (not Development)
3. Go to **Product → Archive**
4. Wait for the build to complete

### Step 9b: Validate the Archive

1. In the **Organizer** window (Window → Organizer), select your archive
2. Click **"Validate App"**
3. Choose distribution options:
   - Upload destination: App Store Connect
   - Strip Swift symbols: Yes
   - Upload symbols: Yes
4. Fix any validation errors before proceeding

### Common Validation Issues and Fixes

| Issue | Fix |
|-------|-----|
| Missing app icon | Ensure `AppIcon_1024.png` is in asset catalog, no alpha channel |
| Invalid bundle ID | Must match what's in App Store Connect |
| Provisioning profile mismatch | Re-create profile in Developer portal |
| Missing privacy descriptions | Add all `NS*UsageDescription` keys to Info.plist |
| Widget extension issues | Ensure widget target has its own bundle ID and profile |

### Step 9c: Upload to App Store Connect

1. After validation passes, click **"Distribute App"**
2. Select **"App Store Connect"**
3. Choose **"Upload"**
4. Wait for upload to complete (may take several minutes)
5. You'll receive an email when processing is complete (usually 15-30 minutes)

### Step 9d: Verify Info.plist Privacy Descriptions

Your Info.plist must include descriptions for all permissions used. Based on Habitra's code, verify these are present:

| Key | Description |
|-----|-------------|
| `NSHealthShareUsageDescription` | "Habitra reads your steps, sleep, and heart rate data to discover how health metrics affect your habit completion. All analysis happens on-device." |
| `NSUserTrackingUsageDescription` | Not needed (you don't track) |

Check your Info.plist has all required keys before uploading.

---

## 10. APP REVIEW PREPARATION

### Step 10a: Select the Build

1. In App Store Connect, go to your app version
2. Under **"Build"**, click **"+"** to select the uploaded build
3. Choose the build you just uploaded

### Step 10b: App Review Information

Navigate to **App Store → [Version] → App Review Information**.

| Field | Value |
|-------|-------|
| **Contact First Name** | Jeanese |
| **Contact Last Name** | Raymond |
| **Contact Phone** | [Your phone number] |
| **Contact Email** | [Your email] |
| **Sign-in Required** | No (Habitra has no accounts!) |
| **Notes for Reviewer** | See below |

### Review Notes Template
```
Thank you for reviewing Habitra!

IMPORTANT: This app uses NO user accounts. All data is stored locally on-device using SwiftData. There is no sign-in required.

TO TEST THE APP:
1. Open the app -- you'll see the onboarding flow
2. Complete onboarding (3 screens)
3. Create a habit by tapping the "+" button
4. Complete the habit by tapping its circle
5. View your streak grow

TO TEST AI FEATURES (PRO):
The AI prediction engine requires ~7 days of habit data to generate meaningful predictions. For review purposes, the AI coaching messages on the Today view will show general motivational messages immediately.

TO TEST IN-APP PURCHASES:
Please use a Sandbox account to test subscriptions. All three tiers (Monthly $2.99, Annual $29.99, Lifetime $39.99) and tip jar items are available.

TO TEST HEALTHKIT:
Grant Health permissions when prompted. The app reads steps, sleep, heart rate, HRV, and active energy. All processing is on-device.

TO TEST WIDGETS:
Long-press the home screen → tap "+" → search "Habitra" → add any widget.

PRIVACY NOTE:
This app collects NO user data. All AI processing uses Core ML on-device. No analytics SDKs, no crash reporting, no network calls for user data. The only network activity is for App Store subscription validation.
```

### Step 10c: Common Rejection Reasons & How to Avoid Them

| Rejection Reason | How to Avoid |
|-----------------|-------------|
| **Guideline 2.1 -- App crashes** | Test on multiple devices and iOS versions. Test cold launch, background/foreground, and low memory. |
| **Guideline 2.3 -- Incomplete app** | Ensure all features work, no placeholder text, no "coming soon" features. |
| **Guideline 3.1.1 -- IAP issues** | All premium features must use Apple's IAP. Don't link to external payment. Restore purchases must work. |
| **Guideline 3.1.2 -- Subscription info** | Subscription screens must clearly show: price, duration, free trial length, and auto-renewal terms. Include links to Terms of Use and Privacy Policy. |
| **Guideline 4.0 -- Design** | No webview-only apps. Must feel native. Habitra is SwiftUI-native, so this is fine. |
| **Guideline 5.1.1 -- Data collection** | Privacy label must match actual data collection. Since you collect nothing, this should be clean. |
| **Guideline 5.1.2 -- HealthKit** | HealthKit data must be used for health/fitness purposes (it is). Must not be stored in iCloud (verify). Must have a privacy policy. |
| **Guideline 5.1.3 -- Health claims** | Don't claim the app can diagnose, treat, or cure any condition. |

### Step 10d: Subscription Compliance Checklist

Apple requires specific disclosures on your subscription/paywall screen. Verify these are visible in your app:

- [ ] **Price** clearly displayed for each tier
- [ ] **Duration** of each subscription period
- [ ] **Free trial length** mentioned for annual plan
- [ ] **Auto-renewal disclosure**: "Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period."
- [ ] **Link to Terms of Use** (can be your support URL)
- [ ] **Link to Privacy Policy**
- [ ] **Restore Purchases** button visible on paywall

---

## 11. SUBMIT FOR REVIEW

### Pre-Submission Checklist

- [ ] App name, subtitle, and description are final
- [ ] Screenshots uploaded for all required device sizes
- [ ] App icon uploaded (1024x1024, no transparency)
- [ ] Keywords filled in (100 chars max)
- [ ] Privacy Policy URL is live and accessible
- [ ] Support URL is live and accessible
- [ ] Age rating questionnaire completed
- [ ] App Privacy details completed
- [ ] Build selected and processed
- [ ] In-App Purchases created and approved (they go through their own review)
- [ ] Review notes and contact info filled in
- [ ] App tested on physical device
- [ ] All Info.plist privacy descriptions present

### Submit

1. Go to your app version in App Store Connect
2. Review everything one more time
3. Click **"Add for Review"**
4. Then click **"Submit to App Review"**

### Review Timeline

- **Typical review time:** 24-48 hours (can be faster or slower)
- **Expedited review:** Available at [developer.apple.com/contact/app-store](https://developer.apple.com/contact/app-store) for critical fixes
- **Status updates:** You'll receive email notifications. Check App Store Connect for status:
  - **Waiting for Review** → In the queue
  - **In Review** → A reviewer is looking at it
  - **Approved** / **Ready for Sale** → You're live!
  - **Rejected** → Read the rejection reason carefully, fix, and resubmit

---

## 12. POST-SUBMISSION

### After Approval

1. **Verify the listing** -- Download your own app from the App Store, verify everything looks correct
2. **Test IAP in production** -- Make a real purchase and verify it works
3. **Share the link** -- Your App Store URL will be: `https://apps.apple.com/app/habitra-ai-habit-tracker/id[YOUR_APP_ID]`
4. **Update your website** -- Add the App Store badge and link to your landing page
5. **Social media launch posts** -- Execute Day 8 of the campaign!

### App Store Optimization (ASO) Tips

- **Update keywords** based on search performance (check App Store Connect → App Analytics)
- **Respond to reviews** -- shows engagement, builds trust
- **A/B test screenshots** -- App Store Connect supports product page optimization tests
- **Localize** -- If you expand to other markets, localize your metadata
- **Update regularly** -- Apps with recent updates rank higher

### Useful App Store Connect URLs

- Dashboard: appstoreconnect.apple.com
- App Analytics: App Store Connect → Analytics tab
- Sales & Trends: App Store Connect → Trends tab
- Payments & Financial Reports: App Store Connect → Payments tab

---

## QUICK REFERENCE: FILE LOCATIONS IN YOUR PROJECT

| Asset | Location |
|-------|----------|
| App Icon (1024x1024) | `Pulsr/Assets.xcassets/AppIcon.appiconset/AppIcon_1024.png` |
| Info.plist | `Pulsr/Info.plist` |
| StoreKit Config | `Pulsr/Configuration.storekit` |
| Landing Page | `docs/index.html` |
| Privacy Policy | `docs/privacy.html` (verify this exists) |
| Support Page | `docs/support.html` (verify this exists) |
| Entitlements | `Pulsr/Pulsr.entitlements` |

---

## HOSTING YOUR REQUIRED URLS

Apple requires live URLs for Privacy Policy, Support, and optionally Marketing. Options:

1. **GitHub Pages** (free): Push your `docs/` folder to GitHub, enable Pages in repo settings
2. **Netlify** (free tier): Connect your repo, deploy `docs/` folder
3. **Your own domain**: Upload the HTML files from `docs/` to your web host

The URLs must be accessible to Apple's reviewers at the time of submission.
