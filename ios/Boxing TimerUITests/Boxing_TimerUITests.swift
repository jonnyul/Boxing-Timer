import XCTest

final class Boxing_TimerUITests: XCTestCase {

    @MainActor
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()

        // 1 — Home / Timer screen
        snapshot("01_Home")

        // 2 — Navigate to Presets tab
        let presetsTab = app.tabBars.buttons["Presets"]
        if presetsTab.exists {
            presetsTab.tap()
            snapshot("02_Presets")
        }

        // 3 — Navigate to Stats tab
        let statsTab = app.tabBars.buttons["Stats"]
        if statsTab.exists {
            statsTab.tap()
            snapshot("03_Stats")
        }

        // 4 — Navigate to Options tab
        let optionsTab = app.tabBars.buttons["Options"]
        if optionsTab.exists {
            optionsTab.tap()
            snapshot("04_Options")
        }
    }
}
