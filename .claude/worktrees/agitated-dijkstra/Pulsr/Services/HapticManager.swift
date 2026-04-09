//
//  HapticManager.swift
//  Pulsr
//
//  Created by Jeanese Raymond on 3/31/26.
//

import UIKit
import Foundation

@MainActor
final class HapticManager {
    static let shared = HapticManager()

    private let impactFeedback = UIImpactFeedbackGenerator()
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private init() {}

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let feedback = UIImpactFeedbackGenerator(style: style)
        feedback.impactOccurred()
    }

    func selection() {
        selectionFeedback.selectionChanged()
    }

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationFeedback.notificationOccurred(type)
    }
}
