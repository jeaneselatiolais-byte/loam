//
//  DayProgressHeader.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI

struct DayProgressHeader: View {
    let progress: Double
    let completedCount: Int
    let totalCount: Int
    var level: Int = 1
    var xpProgress: Double = 0
    var todayXP: Int = 0

    private var dateString: String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: HabitraTheme.spacingLarge) {
                // Progress Ring
                ZStack {
                    ProgressRing(progress: progress, lineWidth: 8, size: 80)

                    VStack(spacing: 2) {
                        Text("\(Int(progress * 100))")
                            .font(HabitraFont.title())
                            .foregroundStyle(Color.habitraTextPrimary)
                        Text("%")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(dateString)
                        .habitraCaption(color: .habitraTextTertiary)
                        .sectionHeaderAccessibility()

                    Text("\(completedCount) of \(totalCount)")
                        .font(HabitraFont.title())
                        .foregroundStyle(isAllDone ? Color.habitraVital : Color.habitraTextPrimary)
                        .animation(.easeOut(duration: 0.4), value: isAllDone)

                    Text(statusMessage)
                        .font(HabitraFont.body())
                        .foregroundStyle(isAllDone ? Color.habitraVital.opacity(0.8) : Color.habitraTextSecondary)
                        .animation(.easeOut(duration: 0.4), value: isAllDone)
                }

                Spacer()
            }
            .padding(HabitraTheme.cardPadding)
            .padding(.horizontal, 4)

            // XP Bar
            VStack(spacing: 6) {
                HStack {
                    Text("Lv. \(level)")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.habitraAccent.opacity(0.12))
                        .clipShape(Capsule())

                    Spacer()

                    if todayXP > 0 {
                        Text("+\(todayXP) XP today")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraVital)
                    }
                }

                // Thin XP progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color.habitraSurfaceLight)
                            .frame(height: 3)

                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(
                                LinearGradient(
                                    colors: [Color.habitraAccent, Color.habitraVital],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geo.size.width * xpProgress), height: 3)
                            .animation(.easeOut(duration: 0.5), value: xpProgress)
                    }
                }
                .frame(height: 3)
            }
            .padding(.horizontal, HabitraTheme.cardPadding + 4)
            .padding(.bottom, HabitraTheme.cardPadding)
        }
        .habitraCard()
        .padding(.horizontal, HabitraTheme.screenPadding)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today's progress: \(completedCount) of \(totalCount) habits completed, \(Int(progress * 100)) percent. Level \(level), plus \(todayXP) XP today")
    }

    private var isAllDone: Bool {
        totalCount > 0 && completedCount == totalCount
    }

    private var statusMessage: String {
        if totalCount == 0 {
            return "No habits scheduled"
        } else if completedCount == totalCount {
            return "All done! Great work. 🔥"
        } else if completedCount == 0 {
            return "Let's get started."
        } else {
            return "Keep going!"
        }
    }
}

#Preview {
    ZStack {
        Color.habitraBackground.ignoresSafeArea()
        DayProgressHeader(
            progress: 0.6,
            completedCount: 3,
            totalCount: 5,
            level: 7,
            xpProgress: 0.65,
            todayXP: 85
        )
    }
}
