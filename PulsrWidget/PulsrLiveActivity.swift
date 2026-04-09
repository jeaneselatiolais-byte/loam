//
//  HabitraLiveActivity.swift
//  HabitraWidget
//
//  Live Activity UI for habit timer sessions.
//  Shows on the Lock Screen and Dynamic Island.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HabitraLiveActivity: Widget {
    let kind = "HabitraLiveActivity"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HabitTimerAttributes.self) { context in
            // Lock Screen / banner presentation
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded regions
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.habitIcon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color(hex: context.attributes.habitColorHex))
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text(context.attributes.habitName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)

                        Text(formatTime(context.state.elapsedSeconds))
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: context.attributes.habitColorHex))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    timerProgress(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(
                        value: min(Double(context.state.elapsedSeconds) / Double(context.attributes.targetMinutes * 60), 1.0)
                    )
                    .tint(Color(hex: context.attributes.habitColorHex))
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: context.attributes.habitIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: context.attributes.habitColorHex))
            } compactTrailing: {
                Text(formatTimeCompact(context.state.elapsedSeconds))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: context.attributes.habitColorHex))
            } minimal: {
                Image(systemName: context.attributes.habitIcon)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: context.attributes.habitColorHex))
            }
        }
    }

    // MARK: - Lock Screen View

    private func lockScreenView(context: ActivityViewContext<HabitTimerAttributes>) -> some View {
        let color = Color(hex: context.attributes.habitColorHex)

        return HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: context.attributes.habitIcon)
                    .font(.system(size: 22))
                    .foregroundStyle(color)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.habitName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                Text(context.state.isCompleted ? "Completed!" : "In progress...")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            // Timer
            VStack(spacing: 4) {
                Text(formatTime(context.state.elapsedSeconds))
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)

                Text("/ \(context.attributes.targetMinutes)m")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(16)
        .background(Color(hex: "0D0D14"))
    }

    // MARK: - Progress Circle

    private func timerProgress(context: ActivityViewContext<HabitTimerAttributes>) -> some View {
        let progress = min(Double(context.state.elapsedSeconds) / Double(context.attributes.targetMinutes * 60), 1.0)
        let color = Color(hex: context.attributes.habitColorHex)

        return ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 36, height: 36)
    }

    // MARK: - Time Formatting

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func formatTimeCompact(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
