//
//  NotesToGraphMapperTests.swift
//  SoundByte 2.0Tests
//
//  Created by Jack Durfee on 5/30/24.
//

import XCTest
@testable import SoundByte2_0

final class NotesToGraphMapperTests: XCTestCase {
    
    // variables that will be used for testing
    var currentMapper: NotesToGraphMapper!
    
    // code set up before each test
    override func setUpWithError() throws {
        currentMapper = NotesToGraphMapper()
    }

    // code tear down after each test
    override func tearDownWithError() throws {
        currentMapper = nil
    }

    // tests that different errors are thrown by the mapper when invalid notes are inputted to the function
    func testErrorHandlingOnNotes() throws {
        // test error handling when note is not set
        currentMapper.centerNote = ("", 0)
        currentMapper.notesInKey = ["C", "D", "E", "F", "G", "A", "B"]
        XCTAssertThrowsError(try currentMapper.checkForErrors()) { error in
            XCTAssertEqual(error as! NotesToGraphMapperInitError, NotesToGraphMapperInitError.centerNoteNotSet)
        }
        
        // test error handling when note is invalid
        currentMapper.centerNote = ("#", 0)
        currentMapper.notesInKey = ["C", "D", "E", "F", "G", "A", "B"]
        XCTAssertThrowsError(try currentMapper.checkForErrors()) { error in
            XCTAssertEqual(error as! NotesToGraphMapperInitError, NotesToGraphMapperInitError.invalidCenterNote)
        }
        
        // test error handling when octave is invalid
        currentMapper.centerNote = ("C", -1)
        currentMapper.notesInKey = ["C", "D", "E", "F", "G", "A", "B"]
        XCTAssertThrowsError(try currentMapper.checkForErrors()) { error in
            XCTAssertEqual(error as! NotesToGraphMapperInitError, NotesToGraphMapperInitError.invalidCenterNote)
        }
    }
    
    // tests that different errors are thrown by the mapper when invalid notes in key arrays are inputted to the function
    func testErrorHandingOnNotesInKeyArrays() throws {        
        // test error ahnding when array is not set
        currentMapper.centerNote = ("C", 0)
        XCTAssertThrowsError(try currentMapper.checkForErrors()) { error in
            XCTAssertEqual(error as! NotesToGraphMapperInitError, NotesToGraphMapperInitError.notesInKeyNotSet)

        }
        
        // test error handing when there aren't enough parameters in the notes in key array
        currentMapper.centerNote = ("C", 0)
        currentMapper.notesInKey = ["C", "D", "E", "F"]
        XCTAssertThrowsError(try currentMapper.checkForErrors()) { error in
            XCTAssertEqual(error as! NotesToGraphMapperInitError, NotesToGraphMapperInitError.invalidNotesInKey)

        }
        
        // test error handing when the notes in the array are invalid
        currentMapper.centerNote = ("C", 0)
        currentMapper.notesInKey = ["C", "D", "E", "F", "G", "A", "#"]
        XCTAssertThrowsError(try currentMapper.checkForErrors()) { error in
            XCTAssertEqual(error as! NotesToGraphMapperInitError, NotesToGraphMapperInitError.invalidNotesInKey)

        }
    }
    
    // tests that the helper function that calculates frequencies is correct
    func testCorrectFrequencyCalculation() throws {
        XCTAssertTrue(areAlmostEqual(currentMapper.calculateFreqency(of: ("C♭", 3)), 246.94))
        XCTAssertTrue(areAlmostEqual(currentMapper.calculateFreqency(of: ("C", 4)), 261.63))
        XCTAssertTrue(areAlmostEqual(currentMapper.calculateFreqency(of: ("C♯", 4)), 277.18))
    }

    // tests that the mapping of notes to positions is correct when there are three notes
    func testCorrectMappingForThreeNotes() throws {
        // sets paramters for mapping
        currentMapper.centerNote = ("A", 4)
        currentMapper.centerNotePosition = 0
        currentMapper.notesInKey = ["C", "D", "E", "F", "G", "A", "B"]
        currentMapper.numNotes = 3
        currentMapper.spacing = 10
        
        // map notes to positions
        let mapping = currentMapper.mapNotes()
        
        // array with keys sorted from lowest frequency to highest
        let keys = Array(mapping.keys).sorted()

        // enusres that the mapping has the correct number of values
        XCTAssertEqual(mapping.count, 3)
        
        // ensures that the mapping was done correctly
        if keys.count == 3 {
            XCTAssertTrue(areAlmostEqual(mapping[keys[0]]!, 10))
            XCTAssertTrue(areAlmostEqual(mapping[keys[1]]!, 0))
            XCTAssertTrue(areAlmostEqual(mapping[keys[2]]!, -10))
        }
    }
    
    // tests that the mapping of notes to positions is correct when there are seven notes
    func testCorrectMappingForSevenNotes() throws {
        // sets paramters for mapping
        currentMapper.centerNote = ("A", 4)
        currentMapper.centerNotePosition = 0
        currentMapper.notesInKey = ["C", "D", "E", "F", "G", "A", "B"]
        currentMapper.numNotes = 7
        currentMapper.spacing = 5
        
        // map notes to positions
        let mapping = currentMapper.mapNotes()
        
        // array with keys sorted from lowest frequency to highest
        let keys = Array(mapping.keys).sorted()

        // enusres that the mapping has the correct number of values
        XCTAssertEqual(mapping.count, 7)
        
        // ensures that the mapping was done correctly
        if keys.count == 7 {
            XCTAssertTrue(areAlmostEqual(mapping[keys[0]]!, 15))
            XCTAssertTrue(areAlmostEqual(mapping[keys[1]]!, 10))
            XCTAssertTrue(areAlmostEqual(mapping[keys[2]]!, 5))
            XCTAssertTrue(areAlmostEqual(mapping[keys[3]]!, 0))
            XCTAssertTrue(areAlmostEqual(mapping[keys[4]]!, -5))
            XCTAssertTrue(areAlmostEqual(mapping[keys[5]]!, -10))
            XCTAssertTrue(areAlmostEqual(mapping[keys[6]]!, -15))
        }
    }
}

// helper function to compare doubles
func areAlmostEqual(_ a: Double, _ b: Double, tolerance: Double = 1) -> Bool {
    return abs(a - b) < tolerance
}
