//
//  SongGraderTests.swift
//  SoundByte2.0
//
//  Created by Kieran Yanaway (Student) on 6/8/25.
//

import XCTest
@testable import SoundByte2_0

final class graderTests: XCTestCase {
    var currentSongGrader: SongGrader!
    var currentNotes: [Note]!
    var currentHistory: [Double]!
    var A: Note = Note(note: "A", octave: 4)
    var B: Note = Note(note: "B", octave: 4)
    var C: Note = Note(note: "C", octave: 5)
    var D: Note = Note(note: "D", octave: 5)
    var E: Note = Note(note: "E", octave: 5)
    var F: Note = Note(note: "F", octave: 5)
    var G: Note = Note(note: "G", octave: 5)
    
    override func setUpWithError() throws {
        currentSongGrader = SongGrader()
    }
    
    override func tearDownWithError() throws {
        currentSongGrader = nil
    }
    
    // Tests that the grader can convert Note objects to target frequencies correctly
    func testTargetPitchCalculation() throws {
        currentNotes = [A, B, C, D, E, F, G]
        let noteFreqs = [440.0, 493.92, 523.2, 587.2, 659.2, 698.56, 784.0]
        currentSongGrader.calculateTargetPitches(targetNotes: currentNotes)
        for i in 0..<currentSongGrader.targetPitches.count {
            XCTAssertEqual(currentSongGrader.targetPitches[i], noteFreqs[i], accuracy: 0.01)
        }
    }
    
    // Tests that the grader can successfully recognize when all notes are correct
    func testAllCorrectGrading() throws {
        currentNotes = [A, B, C, D, E, F, G]
        let historyFreqs = [440.0, 493.92, 523.2, 587.2, 659.2, 698.56, 784.0]
        currentSongGrader.calculateTargetPitches(targetNotes: currentNotes)
        for i in 0..<currentNotes.count {
            currentSongGrader.updateGrading(currentPitch: historyFreqs[i])
        }
        XCTAssertEqual(currentSongGrader.currentGrade, 100.0, accuracy: 0.00001)
    }
    
    // Tests that the grader can successfully recognize when some notes are correct
    func testSomeCorrectGrading() throws {
        currentNotes = [A, B, C, D, E, F, G]
        let historyFreqs = [440.0, 90000.0, 523.2, 587.2, 2.0, 42.0, 784.0]
        currentSongGrader.calculateTargetPitches(targetNotes: currentNotes)
        for i in 0..<currentNotes.count {
            currentSongGrader.updateGrading(currentPitch: historyFreqs[i])
        }
        XCTAssertEqual(currentSongGrader.currentGrade, 100.0*4.0/7.0, accuracy: 0.00001)
    }
    
    // Tests that the grader can successfully recognize when no notes are correct
    func testNoneCorrectGrading() throws {
        currentNotes = [A, B, C, D, E, F, G]
        let historyFreqs = [8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0]
        currentSongGrader.calculateTargetPitches(targetNotes: currentNotes)
        for i in 0..<currentNotes.count {
            currentSongGrader.updateGrading(currentPitch: historyFreqs[i])
        }
        XCTAssertEqual(currentSongGrader.currentGrade, 0.0, accuracy: 0.00001)
    }
    
    // Tests that the song grader calculates cent difference correctly
    func testCentCalculation() throws {
        XCTAssertEqual(currentSongGrader.graderCentHelper(historyPitch: 493.92, targetPitch: 440.0), 200.1286, accuracy: 0.0001)
        XCTAssertEqual(currentSongGrader.graderCentHelper(historyPitch: 784.0, targetPitch: 440.0), 1000.02015, accuracy: 0.0001)
        XCTAssertEqual(currentSongGrader.graderCentHelper(historyPitch: 493.92, targetPitch: 698.56), -600.12798, accuracy: 0.0001)
    }
}
