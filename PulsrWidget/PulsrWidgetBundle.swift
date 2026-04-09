//
//  HabitraWidgetBundle.swift
//  HabitraWidget
//
//  Created by Jeanese Raymond on 3/24/26.
//

import WidgetKit
import SwiftUI

@main
struct HabitraWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitraStreakWidget()
        HabitraHabitGridWidget()
        HabitraProgressBarWidget()
        HabitraLiveActivity()
    }
}
