//
//  DataExportService.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import Foundation

/// CSV export service for habit data.
/// Supports two modes: a habits summary and a per-completion detail export.
enum DataExportService {

    // MARK: - Export Mode

    enum ExportMode {
        case habitsSummary
        case completionsDetail
    }

    // MARK: - Date Formatters

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private static let isoDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let timestampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    // MARK: - Public API

    /// Generates a CSV file for the given habits and returns a temporary file URL.
    /// - Parameters:
    ///   - habits: The habits to export.
    ///   - mode: Whether to export a summary or detailed completions.
    /// - Returns: A file URL pointing to the generated CSV in the temporary directory.
    static func generateCSV(habits: [Habit], mode: ExportMode) throws -> URL {
        let csvString: String

        switch mode {
        case .habitsSummary:
            csvString = buildHabitsSummaryCSV(habits: habits)
        case .completionsDetail:
            csvString = buildCompletionsDetailCSV(habits: habits)
        }

        let fileName: String
        let dateSuffix = isoDateFormatter.string(from: Date())

        switch mode {
        case .habitsSummary:
            fileName = "Habitra_Habits_Summary_\(dateSuffix).csv"
        case .completionsDetail:
            fileName = "Habitra_Completions_\(dateSuffix).csv"
        }

        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    // MARK: - Habits Summary

    private static func buildHabitsSummaryCSV(habits: [Habit]) -> String {
        var rows: [String] = []

        // Header
        rows.append(csvRow([
            "Habit Name",
            "Frequency",
            "Current Streak",
            "Longest Streak",
            "Total Completions",
            "Created Date",
            "Archived"
        ]))

        // Data rows sorted by creation date
        let sorted = habits.sorted { $0.createdAt < $1.createdAt }

        for habit in sorted {
            rows.append(csvRow([
                habit.name,
                habit.frequencyType,
                "\(habit.currentStreak)",
                "\(habit.longestStreak)",
                "\(habit.completions.count)",
                dateFormatter.string(from: habit.createdAt),
                habit.isArchived ? "Yes" : "No"
            ]))
        }

        return rows.joined(separator: "\n")
    }

    // MARK: - Completions Detail

    private static func buildCompletionsDetailCSV(habits: [Habit]) -> String {
        var rows: [String] = []

        // Header
        rows.append(csvRow([
            "Habit Name",
            "Completion Date",
            "Completion Timestamp",
            "Note"
        ]))

        // Gather all completions across habits, sorted by timestamp
        var entries: [(habitName: String, completedDate: Date, completedAt: Date, note: String)] = []

        for habit in habits {
            for completion in habit.completions {
                entries.append((
                    habitName: habit.name,
                    completedDate: completion.completedDate,
                    completedAt: completion.completedAt,
                    note: completion.note ?? ""
                ))
            }
        }

        entries.sort { $0.completedAt < $1.completedAt }

        for entry in entries {
            rows.append(csvRow([
                entry.habitName,
                isoDateFormatter.string(from: entry.completedDate),
                timestampFormatter.string(from: entry.completedAt),
                entry.note
            ]))
        }

        return rows.joined(separator: "\n")
    }

    // MARK: - CSV Helpers

    /// Escapes a field for CSV: wraps in double-quotes if it contains commas,
    /// double-quotes, or newlines, and escapes internal double-quotes.
    private static func escapeField(_ field: String) -> String {
        let needsQuoting = field.contains(",") || field.contains("\"") || field.contains("\n")
        if needsQuoting {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }

    /// Joins an array of fields into a single CSV row string.
    private static func csvRow(_ fields: [String]) -> String {
        fields.map { escapeField($0) }.joined(separator: ",")
    }
}
