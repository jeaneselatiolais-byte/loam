//
//  CloudSyncManager.swift
//  Habitra
//
//  Phase 4: CloudKit multi-device sync via SwiftData
//  Uses SwiftData's built-in CloudKit integration. Pro feature.
//

import Foundation
import SwiftData
import CloudKit
import CoreData

/// Manages iCloud sync state and configuration.
/// SwiftData handles the actual sync via ModelConfiguration + CloudKit.
@MainActor
@Observable
final class CloudSyncManager {
    static let shared = CloudSyncManager()

    private(set) var syncStatus: SyncStatus = .unknown
    private(set) var lastSyncDate: Date?
    private(set) var iCloudAvailable: Bool = false

    private let containerID = "iCloud.com.jeanese.Habitra"
    private var syncObserver: NSObjectProtocol?
    private var isSyncing = false

    private init() {
        checkAvailability()
        observeSyncEvents()
    }

    // MARK: - Availability

    func checkAvailability() {
        CKContainer(identifier: containerID).accountStatus { status, _ in
            let available: Bool
            let newStatus: SyncStatus
            switch status {
            case .available:
                available = true
                newStatus = .connected
            case .noAccount:
                available = false
                newStatus = .noAccount
            case .restricted, .couldNotDetermine:
                available = false
                newStatus = .unavailable
            case .temporarilyUnavailable:
                available = false
                newStatus = .temporarilyUnavailable
            @unknown default:
                available = false
                newStatus = .unknown
            }

            Task {
                await MainActor.run {
                    self.iCloudAvailable = available
                    // Don't overwrite an active syncing status with the account check result
                    if !self.isSyncing {
                        self.syncStatus = newStatus
                    }
                }
            }
        }
    }

    // MARK: - Sync Event Observation

    private func observeSyncEvents() {
        syncObserver = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let event = notification.userInfo?[
                      NSPersistentCloudKitContainer.eventNotificationUserInfoKey
                  ] as? NSPersistentCloudKitContainer.Event
            else { return }

            Task { @MainActor [weak self] in
                guard let self else { return }
                switch event.type {
                case .setup:
                    break
                case .import, .export:
                    if event.endDate == nil {
                        // Sync started
                        self.isSyncing = true
                        self.syncStatus = .syncing
                    } else {
                        // Sync finished
                        self.isSyncing = false
                        if event.succeeded {
                            self.syncStatus = .upToDate
                            self.lastSyncDate = event.endDate
                        } else {
                            self.syncStatus = self.iCloudAvailable ? .connected : .unavailable
                        }
                    }
                @unknown default:
                    break
                }
            }
        }
    }

    // MARK: - Model Configuration

    /// Create a ModelConfiguration with CloudKit sync enabled.
    /// Call this instead of the default config when Pro + sync enabled.
    static func cloudModelConfiguration(schema: Schema) -> ModelConfiguration {
        ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.jeanese.Habitra")
        )
    }

    /// Create a local-only ModelConfiguration (default, free tier).
    static func localModelConfiguration(schema: Schema) -> ModelConfiguration {
        ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
    }

    // MARK: - Sync Trigger

    func refreshSync() {
        checkAvailability()
    }
}

// MARK: - Sync Status

enum SyncStatus: String {
    case connected = "Connected"
    case syncing = "Syncing..."
    case upToDate = "Up to Date"
    case noAccount = "No iCloud Account"
    case unavailable = "Unavailable"
    case temporarilyUnavailable = "Temporarily Unavailable"
    case disabled = "Disabled"
    case unknown = "Checking..."

    var icon: String {
        switch self {
        case .connected:           return "icloud.fill"
        case .syncing:             return "arrow.triangle.2.circlepath.icloud.fill"
        case .upToDate:            return "checkmark.icloud.fill"
        case .noAccount:           return "person.crop.circle.badge.questionmark"
        case .unavailable, .temporarilyUnavailable: return "icloud.slash"
        case .disabled:            return "icloud.slash"
        case .unknown:             return "icloud"
        }
    }

    var colorHex: String {
        switch self {
        case .connected:               return "4ADE80"
        case .syncing:                 return "60A5FA"
        case .upToDate:                return "4ADE80"
        case .noAccount, .temporarilyUnavailable: return "FBBF24"
        case .unavailable, .disabled:  return "F87171"
        case .unknown:                 return "7A74B0"
        }
    }
}
