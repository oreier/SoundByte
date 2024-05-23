//
//  Converter.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/21/24.
//

import Foundation

/*
 creates a mapping from a single note to a range of notes evenly
 spaced apart in bounds given by the caller
 */
class FreqGraphMapper {
    // class variables
    private let NOTES_ARR: [String]      = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private let NOTES_DICT: Dictionary   = ["C":   0,
                                           "C#":  1,
                                           "D":   2,
                                           "D#":  3,
                                           "E":   4,
                                           "F":   5,
                                           "F#":  6,
                                           "G":   7,
                                           "G#":  8,
                                           "A":   9,
                                           "A#":  10,
                                           "B":   11]
    private let FREQUENCIES: [[Double]] = [
        [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87],
        [32.7, 34.65, 36.71, 38.89, 41.2, 43.65, 46.25, 49.0, 51.91, 55.0, 58.27, 61.74],
        [65.41, 69.3, 73.42, 77.78, 82.41, 87.31, 92.5, 98.0, 103.83, 110.0, 116.54, 123.47],
        [130.81, 138.59, 146.83, 155.56, 164.81, 174.61, 185.0, 196.0, 207.65, 220.0, 233.08, 246.94],
        [261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.0, 415.3, 440.0, 466.16, 493.88],
        [523.25, 554.37, 587.33, 622.25, 659.26, 698.46, 739.99, 783.99, 830.61, 880.0, 932.33, 987.77],
        [1046.5, 1108.73, 1174.66, 1244.51, 1318.51, 1396.91, 1479.98, 1567.98, 1661.22, 1760.0, 1864.66, 1975.53],
        [2093.0, 2217.46, 2349.32, 2489.02, 2637.02, 2793.83, 2959.96, 3135.96, 3322.44, 3520.0, 3729.31, 3951.07]
    ]
    
    // maps notes to y-coordinates in a graph between the bounds
    func mapToGraph(midNote: (note: String, octave: Int), bounds: (upper: Double, lower: Double), numNotes: Int) -> [(note: String, pos: Double, freq: Double)] {
        // finds the distance between each note
        let TOTAL_SPACE: Double = bounds.lower - bounds.upper
        let WHITE_SPACE: Double = TOTAL_SPACE / Double(numNotes)
        
        // resulting array
        var results: [(note: String, pos: Double, freq: Double)] = []
        
        // finds the location of the first note
        var currY: Double = bounds.lower - (WHITE_SPACE / 2)
        
        // for the number of notes there are, map them to the bounds
        for i in 0..<numNotes {
            // variables used to index 2D frequencies array
            var currNoteIndex: Int  = (i + NOTES_DICT[midNote.note]! - (numNotes / 2))
            var octave: Int         = midNote.octave
            
            // switch statement adjusts currNoteIndex and octave when values wrap around the notes dictionary
            switch currNoteIndex {
            case ..<0:
                currNoteIndex += NOTES_ARR.count
                octave = midNote.octave - 1
            case 0...NOTES_ARR.count-1:
                octave = midNote.octave
            case NOTES_ARR.count...:
                currNoteIndex %= NOTES_ARR.count
                octave = midNote.octave + 1
            default:
                continue
            }
            
            // gets the current note and frequency from the class variables
            let CURR_NOTE = NOTES_ARR[currNoteIndex]
            let CURR_FREQ = FREQUENCIES[octave][currNoteIndex]
            
            // appends current state to results and updates to the next y coordinate
            results.append((note: CURR_NOTE, pos: currY, freq: CURR_FREQ))
            currY -= WHITE_SPACE
        }
        return results
    }
}

