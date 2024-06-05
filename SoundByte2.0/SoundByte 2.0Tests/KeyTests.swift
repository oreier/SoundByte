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
    
    // tests that when a key without any sharps or flats is initialized, the correct notes are generated
    func testNoteGenerationWithNoSharpsOrFlats() throws {
        // tests key with no sharps or flats
        currentKey = Key(numSharps: 0, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E", "F", "G", "A", "B"])
    }
    
    // tests that when a key with sharps is initialized, the correct notes are generated
    func testNoteGenerationWithSharps() throws {
        // tests key with one sharp
        currentKey = Key(numSharps: 1, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E", "F♯", "G", "A", "B"])
        
        // tests key with two sharps
        currentKey = Key(numSharps: 2, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D", "E", "F♯", "G", "A", "B"])
        
        // tests key with three sharps
        currentKey = Key(numSharps: 3, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D", "E", "F♯", "G♯", "A", "B"])
        
        // tests key with five sharps
        currentKey = Key(numSharps: 5, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D♯", "E", "F♯", "G♯", "A♯", "B"])
        
        // tests key with all seven sharps
        currentKey = Key(numSharps: 7, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D♯", "E♯", "F♯", "G♯", "A♯", "B♯"])
    }
    
    // tests that when a key with flats is initialized, the correct notes are generated
    func testNoteGenerationWithFlats() throws {
        // tests a key with one flat
        currentKey = Key(numFlats: 1, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E", "F", "G", "A", "B♭"])
        
        // tests a key with two flats
        currentKey = Key(numFlats: 2, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E♭", "F", "G", "A", "B♭"])
        
        // tests a key with three flats
        currentKey = Key(numFlats: 3, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E♭", "F", "G", "A♭", "B♭"])
        
        // tests a key with five flats
        currentKey = Key(numFlats: 5, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D♭", "E♭", "F", "G♭", "A♭", "B♭"])
        
        // tests a key with all seven flats
        currentKey = Key(numFlats: 7, isMajor: true)
        notesInKey = currentKey.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♭", "D♭", "E♭", "F♭", "G♭", "A♭", "B♭"])
    }
    
    // tests that the correct center note is set for various types of keys
    func testCorrectCenterNote() throws {
        // tests that the center staff notes are correct for each clef in a key with four sharps
        currentKey = Key(numSharps: 4, isMajor: true)
        centerNoteTreble = currentKey.data.centerNoteTreble
        centerNoteTenorVocal = currentKey.data.centerNoteOctave
        centerNoteBass = currentKey.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B")
        XCTAssertEqual(centerNoteTenorVocal.note, "B")
        XCTAssertEqual(centerNoteBass.note, "D♯")
        
        // tests that the center staff notes are correct for each clef in a key with seven sharps
        currentKey = Key(numSharps: 7, isMajor: true)
        centerNoteTreble = currentKey.data.centerNoteTreble
        centerNoteTenorVocal = currentKey.data.centerNoteOctave
        centerNoteBass = currentKey.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B♯")
        XCTAssertEqual(centerNoteTenorVocal.note, "B♯")
        XCTAssertEqual(centerNoteBass.note, "D♯")
        
        // tests that the center staff notes are correct for each clef in a key with two flats
        currentKey = Key(numFlats: 2, isMajor: true)
        centerNoteTreble = currentKey.data.centerNoteTreble
        centerNoteTenorVocal = currentKey.data.centerNoteOctave
        centerNoteBass = currentKey.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B♭")
        XCTAssertEqual(centerNoteTenorVocal.note, "B♭")
        XCTAssertEqual(centerNoteBass.note, "D")
        
        // tests that the center staff notes are correct for each clef in a key with six flats
        currentKey = Key(numFlats: 6, isMajor: true)
        centerNoteTreble = currentKey.data.centerNoteTreble
        centerNoteTenorVocal = currentKey.data.centerNoteOctave
        centerNoteBass = currentKey.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B♭")
        XCTAssertEqual(centerNoteTenorVocal.note, "B♭")
        XCTAssertEqual(centerNoteBass.note, "D♭")
    }
}
