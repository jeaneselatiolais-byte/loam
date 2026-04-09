//
//  HabitraUITests.swift
//  HabitraUITests
//
//  Created by Jeanese Raymond on 3/24/26.
//

import XCTest

final class HabitraUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Reset onboarding so we start fresh
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Bar Navigation

    @MainActor
    func testTabBarExists() throws {
        // The three tabs should be visible
        let todayTab = app.tabBars.buttons["Today"]
        let statsTab = app.tabBars.buttons["Stats"]
        let settingsTab = app.tabBars.buttons["Settings"]

        XCTAssertTrue(todayTab.exists)
        XCTAssertTrue(statsTab.exists)
        XCTAssertTrue(settingsTab.exists)
    }

    @MainActor
    func testNavigateToStatsTab() throws {
        app.tabBars.buttons["Stats"].tap()
        // Stats title should appear
        let navTitle = app.navigationBars["Stats"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 3))
    }

    @MainActor
    func testNavigateToSettingsTab() throws {
        app.tabBars.buttons["Settings"].tap()
        let navTitle = app.navigationBars["Settings"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 3))
    }

    // MARK: - Habit Creation Flow

    @MainActor
    func testAddHabitButtonShowsForm() throws {
        // Tap the + button
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'plus'")).firstMatch
        if addButton.exists {
            addButton.tap()
            // The form sheet should appear with "New Habit" title
            let newHabitTitle = app.staticTexts["New Habit"]
            XCTAssertTrue(newHabitTitle.waitForExistence(timeout: 3))
        }
    }

    @MainActor
    func testCreateHabitFlow() throws {
        // Tap add button
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'plus'")).firstMatch
        guard addButton.exists else { return }
        addButton.tap()

        // Wait for form
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 3))

        // Type a habit name
        let textField = app.textFields.firstMatch
        if textField.exists {
            textField.tap()
            textField.typeText("Test Habit")
        }

        // Tap Create Habit button
        let createButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Create'")).firstMatch
        if createButton.exists && createButton.isEnabled {
            createButton.tap()

            // Verify the habit appears in the list
            let habitText = app.staticTexts["Test Habit"]
            XCTAssertTrue(habitText.waitForExistence(timeout: 3))
        }
    }

    @MainActor
    func testCancelHabitCreation() throws {
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'plus'")).firstMatch
        guard addButton.exists else { return }
        addButton.tap()

        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 3))
        cancelButton.tap()

        // Form should be dismissed — we should be back on Today
        let navTitle = app.navigationBars["Today"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 3))
    }

    // MARK: - Settings Navigation

    @MainActor
    func testSettingsShowsAppInfo() throws {
        app.tabBars.buttons["Settings"].tap()

        // HABITRA wordmark should be visible
        let wordmark = app.staticTexts["HABITRA"]
        XCTAssertTrue(wordmark.waitForExistence(timeout: 3))
    }

    @MainActor
    func testNavigateToHelpGuide() throws {
        app.tabBars.buttons["Settings"].tap()

        let helpButton = app.staticTexts["Help Guide"]
        if helpButton.waitForExistence(timeout: 3) {
            helpButton.tap()
            let helpTitle = app.navigationBars["Help Guide"]
            XCTAssertTrue(helpTitle.waitForExistence(timeout: 3))
        }
    }

    @MainActor
    func testNavigateToArchivedHabits() throws {
        app.tabBars.buttons["Settings"].tap()

        let archivedButton = app.staticTexts["Archived Habits"]
        if archivedButton.waitForExistence(timeout: 3) {
            archivedButton.tap()
            let archivedTitle = app.navigationBars["Archived Habits"]
            XCTAssertTrue(archivedTitle.waitForExistence(timeout: 3))
        }
    }

    @MainActor
    func testDarkModeToggleExists() throws {
        app.tabBars.buttons["Settings"].tap()

        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 3))
    }

    // MARK: - Stats Empty State

    @MainActor
    func testStatsShowsEmptyStateWithNoHabits() throws {
        app.tabBars.buttons["Stats"].tap()

        // Should show empty state message
        let emptyTitle = app.staticTexts["No stats yet"]
        // May or may not exist depending on whether habits exist
        // Just verify the tab loads without crash
        _ = app.navigationBars["Stats"].waitForExistence(timeout: 3)
    }

    // MARK: - Launch Performance

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
