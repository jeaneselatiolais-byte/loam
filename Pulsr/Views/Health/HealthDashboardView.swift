//
//  HealthDashboardView.swift
//  Habitra
//
//  Phase 4: HealthKit correlation dashboard
//

import SwiftUI
import SwiftData

struct HealthDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var healthManager = HealthKitManager.shared

    @Query(filter: #Predicate<Habit> { !$0.isArchived },
           sort: \Habit.sortOrder)
    private var habits: [Habit]

    @State private var correlations: [HealthCorrelation] = []
    @State private var isLoading = false
    @State private var isRequesting = false
    @State private var authError: String?
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                if !SubscriptionManager.canUseHealthKit {
                    proGate
                } else if !healthManager.isAvailable {
                    unavailableView
                } else if !healthManager.isAuthorized {
                    authorizationView
                } else if isLoading {
                    loadingView
                } else {
                    contentView
                }
            }
            .navigationTitle("Health Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.habitraAccent)
                }
            }
            .task {
                guard SubscriptionManager.canUseHealthKit,
                      healthManager.isAvailable,
                      healthManager.isAuthorized
                else { return }
                await loadData()
            }
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            VStack(spacing: HabitraTheme.spacingLarge) {
                // Today's health snapshot
                if let today = healthManager.recentData.first {
                    todayHealthCard(today)
                }

                // Correlations
                if !correlations.isEmpty {
                    correlationsSection
                }

                // Recent health data
                if healthManager.recentData.count >= 2 {
                    recentHealthSection
                }

                if correlations.isEmpty && healthManager.recentData.count < 7 {
                    HabitraEmptyState(
                        icon: "heart.text.clipboard",
                        title: "Gathering health data",
                        message: "Keep tracking for a week. Habitra will discover how your health affects your habits."
                    )
                }

                privacyNote
            }
            .padding(.top, HabitraTheme.spacing)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Today's Health

    private func todayHealthCard(_ data: DailyHealthData) -> some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("TODAY")
                .habitraCaption()
                .sectionHeaderAccessibility()

            HStack(spacing: HabitraTheme.spacing) {
                healthMetric(icon: "figure.walk", value: "\(data.steps)", label: "Steps", color: .habitraHabitGreen)
                healthMetric(icon: "bed.double.fill", value: String(format: "%.1f", data.sleepHours), label: "Sleep hrs", color: .habitraHabitBlue)
                healthMetric(icon: "flame.fill", value: "\(Int(data.activeEnergy))", label: "kcal", color: .habitraHabitOrange)

                if let hrv = data.hrv {
                    healthMetric(icon: "heart.fill", value: "\(Int(hrv))", label: "HRV ms", color: .habitraHabitPink)
                }
            }
        }
        .habitraCard()
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    private func healthMetric(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text(value)
                .font(HabitraFont.headline())
                .foregroundStyle(Color.habitraTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(.caption2))
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Correlations

    private var correlationsSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("HEALTH × HABITS")
                .habitraCaption()
                .sectionHeaderAccessibility()
                .padding(.horizontal, HabitraTheme.screenPadding)

            ForEach(correlations.prefix(6)) { corr in
                correlationCard(corr)
                    .padding(.horizontal, HabitraTheme.screenPadding)
            }
        }
    }

    private func correlationCard(_ corr: HealthCorrelation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: corr.metricIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.habitraHabitCyan)

                Text(corr.metricName)
                    .font(HabitraFont.caption())
                    .tracking(0)
                    .textCase(.none)
                    .foregroundStyle(Color.habitraTextTertiary)

                Image(systemName: "arrow.right")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.habitraTextTertiary)

                Image(systemName: corr.habitIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: corr.habitColorHex))

                Text(corr.habitName)
                    .font(HabitraFont.caption())
                    .tracking(0)
                    .textCase(.none)
                    .foregroundStyle(Color.habitraTextPrimary)

                Spacer()

                let pct = Int(abs(corr.difference) * 100)
                Text(corr.difference > 0 ? "+\(pct)%" : "-\(pct)%")
                    .font(HabitraFont.caption())
                    .foregroundStyle(corr.difference > 0 ? Color.habitraSuccess : Color.habitraDanger)
            }

            Text(corr.insight)
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            // Comparison bars
            HStack(spacing: HabitraTheme.spacing) {
                comparisonBar(label: "High", rate: corr.highMetricRate, color: .habitraSuccess)
                comparisonBar(label: "Low", rate: corr.lowMetricRate, color: .habitraTextTertiary)
            }
        }
        .habitraCard()
    }

    private func comparisonBar(label: String, rate: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.system(.caption2))
                    .foregroundStyle(Color.habitraTextTertiary)
                Spacer()
                Text("\(Int(rate * 100))%")
                    .font(.system(.caption2))
                    .foregroundStyle(color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.habitraSurfaceLight)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geo.size.width * rate, height: 4)
                }
            }
            .frame(height: 4)
        }
    }

    // MARK: - Recent Health

    private var recentHealthSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("LAST 7 DAYS")
                .habitraCaption()
                .sectionHeaderAccessibility()
                .padding(.horizontal, HabitraTheme.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(healthManager.recentData.prefix(7)) { data in
                        VStack(spacing: 4) {
                            Text(data.date.formatted(.dateTime.weekday(.abbreviated)))
                                .font(.system(.caption2))
                                .foregroundStyle(Color.habitraTextTertiary)

                            Text("\(data.steps)")
                                .font(HabitraFont.footnote())
                                .foregroundStyle(data.steps >= 7000 ? Color.habitraSuccess : Color.habitraTextSecondary)

                            Text(String(format: "%.1fh", data.sleepHours))
                                .font(.system(.caption2))
                                .foregroundStyle(data.sleepHours >= 7 ? Color.habitraHabitBlue : Color.habitraTextTertiary)
                        }
                        .frame(width: 48)
                        .padding(.vertical, 8)
                        .background(Color.habitraSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal, HabitraTheme.screenPadding)
            }
        }
    }

    // MARK: - Authorization & Gates

    private var authorizationView: some View {
        VStack(spacing: HabitraTheme.spacingLarge) {
            Spacer()

            Image(systemName: "heart.text.clipboard")
                .font(.system(size: 56))
                .foregroundStyle(Color.habitraAccent)

            Text("Connect Health Data")
                .font(HabitraFont.title())
                .foregroundStyle(Color.habitraTextPrimary)

            Text("Habitra can read your steps, sleep, and heart rate to discover how health affects your habits. Read-only — we never write to HealthKit.")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            if isRequesting {
                ProgressView()
                    .tint(Color.habitraAccent)
                    .padding()
            } else {
                HabitraButton("Connect HealthKit", icon: "heart.fill") {
                    Task {
                        isRequesting = true
                        authError = nil
                        let authorized = await healthManager.requestAuthorization()
                        if authorized {
                            await loadData()
                        } else {
                            authError = "Could not connect to HealthKit. Please check that Health access is enabled in Settings → Privacy & Security → Health."
                        }
                        isRequesting = false
                    }
                }
                .padding(.horizontal, HabitraTheme.screenPadding)
            }

            if let authError {
                Text(authError)
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraDanger)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }

            Spacer()
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
    }

    private var unavailableView: some View {
        HabitraEmptyState(
            icon: "heart.slash",
            title: "HealthKit unavailable",
            message: "HealthKit is not available on this device."
        )
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
    }

    @MainActor
    private var proGate: some View {
        VStack(spacing: HabitraTheme.spacingLarge) {
            Spacer()

            Image(systemName: "heart.text.clipboard")
                .font(.system(size: 56))
                .foregroundStyle(Color.habitraAccentMuted)

            Text("Health Insights")
                .font(HabitraFont.title())
                .foregroundStyle(Color.habitraTextPrimary)

            Text("Discover how sleep, steps, and heart rate affect your habit completion. A Habitra Pro feature.")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            HabitraButton("Upgrade to Pro", icon: "sparkles") {
                showingPaywall = true
            }
            .padding(.horizontal, HabitraTheme.screenPadding)

            Spacer()
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
    }

    private var privacyNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.habitraAccent)

            Text("Health data is read-only and stays on your device. Habitra never writes to HealthKit or sends health data anywhere.")
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    private var loadingView: some View {
        VStack(spacing: HabitraTheme.spacing) {
            ProgressView()
                .tint(Color.habitraAccent)
            Text("Reading health data...")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextTertiary)
        }
    }

    // MARK: - Data Loading

    private func loadData() async {
        isLoading = true
        await healthManager.fetchRecentData(days: 30)
        correlations = HealthHabitCorrelator.analyze(
            habits: habits,
            healthData: healthManager.recentData
        )
        withHabitraAnimation { isLoading = false }
    }
}

#Preview {
    HealthDashboardView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self], inMemory: true)
}
