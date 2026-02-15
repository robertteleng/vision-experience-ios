//
//  VisionExperienceUITestsLaunchTests.swift
//  VisionExperienceUITests
//
//  Created by Roberto Rojo Sahuquillo on 4/8/25.
//

import XCTest

final class VisionExperienceUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
