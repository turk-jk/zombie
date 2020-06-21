//
//  zombieUITests.swift
//  zombieUITests
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import XCTest

class zombieUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    /// Launch the app with no levelOfPain and check workflow
    func test_without_levelOfPain() {
        
        let app = XCUIApplication()
        app.launchArguments += [st.UI_Testing.s]
        app.launchEnvironment[st.hasLevelOfPain.s] = "NO"
        app.launch()
        
        // check if the view is select illness table view
        let Select_illness = app.navigationBars["Select an illness"]
         XCTAssertTrue(Select_illness.exists)
        
        let tablesQuery = XCUIApplication().tables
        
        // check that table has more than 0 cells
        let cellCount = tablesQuery.cells.count
        XCTAssertTrue(cellCount > 0)
        
        

        // tap on first cell
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        firstCell.tap()
        
        
        
        let buttons = tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"Select severity Level:")/*[[".cells.containing(.staticText, identifier:\"Mortal Cold\")",".cells.containing(.staticText, identifier:\"Select severity Level:\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .button)
        
        // Check that cell has 5 buttons for `severity level`
        XCTAssertEqual(buttons.allElementsBoundByIndex.count, 5)
        
        // Check that cell has all 5 buttons for `severity level`
        XCTAssertTrue(buttons.element(matching: .button, identifier: "boring 40").exists)
        XCTAssertTrue(buttons.element(matching: .button, identifier: "pain 40").exists)
        XCTAssertTrue(buttons.element(matching: .button, identifier: "sad 40").exists)
        XCTAssertTrue(buttons.element(matching: .button, identifier: "tired 40").exists)
        XCTAssertTrue(buttons.element(matching: .button, identifier: "happy 40").exists)
        
        // tap on pain button
        tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"Select severity Level:")/*[[".cells.containing(.staticText, identifier:\"Mortal Cold\")",".cells.containing(.staticText, identifier:\"Select severity Level:\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["pain 40"].tap()

        
        // check if the view is Our suggested Hospitals table view
        let Our_suggested_Hospitals = app.navigationBars["Our suggested Hospitals"]
         XCTAssertTrue(Our_suggested_Hospitals.exists)
        
        let tablesQuery2 = XCUIApplication().tables
        let cellCount2 = tablesQuery2.cells.count
        XCTAssertTrue(cellCount2 > 0)
        
        // check map is closed
        let map = XCUIApplication().maps.allElementsBoundByIndex.first
        XCTAssertNil(map)

        // open map
        XCUIApplication().navigationBars["Our suggested Hospitals"].buttons["icons8 marker 29"].tap()
        
        // check map is exists
        let map_after_open = XCUIApplication().maps.allElementsBoundByIndex.first
        XCTAssertNotNil(map_after_open)
        
        // check map size
        let size = map_after_open?.frame.size
        let h = size?.height ?? 0
        let w = size?.width ?? 0
        XCTAssertTrue(h > 0)
        XCTAssertTrue(w > 0)
         
        
        
    }
    
    /// Launch the app with  levelOfPain and check if view is the `Our suggested Hospitals table view`
    func test_with_levelOfPain() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments += [st.UI_Testing.s]
        app.launchEnvironment[st.hasLevelOfPain.s] = "YES"
        app.launch()
        
        let Our_suggested_Hospitals = app.navigationBars["Our suggested Hospitals"]
         XCTAssertTrue(Our_suggested_Hospitals.exists)
        
                
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
