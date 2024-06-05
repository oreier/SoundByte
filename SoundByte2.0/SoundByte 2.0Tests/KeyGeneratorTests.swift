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
    var currentKeyGenerator: KeyGenerator!
    var notesInKey: [String]!
    var centerNoteTreble: Note!
    var centerNoteTenorVocal: Note!
    var centerNoteBass: Note!
    
    // code set up before each test
    override func setUpWithError() throws {
        currentKeyGenerator = KeyGenerator()
    }
    
    // code tear down after each test
    override func tearDownWithError() throws {
        currentKeyGenerator = nil
    }
    
    // tests that when a key without any sharps or flats is initialized, the correct notes are generated
    func testNoteGenerationWithNoSharpsOrFlats() throws {
        // tests key with no sharps or flats
        currentKeyGenerator = KeyGenerator(numSharps: 0, isMajor: true)
        notesInKey = currentKeyGenerator.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E", "F", "G", "A", "B"])
    }
    
    // tests that when a key with sharps is initialized, the correct notes are generated
    func testNoteGenerationWithSharps() throws {
        // tests key with one sharp
        currentKeyGenerator = KeyGenerator(numSharps: 1, isMajor: true)
        notesInKey = currentKeyGenerator.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E", "F♯", "G", "A", "B"])
        
        // tests key with two sharps
        currentKeyGenerator = KeyGenerator(numSharps: 2, isMajor: true)
        notesInKey = currentKeyGenerator.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D", "E", "F♯", "G", "A", "B"])
        
        // tests key with three sharps
        currentKeyGenerator = KeyGenerator(numSharps: 3, isMajor: true)
        notesInKey = currentKeyGenerator.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D", "E", "F♯", "G♯", "A", "B"])
        
        // tests key with five sharps
        currentKeyGenerator = KeyGenerator(numSharps: 5, isMajor: true)
        notesInKey = currentKeyGenerator.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D♯", "E", "F♯", "G♯", "A♯", "B"])
        
        // tests key with all seven sharps
        currentKeyGenerator = KeyGenerator(numSharps: 7, isMajor: true)
        notesInKey = currentKeyGenerator.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♯", "D♯", "E♯", "F♯", "G♯", "A♯", "B♯"])
    }
    
    // tests that when a key with flats is initialized, the correct notes are generated
    func testNoteGenerationWithFlats() throws {
        // tests a key with one flat
        currentKeyGenerator = KeyGenerator(numFlats: 1, isMajor: true)
        notesInKey = currentKeyGenerator.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E", "F", "G", "A", "B♭"])
        
        // tests a key with two flats
        currentKeyGenerator = KeyGenerator(numFlats: 2, isMajor: true)
        notesInKey = currentKeyGenerator.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E♭", "F", "G", "A", "B♭"])
        
        // tests a key with three flats
        currentKeyGenerator = KeyGenerator(numFlats: 3, isMajor: true)
        notesInKey = currentKeyGenerator.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D", "E♭", "F", "G", "A♭", "B♭"])
        
        // tests a key with five flats
        currentKeyGenerator = KeyGenerator(numFlats: 5, isMajor: true)
        notesInKey = currentKeyGenerator.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C", "D♭", "E♭", "F", "G♭", "A♭", "B♭"])
        
        // tests a key with all seven flats
        currentKeyGenerator = KeyGenerator(numFlats: 7, isMajor: true)
        notesInKey = currentKeyGenerator.data.notes
        XCTAssertEqual(notesInKey.count, 7)
        XCTAssertEqual(notesInKey, ["C♭", "D♭", "E♭", "F♭", "G♭", "A♭", "B♭"])
    }
    
    // tests that the correct center note is set for various types of keys
    func testCorrectCenterNote() throws {
        // tests that the center staff notes are correct for each clef in a key with four sharps
        currentKeyGenerator = KeyGenerator(numSharps: 4, isMajor: true)
        centerNoteTreble = currentKeyGenerator.data.centerNoteTreble
        centerNoteTenorVocal = currentKeyGenerator.data.centerNoteOctave
        centerNoteBass = currentKeyGenerator.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B")
        XCTAssertEqual(centerNoteTenorVocal.note, "B")
        XCTAssertEqual(centerNoteBass.note, "D♯")
        
        // tests that the center staff notes are correct for each clef in a key with seven sharps
        currentKeyGenerator = KeyGenerator(numSharps: 7, isMajor: true)
        centerNoteTreble = currentKeyGenerator.data.centerNoteTreble
        centerNoteTenorVocal = currentKeyGenerator.data.centerNoteOctave
        centerNoteBass = currentKeyGenerator.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B♯")
        XCTAssertEqual(centerNoteTenorVocal.note, "B♯")
        XCTAssertEqual(centerNoteBass.note, "D♯")
        
        // tests that the center staff notes are correct for each clef in a key with two flats
        currentKeyGenerator = KeyGenerator(numFlats: 2, isMajor: true)
        centerNoteTreble = currentKeyGenerator.data.centerNoteTreble
        centerNoteTenorVocal = currentKeyGenerator.data.centerNoteOctave
        centerNoteBass = currentKeyGenerator.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B♭")
        XCTAssertEqual(centerNoteTenorVocal.note, "B♭")
        XCTAssertEqual(centerNoteBass.note, "D")
        
        // tests that the center staff notes are correct for each clef in a key with six flats
        currentKeyGenerator = KeyGenerator(numFlats: 6, isMajor: true)
        centerNoteTreble = currentKeyGenerator.data.centerNoteTreble
        centerNoteTenorVocal = currentKeyGenerator.data.centerNoteOctave
        centerNoteBass = currentKeyGenerator.data.centerNoteBass
        XCTAssertEqual(centerNoteTreble.note, "B♭")
        XCTAssertEqual(centerNoteTenorVocal.note, "B♭")
        XCTAssertEqual(centerNoteBass.note, "D♭")
    }
}
