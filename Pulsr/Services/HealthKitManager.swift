//
//  HealthKitManager.swift
//  Habitra
//
//  Phase 4: HealthKit integration — steps, sleep, HRV
//  All data read-only, on-device. Pro feature.
//

import Foundation
import HealthKit

/// Daily health snapshot from HealthKit.
struct DailyHealthData: Identifiable {
    let id = UUID()
    let date: Date
    let steps: Int
    let sleepHours: Double        // Total sleep in hours
    let restingHeartRate: Double? // bpm, nil if unavailable
    let hrv: Double?              // ms, nil if unavailable
    let activeEnergy: Double      // kcal
}

/// HealthKit data manager — read-only access to health metrics.
@MainActor
@Observable
final class HealthKitManager {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    var isAuthorized = false
    var isAvailable = HKHealthStore.isHealthDataAvailable()
    var recentData: [DailyHealthData] = []

    private init() {
        // Restore persisted authorization state so we don't wait for
        // the user to re-authorize on every cold launch.
        isAuthorized = UserDefaults.standard.bool(forKey: "healthKitAuthorized")
    }

    // MARK: - Authorization

    /// Request read-only access to health data.
    func requestAuthorization() async -> Bool {
        guard isAvailable else {
            print("Habitra HealthKit: Not available on this device")
            return false
        }
        guard SubscriptionManager.canUseHealthKit else {
            print("Habitra HealthKit: Pro subscription required")
            return false
        }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.workoutType(),
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!,
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            isAuthorized = true
            UserDefaults.standard.set(true, forKey: "healthKitAuthorized")
            return true
        } catch {
            print("Habitra HealthKit: Authorization failed: \(error)")
            return false
        }
    }

    // MARK: - Disconnect (app-side only)

    /// Clears Habitra's stored authorization flag and cached health data.
    /// This stops all HealthKit usage within the app without requiring iOS permission changes.
    /// To fully revoke OS-level access, the user must go to:
    ///   Settings → Privacy & Security → Health → Habitra
    func disconnect() {
        isAuthorized = false
        recentData = []
        UserDefaults.standard.removeObject(forKey: "healthKitAuthorized")
    }

    // MARK: - Fetch Data

    /// Fetch health data for the last N days.
    func fetchRecentData(days: Int = 30) async {
        guard isAvailable, isAuthorized else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var results: [DailyHealthData] = []

        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            guard let endDate = calendar.date(byAdding: .day, value: 1, to: date) else { continue }

            async let steps = fetchSum(.stepCount, start: date, end: endDate)
            async let energy = fetchSum(.activeEnergyBurned, start: date, end: endDate)
            async let sleep = fetchSleepHours(start: date, end: endDate)
            async let rhr = fetchAverage(.restingHeartRate, start: date, end: endDate)
            async let hrv = fetchAverage(.heartRateVariabilitySDNN, start: date, end: endDate)

            let data = DailyHealthData(
                date: date,
                steps: Int(await steps),
                sleepHours: await sleep,
                restingHeartRate: await rhr,
                hrv: await hrv,
                activeEnergy: await energy
            )
            results.append(data)
        }

        recentData = results.sorted { $0.date > $1.date }
    }

    // MARK: - Single Day Fetch

    /// Fetch health data for a specific date.
    func fetchDay(_ date: Date) async -> DailyHealthData? {
        guard isAvailable, isAuthorized else { return nil }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return nil }

        async let steps = fetchSum(.stepCount, start: start, end: end)
        async let energy = fetchSum(.activeEnergyBurned, start: start, end: end)
        async let sleep = fetchSleepHours(start: start, end: end)
        async let rhr = fetchAverage(.restingHeartRate, start: start, end: end)
        async let hrv = fetchAverage(.heartRateVariabilitySDNN, start: start, end: end)

        return DailyHealthData(
            date: start,
            steps: Int(await steps),
            sleepHours: await sleep,
            restingHeartRate: await rhr,
            hrv: await hrv,
            activeEnergy: await energy
        )
    }

    // MARK: - Auto-Complete Queries

    /// All workouts recorded between two dates.
    func fetchWorkouts(start: Date, end: Date) async -> [HKWorkout] {
        guard isAvailable, isAuthorized else { return [] }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                continuation.resume(returning: samples as? [HKWorkout] ?? [])
            }
            healthStore.execute(query)
        }
    }

    /// Total mindful minutes between two dates.
    func fetchMindfulMinutes(start: Date, end: Date) async -> Double {
        guard isAvailable, isAuthorized else { return 0 }
        guard let type = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else { return 0 }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                guard let sessions = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0)
                    return
                }
                let totalSeconds = sessions.reduce(0.0) {
                    $0 + $1.endDate.timeIntervalSince($1.startDate)
                }
                continuation.resume(returning: totalSeconds / 60.0)
            }
            healthStore.execute(query)
        }
    }

    /// Step count between two dates.
    func fetchStepCount(start: Date, end: Date) async -> Int {
        guard isAvailable, isAuthorized else { return 0 }
        return Int(await fetchSum(.stepCount, start: start, end: end))
    }

    /// Sleep hours between two dates (public wrapper).
    func fetchSleepHoursPublic(start: Date, end: Date) async -> Double {
        guard isAvailable, isAuthorized else { return 0 }
        return await fetchSleepHours(start: start, end: end)
    }

    // MARK: - Query Helpers

    private func fetchSum(_ identifier: HKQuantityTypeIdentifier, start: Date, end: Date) async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { return 0 }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let unit: HKUnit = identifier == .stepCount ? .count() : .kilocalorie()
                let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }

    private func fetchAverage(_ identifier: HKQuantityTypeIdentifier, start: Date, end: Date) async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { return nil }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, _ in
                let unit: HKUnit = identifier == .heartRateVariabilitySDNN ?
                    .secondUnit(with: .milli) : HKUnit.count().unitDivided(by: .minute())
                let value = result?.averageQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }

    private func fetchSleepHours(start: Date, end: Date) async -> Double {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return 0 }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0)
                    return
                }

                // Sum asleep intervals (exclude inBed if available)
                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                ]

                let totalSeconds = samples
                    .filter { asleepValues.contains($0.value) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }

                continuation.resume(returning: totalSeconds / 3600.0)
            }
            healthStore.execute(query)
        }
    }
}
