//
//  VisionExperienceUITests.swift
//  VisionExperienceUITests
//
//  Created by Roberto Rojo Sahuquillo on 4/8/25.
//

import XCTest

final class VisionExperienceUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
