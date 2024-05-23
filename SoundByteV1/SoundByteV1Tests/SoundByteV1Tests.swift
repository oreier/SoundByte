//
//  SoundByteV1Tests.swift
//  SoundByteV1Tests
//
//  Created by Delaney Lim (Student) on 5/15/24.
//

import XCTest
@testable import SoundByteV1

final class SoundByteV1Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // PitchVisualizer.swift
    //###########################################################
    // Test that Pitch Visualizer is set up correctly
    func testInitialState() {
        XCTAssertEqual(true,false)
    }
    // Test the SetUp function
    func testSetUP() {
        XCTAssertEqual(true,false)
    }
    // Test the updateGraphNoteAxis function
    func testUpdateGraphNoteAxis() {
        XCTAssertEqual(true,false)
    }
    // Test the calculatePosition function
    func testCalculatePosition() {
        // Mock data
        var pitchVisualizer = PitchVisualizer()
        // call calculatePosition
        // calculate expected values
        // Assert whether function is working properly
        XCTAssertEqual(true,false)
    }
    // Test the updateHistory function
    func testUpdateHistory() {
        XCTAssertEqual(true,false)
    }
    // Test the resetHistory function
    func testResetHistory() {
        XCTAssertEqual(true,false)
    }
    // Test the centsOff function
    func testCentsOff() {
        XCTAssertEqual(true,false)
    }
    // Test the calculateColor function
    func testCalculateColor() {
        XCTAssertEqual(true,false)
    }
    // Test the UIColor extension
    func testUIColor () {
        XCTAssertEqual(true,false)
    }
    
}
