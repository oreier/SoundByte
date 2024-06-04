//
//  KeyTests.swift
//  SoundByte 2.0Tests
//
//  Created by Jack Durfee on 5/30/24.
//

import XCTest
@testable import SoundByte2_0

final class KeyTests: XCTestCase {

    // variables that will be used for testing
    var currentKey: Key!
    var notesInKey: [String]!
    var centerNoteTreble: (note: String, octave: Int)!
    var centerNoteTenorVocal: (note: String, octave: Int)!
    var centerNoteBass: (note: String, octave: Int)!
    
    // code set up before each test
    override func setUpWithError() throws {
        currentKey = Key()
    }
    
    // code tear down after each test
    override func tearDownWithError() throws {
        currentKey = nil
    }
    
    // tests that the correct errors are thrown when invalid paramters are passed to the constructor
    func testErrorHandling() throws {
        // tests that the correct error is thrown when an invalid note is passed to the constructor
        XCTAssertThrowsError(try Key(note: "#", accidental: "♮", isMajor: true)) { error in
            XCTAssertEqual(error as! KeyInitError, KeyInitError.invalidNote)
        }
        
        // tests that the correct error is thrown when an invalid accidental is passed to the constructor
        XCTAssertThrowsError(try Key(note: "C", accidental: "#", isMajor: true)) { error in
            XCTAssertEqual(error as! KeyInitError, KeyInitError.invalidAccidental)
        }
        
        // tests that the correct error is thrown when an invalid number of sharps are passed to the constructor
        XCTAssertThrowsError(try Key(numSharps: 8, isMajor: true)) { error in
            XCTAssertEqual(error as! KeyInitError, KeyInitError.invalidNumberOfSharps)
        }
        
        // tests that the correct error is thrown when an invalid number of flats are passed to the constructor
        XCTAssertThrowsError(try Key(numFlats: 8, isMajor: true)) { error in
            XCTAssertEqual(error as! KeyInitError, KeyInitError.invalidNumberOfFlats)
        }
    }
    
    // tests that when a key without any sharps or flats is initialized, the correct notes are generated
    func testNoteGenerationWithNoSharpsOrFlats() throws {
        // tests key with no sharps or flats
        currentKey = try Key(numSharps: 0, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E", "F", "G", "A", "B"])
    }
    
    // tests that when a key with sharps is initialized, the correct notes are generated
    func testNoteGenerationWithSharps() throws {
        // tests key with one sharp
        currentKey = try Key(numSharps: 1, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E", "F♯", "G", "A", "B"])
        
        // tests key with two sharps
        currentKey = try Key(numSharps: 2, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D", "E", "F♯", "G", "A", "B"])
        
        // tests key with three sharps
        currentKey = try Key(numSharps: 3, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D", "E", "F♯", "G♯", "A", "B"])
        
        // tests key with five sharps
        currentKey = try Key(numSharps: 5, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D♯", "E", "F♯", "G♯", "A♯", "B"])
        
        // tests key with all seven sharps
        currentKey = try Key(numSharps: 7, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D♯", "E♯", "F♯", "G♯", "A♯", "B♯"])
    }
    
    // tests that when a key with flats is initialized, the correct notes are generated
    func testNoteGenerationWithFlats() throws {
        // tests a key with one flat
        currentKey = try Key(numFlats: 1, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E", "F", "G", "A", "B♭"])
        
        // tests a key with two flats
        currentKey = try Key(numFlats: 2, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E♭", "F", "G", "A", "B♭"])
        
        // tests a key with three flats
        currentKey = try Key(numFlats: 3, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E♭", "F", "G", "A♭", "B♭"])
        
        // tests a key with five flats
        currentKey = try Key(numFlats: 5, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D♭", "E♭", "F", "G♭", "A♭", "B♭"])
        
        // tests a key with all seven flats
        currentKey = try Key(numFlats: 7, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♭", "D♭", "E♭", "F♭", "G♭", "A♭", "B♭"])
    }
    
    // tests that the correct center note is set for various types of keys
    func testCorrectCenterNote() throws {
        // tests that the center staff notes are correct for each clef in a key with four sharps
        currentKey = try Key(numSharps: 4, isMajor: true)
        centerNoteTreble = currentKey.data.centerNoteTreble
        centerNoteTenorVocal = currentKey.data.centerNoteTenorVocal
        centerNoteBass = currentKey.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B")
        XCTAssertEqual(centerNoteTenorVocal.note, "B")
        XCTAssertEqual(centerNoteBass.note, "D♯")
        
        // tests that the center staff notes are correct for each clef in a key with seven sharps
        currentKey = try Key(numSharps: 7, isMajor: true)
        centerNoteTreble = currentKey.data.centerNoteTreble
        centerNoteTenorVocal = currentKey.data.centerNoteTenorVocal
        centerNoteBass = currentKey.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B♯")
        XCTAssertEqual(centerNoteTenorVocal.note, "B♯")
        XCTAssertEqual(centerNoteBass.note, "D♯")
        
        // tests that the center staff notes are correct for each clef in a key with two flats
        currentKey = try Key(numFlats: 2, isMajor: true)
        centerNoteTreble = currentKey.data.centerNoteTreble
        centerNoteTenorVocal = currentKey.data.centerNoteTenorVocal
        centerNoteBass = currentKey.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B♭")
        XCTAssertEqual(centerNoteTenorVocal.note, "B♭")
        XCTAssertEqual(centerNoteBass.note, "D")
        
        // tests that the center staff notes are correct for each clef in a key with six flats
        currentKey = try Key(numFlats: 6, isMajor: true)
        centerNoteTreble = currentKey.data.centerNoteTreble
        centerNoteTenorVocal = currentKey.data.centerNoteTenorVocal
        centerNoteBass = currentKey.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B♭")
        XCTAssertEqual(centerNoteTenorVocal.note, "B♭")
        XCTAssertEqual(centerNoteBass.note, "D♭")
    }
}
