# Habitra v1.0 -- Soft Launch Plan (Free-Only)

**Status:** Pre-launch
**Target:** English-speaking markets (US, UK, Canada, Australia)
**Model:** Free app + Tip Jar. No subscriptions in v1.0.
**Reference:** `docs/RELEASE_STRATEGY.md` for the full free-vs-Pro breakdown.

---

## TABLE OF CONTENTS

1. [Executive Summary](#1-executive-summary)
2. [Target Markets](#2-target-markets)
3. [Phased Rollout](#3-phased-rollout)
4. [The Launch as a Marketing Tool](#4-the-launch-as-a-marketing-tool)
5. [Social Media Campaign Adaptation](#5-social-media-campaign-adaptation)
6. [App Store Optimization (ASO)](#6-app-store-optimization-aso)
7. [Custom Product Page A/B Testing](#7-custom-product-page-ab-testing)
8. [Metrics and KPIs](#8-metrics-and-kpis)
9. [When to Introduce Paid Tiers](#9-when-to-introduce-paid-tiers)
10. [Risk Mitigation](#10-risk-mitigation)

---

## 1. EXECUTIVE SUMMARY

Habitra v1.0 launches as a **completely free** habit tracker -- no paywalls, no subscriptions, no feature gates beyond a 5-habit limit. This is a deliberate strategy, not a lack of monetization:

- **Remove friction:** Free apps get 10-50x more downloads than paid apps in the same category. Downloads drive App Store ranking, which drives organic discovery.
- **Build a user base first:** 1,000 active users who love the free product are worth more than 50 users who paid $4.99 and churned.
- **Create anticipation:** Five "Coming Soon" features (AI Coach, HealthKit, iCloud Sync, More Widgets, Weekly Quests) are teased in-app and on the website. Each becomes a mini-launch event when it ships.
- **Fund development with tips:** The Tip Jar ($1.99 / $4.99 / $9.99) validates willingness-to-pay without gating features.

The product launch itself is the marketing tool. "Everything is free" is a story worth telling.

---

## 2. TARGET MARKETS

### Day 1 Markets

| Market | Rationale |
|--------|-----------|
| **United States** | Largest English-speaking App Store market, highest download volume |
| **United Kingdom** | Strong privacy awareness, high App Store engagement |
| **Canada** | High-quality users, often used as a test market for US launches |
| **Australia** | English-speaking, different timezone provides 24/7 feedback cycle |

### Why all four from Day 1

- The app is free -- there is no financial risk from wide availability.
- A larger geographic footprint increases download velocity, which boosts App Store ranking.
- Different timezones mean bugs surface faster (Australian morning = US evening).
- App Store Connect analytics break down by market, so we can still measure per-country performance.

### Future expansion

After Phase 3 (Week 8), evaluate adding:
- Germany, France, Japan (localization required)
- India, Brazil (high volume, lower ARPU -- useful for ranking, less for tips)

---

## 3. PHASED ROLLOUT

### Phase 0: Pre-Launch (2 weeks before submission)

**Goal:** Everything ready for a clean launch day.

**Checklist:**
- [ ] All free-only documentation finalized:
  - [ ] `docs/app-store-product-page-free.md` -- metadata, screenshots, review notes
  - [ ] `docs/Github files/*-free.html` -- website pages
  - [ ] `docs/RELEASE_STRATEGY.md` -- authoritative free-vs-Pro source
- [ ] App Store Connect configured:
  - [ ] App listing with free-only metadata (name, subtitle, keywords, description)
  - [ ] 8 free-only screenshots uploaded for all device sizes
  - [ ] App preview video uploaded (Video 1: "A Day with Habitra")
  - [ ] 3 Custom Product Pages created (Fitness, Productivity, Privacy)
  - [ ] Subscription products marked "Removed from Sale"
  - [ ] Tip Jar products active ($1.99, $4.99, $9.99)
  - [ ] App Review notes pasted (free-only version)
  - [ ] Privacy Policy URL pointing to privacy-free.html
  - [ ] Support URL pointing to support-free.html
- [ ] Build submitted for App Review
- [ ] Website deployed with -free.html pages
- [ ] Social media accounts set up / verified
- [ ] Begin social media campaign Phase 1 (adapted -- see Section 5)

**Timeline:** Submit build at least 5 business days before target launch date. Average review time is 24-48 hours, but allow buffer for rejections.

### Phase 1: Soft Launch (Weeks 1-2)

**Goal:** Validate stability, collect initial feedback, seed ratings.

**Actions:**
- App goes live on the App Store in all 4 markets
- Monitor crash rates via Xcode Organizer (no third-party crash reporting -- privacy-first)
- Respond to every App Store review within 24 hours
- Social media campaign Phase 2 (launch week -- adapted)
- Share app link in relevant communities (Reddit r/getdisciplined, r/theXeffect, r/habittracking)
- Ask 5-10 trusted friends/family to download, use, and rate

**Success criteria:**
- 200+ downloads
- 4.0+ star rating
- 99%+ crash-free sessions
- No critical bugs reported

**If criteria NOT met:**
- Crash rate > 1%: Pull the build, fix, resubmit
- Rating < 3.5: Investigate reviews, ship hotfix
- < 100 downloads: Increase social posting frequency, consider small Apple Search Ads spend

### Phase 2: Growth (Weeks 3-4)

**Goal:** Accelerate organic discovery, begin optimization.

**Actions:**
- Activate Apple Search Ads (Basic tier):
  - Budget: $50-100/month
  - Keywords: "habit tracker", "streak tracker", "daily routine", "private habit tracker"
  - Match each keyword group to the most relevant Custom Product Page
- Launch PPO Test 1 (Hero Screenshot A/B test)
- Social media campaign Phase 3
- Begin engaging in App Store Connect developer forums
- Write and publish a "Why I made Habitra free" blog post / Reddit post (indie dev story angle)

**Success criteria:**
- 500+ cumulative downloads
- 10+ ratings (maintaining 4.0+)
- Tip Jar revenue > $0 (validates willingness-to-pay)
- Apple Search Ads cost-per-install < $2.00

### Phase 3: Sustain & Evaluate (Weeks 5-8)

**Goal:** Build retention, understand user behavior, prepare for Pro decision.

**Actions:**
- Social media campaign Phase 4 + ongoing content
- Launch PPO Test 2 and 3
- Analyze Tip Jar data:
  - Conversion rate (tips / downloads)
  - Average tip amount
  - Time-to-tip (days from install to first tip)
- Monitor habit limit hits:
  - How many users reach 5 habits?
  - How quickly do they reach it?
  - Do they churn after hitting the limit?
- In-app feedback: Consider adding a lightweight "What feature do you want most?" prompt after the user's first 7-day streak
- Update promotional text seasonally (no new build needed)

**Success criteria:**
- 1,000+ cumulative downloads
- Day-7 retention > 25%
- Tip Jar cumulative revenue > $200
- 30+ ratings (maintaining 4.3+)

### Phase 4: Pro Tier Decision (Weeks 8-12)

**Goal:** Decide when and how to introduce paid features.

See [Section 9](#9-when-to-introduce-paid-tiers) for the decision framework.

---

## 4. THE LAUNCH AS A MARKETING TOOL

### Core Narrative: "Everything Free"

The counter-positioning strategy: most habit trackers gate basic features behind paywalls. Habitra gives everything away. This is inherently newsworthy.

**Messaging pillars:**

1. **"We believe habit tracking should be free."**
   - Competitors charge $4.99-$9.99/month for features Habitra gives away
   - The comparison itself is the marketing
   - Use in: App Store description, social media, website hero

2. **"No ads. No tracking. No cloud. No compromise."**
   - Privacy as a feature, not a footnote
   - Appeals to the growing segment of privacy-conscious users
   - Use in: Privacy CPP, Reddit posts, Twitter threads

3. **"Built by one developer who thinks your habits are your business."**
   - Indie dev authenticity resonates on Reddit, Twitter, Product Hunt
   - Personal story creates emotional connection
   - Use in: Launch announcement posts, About page, bio links

### "Coming Soon" as Anticipation Hooks

The 5 roadmap features teased in-app create a built-in engagement loop:

| Feature | Marketing Angle | Where to Tease |
|---------|----------------|----------------|
| On-device AI Coach | "AI that never sees your data" | Website, Twitter threads |
| Apple Health Integration | "Your workouts will auto-complete your habits" | Instagram fitness, Reddit |
| iCloud Sync | "Same habits, every device, encrypted" | Twitter, website |
| More Widgets & StandBy | "Your streaks everywhere you look" | Instagram stories, TikTok |
| Weekly Quests | "Gamify your consistency" | Reddit r/gamification, TikTok |

**Rules:**
- "Coming Soon" appears ONLY on the website and social media, NEVER in App Store metadata (Guideline 2.3.8)
- Use aspirational language: "We're building..." not "Coming in v2.0"
- No dates. "We ship when it's ready."
- Each feature launch becomes its own mini-launch event with press, social, and App Store update

### Launch Channels

| Channel | Strategy | Timing |
|---------|----------|--------|
| **Reddit** | r/getdisciplined, r/theXeffect, r/habittracking, r/privacy, r/apple | Phase 1, Day 1 |
| **Twitter/X** | Thread: "I built a free habit tracker. Here's why I didn't charge for it." | Phase 1, Day 1 |
| **Product Hunt** | Full launch with screenshots, description, maker story | Phase 2, Week 3 |
| **Instagram** | Screenshot carousel, streak card shares, widget showcase | Phase 1-3, ongoing |
| **TikTok** | "POV: Your habit tracker doesn't sell your data" | Phase 2-3, ongoing |
| **Apple Search Ads** | Basic tier, keyword targeting with CPPs | Phase 2, Week 3 |
| **Indie Hacker communities** | Indie Hackers, Hacker News (Show HN) | Phase 2, Week 3-4 |

### Product Hunt Launch Playbook

**Timing:** Week 3 (after initial bugs are fixed and ratings are seeded)

**Preparation:**
- [ ] Create Product Hunt maker account
- [ ] Prepare: tagline, description, 4 screenshots, maker comment
- [ ] Tagline: "Free, private habit tracking. No ads. No cloud. No compromise."
- [ ] First comment: "Hey! I'm Jeanese, the solo developer behind Habitra. [Personal story about why habits matter + why privacy matters + why it's free]"
- [ ] Schedule launch for Tuesday-Thursday (highest Product Hunt traffic)
- [ ] Alert friends/supporters to upvote and comment on launch day

---

## 5. SOCIAL MEDIA CAMPAIGN ADAPTATION

The existing 30-day campaign (`docs/30-day-social-media-campaign.md`) references Pro features on several days. Here's how to adapt each:

| Day | Original Topic | Free v1.0 Adaptation |
|-----|---------------|---------------------|
| 5 | Mood + Habits Connection | **"Coming Soon" teaser:** "What if your habit tracker understood how you feel? We're building mood tracking that connects your emotions to your habits. Stay tuned." |
| 6 | HealthKit Teaser | **"Coming Soon" teaser:** "Imagine your morning run auto-completing your Exercise habit. Apple Health integration is on our roadmap." |
| 13 | Free vs Pro Comparison | **Replace entirely:** "Everything is free" celebration post. "Most habit trackers charge $5-10/month for what Habitra gives you for free. No catch. No paywall. Just habits." |
| 16 | AI Coaching Deep Dive | **Replace with:** Streak tracking deep dive. "Your streaks tell a story. Here's how to read yours." Show heatmap, streak milestones, day-of-week patterns. |
| 21 | Weekly Recap Feature | **Replace with:** Manual weekly review tips. "Sunday check-in: Open Stats, look at your heatmap, celebrate your wins, plan your week." |
| 26 | Data Export Feature | **Replace with:** Privacy + data ownership post. "Your data lives on your phone. Period. No servers. No analytics. No tracking. Your habits are nobody's business but yours." |
| 28 | Lifetime Deal Highlight | **Replace with:** Tip Jar appreciation post. "Habitra is free forever. But if you want to support indie development, our Tip Jar is how. Every coffee helps." |

**All other days remain unchanged** -- they focus on free features (streaks, habits, reminders, widgets, badges).

---

## 6. APP STORE OPTIMIZATION (ASO)

### Keyword Strategy

Free apps benefit from higher download velocity, which boosts keyword rankings. Focus on:

**Primary keywords (high volume, moderate competition):**
- habit tracker
- streak tracker
- daily routine
- habit building

**Secondary keywords (lower volume, lower competition):**
- private habit tracker
- offline habit tracker
- no account habit tracker
- free habit tracker

**Avoid competing on:**
- "AI" keywords (feature is hidden)
- "HealthKit" / "health tracker" (feature is hidden)
- "mood tracker" (feature is hidden)

**Monitor weekly:** App Store Connect > Analytics > Sources > Search Terms

### Conversion Rate Optimization

| Element | Best Practice | Habitra v1.0 |
|---------|-------------|-------------|
| Icon | Recognizable at small sizes | Purple waveform on dark background |
| Name | Include primary keyword | "Habitra - Habit Tracker" |
| Subtitle | Benefit-focused, not feature-list | "Build streaks. Track progress. Stay private." |
| Screenshot 1 | Show core experience immediately | Today View with 5 habits |
| Promotional text | Updated frequently for seasonal hooks | Rotated monthly |

### Rating Strategy

**When to prompt:** After the user's first 7-day streak milestone. This is a high-emotion moment (confetti, celebration) where the user feels accomplished and positive.

**When NOT to prompt:**
- First day of use
- After a broken streak
- After hitting the 5-habit limit
- Within 48 hours of a previous prompt

**Implementation:** Use Apple's native `SKStoreReviewController.requestReview()`. Apple limits display to 3 times per 365-day period per device.

**Target:** 4.5+ stars within the first 50 reviews.

---

## 7. CUSTOM PRODUCT PAGE A/B TESTING

### Test 1: Hero Screenshot (Launch + 2 weeks)

| Variant | Screenshot 1 | Hypothesis |
|---------|-------------|------------|
| Control | Today View | Core experience converts broadly |
| Treatment A | Streak Celebration | Emotional aspiration converts better |
| Treatment B | XP & Badges | Gamification hook attracts casual users |

**Run until:** 90% statistical confidence or 14 days, whichever comes first.

### Test 2: CPP vs. Keyword Matching (Launch + 4 weeks)

Match Custom Product Pages to Apple Search Ads keyword groups:

| Keyword Group | CPP | Measure |
|--------------|-----|---------|
| "workout tracker", "fitness habits" | Fitness & Wellness CPP | Tap-to-install rate |
| "daily routine", "productivity tracker" | Productivity & Routines CPP | Tap-to-install rate |
| "private tracker", "no cloud tracker" | Privacy-First CPP | Tap-to-install rate |

**Goal:** Identify which CPP converts best for each audience segment.

### Test 3: Tagline Style (Launch + 6 weeks)

| Variant | Tagline | Style |
|---------|---------|-------|
| Control | "Your habits. Your rhythm. Your day." | Poetic / emotional |
| Treatment A | "Build habits that actually stick." | Benefit-focused |
| Treatment B | "The free habit tracker that respects your privacy." | USP-focused |

---

## 8. METRICS AND KPIs

### Weekly Dashboard

| Metric | Phase 1 (W1-2) | Phase 2 (W3-4) | Phase 3 (W5-8) | Phase 4 (W8-12) |
|--------|----------------|----------------|----------------|-----------------|
| **Downloads (cumulative)** | 200 | 500 | 1,000 | 2,000+ |
| **Day-1 Retention** | 40%+ | 40%+ | 45%+ | 45%+ |
| **Day-7 Retention** | 20%+ | 25%+ | 25%+ | 30%+ |
| **Tip Jar Revenue (cumulative)** | $50 | $150 | $400 | $800+ |
| **Tip Jar Conversion** | 2%+ | 3%+ | 3%+ | 4%+ |
| **App Store Rating** | 4.0+ | 4.3+ | 4.5+ | 4.5+ |
| **Crash-Free Rate** | 99%+ | 99.5%+ | 99.5%+ | 99.5%+ |
| **5-Habit Limit Hits** | Track | Track | Analyze | Decide |

### Where to Find These Metrics

| Metric | Source |
|--------|--------|
| Downloads, impressions, conversion | App Store Connect > Analytics |
| Retention (Day-1, Day-7) | App Store Connect > Analytics > Retention |
| Revenue | App Store Connect > Sales and Trends |
| Ratings & reviews | App Store Connect > Ratings and Reviews |
| Crash-free rate | Xcode Organizer > Crashes |
| Keyword rankings | App Store Connect > Analytics > Sources |

### Retention Benchmarks (Health & Fitness category)

| Timeframe | Industry Average | Habitra Target |
|-----------|-----------------|---------------|
| Day 1 | 25-35% | 40%+ |
| Day 7 | 12-18% | 25%+ |
| Day 30 | 6-10% | 15%+ |

> Habitra should beat averages because: (a) free = lower "buyer's remorse" churn, (b) streaks create daily return motivation, (c) no account friction = faster time-to-value.

---

## 9. WHEN TO INTRODUCE PAID TIERS

### Decision Framework

Introduce the Pro tier when **ALL** of the following are true:

| Criterion | Threshold | Why |
|-----------|-----------|-----|
| Active users (retained past Day 7) | 1,000+ | Large enough base to monetize meaningfully |
| App Store rating | 4.3+ with 30+ reviews | Proves product quality before adding complexity |
| Crash-free rate | 99.5%+ | Stability must be flawless before adding features |
| First Pro feature ready | At least one fully built and tested | Don't sell what doesn't exist |
| User signal | Feedback/surveys indicate demand | Build what users actually want |

### Which Feature to Ship First

**Recommended: AI Coach or HealthKit** (highest perceived value, highest marketing potential).

| Feature | Effort | Marketing Value | User Demand Signal |
|---------|--------|----------------|-------------------|
| AI Coach | High | Very High ("AI" is a search magnet) | Monitor social mentions |
| HealthKit | Medium | High (Apple Watch audience) | Monitor "health" keyword searches |
| iCloud Sync | Medium | Medium (utility, not exciting) | Monitor "sync" support requests |
| More Widgets | Low | Medium (visual, shareable) | Monitor widget-related reviews |
| Weekly Quests | Medium | Medium (gamification crowd) | Monitor "quests" in-app taps |

### How to Introduce Pro

1. **Ship the feature as a v1.1 update** -- the update itself is newsworthy
2. **Flip the `FeatureAvailability` flag** for that feature
3. **Re-enable subscription products** in App Store Connect ("Available for Sale")
4. **Update App Store metadata:**
   - Name: "Habitra - AI Habit Tracker" (add "AI" back if AI Coach is the feature)
   - Keywords: Add `AI`, `coach`, etc. back
   - Screenshots: Add Pro feature screenshot(s)
   - Description: Add Pro tier description
5. **Update website:** Replace -free.html pages with new versions that include Pro
6. **Marketing push:** Treat it as a second launch
   - Product Hunt update
   - "We just shipped AI coaching" social media blitz
   - Apple Search Ads with AI-focused keywords
   - Email existing tip-jar customers (if we have a way to reach them)

### Pricing Consideration

- Start with **Annual ($29.99/year) + Lifetime ($39.99)** only -- higher ARPU, simpler choice
- Add Monthly ($4.99/month) after 2 weeks if Annual conversion is low
- **Never take away free features.** Everything free in v1.0 stays free forever.
- Consider a "launch week" discount (e.g., Annual at $19.99 for the first week)

---

## 10. RISK MITIGATION

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| App Store rejection | Medium | High | Submit 5+ days early. Have backup plan for review notes. Remove any "Coming Soon" from metadata. |
| Low downloads | Medium | Medium | Increase social posting, activate Search Ads earlier, post to Product Hunt sooner. |
| Negative reviews | Low | High | Respond within 24 hours. Ship hotfixes within 48 hours. |
| Tip Jar earns $0 | Medium | Low | Tips are validation, not revenue. $0 tips just mean: don't price Pro too low. |
| Users churn at 5-habit limit | Medium | Medium | Monitor closely. If >30% of limit-hitters churn within 7 days, consider raising to 7 or 10. |
| Competitor copies the "everything free" angle | Low | Low | First-mover advantage + privacy positioning is hard to replicate. |
| Apple changes App Store guidelines re: "Coming Soon" | Low | Medium | In-app roadmap is clearly labeled "planned", not "promised". Website content is outside Apple's jurisdiction. |

---

## APPENDIX: TIMELINE SUMMARY

```
Week -2    Pre-launch prep, submit build, begin social campaign
Week -1    App Review, final fixes, social campaign continues
Week 1     LAUNCH DAY. Monitor crashes, respond to reviews.
Week 2     Seed ratings, community engagement, bug fixes
Week 3     Activate Search Ads, Product Hunt launch, PPO Test 1
Week 4     CPP A/B testing, analyze Search Ads performance
Week 5-6   Sustain content, analyze Tip Jar data
Week 7-8   User survey, evaluate habit limit hits, PPO Tests 2-3
Week 9-10  Pro tier decision point
Week 11-12 If ready: ship Pro feature, second launch event
```

## APPENDIX: QUICK REFERENCE

- **App Store product page:** `docs/app-store-product-page-free.md`
- **Social media campaign:** `docs/30-day-social-media-campaign.md` (adapt per Section 5)
- **Free vs Pro feature list:** `docs/RELEASE_STRATEGY.md`
- **Feature flag layer:** `Pulsr/Services/FeatureAvailability.swift`
- **In-app roadmap items:** `Pulsr/Views/Paywall/PaywallView.swift` (roadmapRow calls)
- **Website pages:** `docs/Github files/*-free.html`
