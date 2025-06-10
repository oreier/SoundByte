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
    var Z: Note = Note(note: "0", octave: 0)
    
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
        XCTAssertEqual(currentSongGrader.targetPitches.count, 7)
        XCTAssertEqual(currentSongGrader.historyPitches.count, 7)
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
        XCTAssertEqual(currentSongGrader.targetPitches.count, 7)
        XCTAssertEqual(currentSongGrader.historyPitches.count, 7)
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
        XCTAssertEqual(currentSongGrader.targetPitches.count, 7)
        XCTAssertEqual(currentSongGrader.historyPitches.count, 7)
        XCTAssertEqual(currentSongGrader.currentGrade, 0.0, accuracy: 0.00001)
    }
    
    // Tests that the calculation of cents is correct
    func testCentCalculation() throws {
        currentNotes = [A, B, C, D, E, F, G]
        var historyFreqs = [440.0, 493.92, 523.2, 587.2, 659.2, 698.56, 784.0]
        currentSongGrader.calculateTargetPitches(targetNotes: currentNotes)
        for i in 0..<historyFreqs.count {
            XCTAssertEqual(currentSongGrader.graderCentHelper(historyPitch: historyFreqs[i]), 0.0, accuracy: 0.00001)
            currentSongGrader.targetIndex += 1
        }
        currentSongGrader.targetIndex = 0
        historyFreqs = [493.92, 523.2, 587.2, 659.2, 698.56, 784.0, 880.0]
        let centDiffs = [-200.13, -99.702, -199.79, -200.24, -100.401, -199.76, -199.98]
        for i in 0..<historyFreqs.count {
            XCTAssertEqual(currentSongGrader.graderCentHelper(historyPitch: historyFreqs[i]), centDiffs[i], accuracy: 0.1)
            currentSongGrader.targetIndex += 1
        }
    }
    
    // Tests that intervals are graded correctly
    func testIntervalGrader() throws {
        currentNotes = [A, Z, C, Z]
        let historyFreqs = [440.0, 493.92, 0, 0]
        currentSongGrader.calculateTargetPitches(targetNotes: currentNotes)
        let expectedGrades = [1.0, 0.0, 0.0, 1.0]
        for i in 0..<historyFreqs.count {
            XCTAssertEqual(currentSongGrader.gradeCurrentInterval(historyPitch: historyFreqs[i]), expectedGrades[i], accuracy: 0.1)
            currentSongGrader.targetIndex += 1
        }
    }
}
