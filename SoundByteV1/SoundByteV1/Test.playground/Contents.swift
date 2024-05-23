import UIKit

import Foundation

class FreqGraphMapper {
    private var middleNote: (note: String, octave: Int)
    private var graphBounds: (upper: Double, lower: Double)
    private var numNotes: Int
    
    private var baseNotes: Dictionary = ["C":   0,
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
    private var frequencies: [[Double]] = [
        [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87],
        [32.7, 34.65, 36.71, 38.89, 41.2, 43.65, 46.25, 49.0, 51.91, 55.0, 58.27, 61.74],
        [65.41, 69.3, 73.42, 77.78, 82.41, 87.31, 92.5, 98.0, 103.83, 110.0, 116.54, 123.47],
        [130.81, 138.59, 146.83, 155.56, 164.81, 174.61, 185.0, 196.0, 207.65, 220.0, 233.08, 246.94],
        [261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.0, 415.3, 440.0, 466.16, 493.88],
        [523.25, 554.37, 587.33, 622.25, 659.26, 698.46, 739.99, 783.99, 830.61, 880.0, 932.33, 987.77],
        [1046.5, 1108.73, 1174.66, 1244.51, 1318.51, 1396.91, 1479.98, 1567.98, 1661.22, 1760.0, 1864.66, 1975.53],
        [2093.0, 2217.46, 2349.32, 2489.02, 2637.02, 2793.83, 2959.96, 3135.96, 3322.44, 3520.0, 3729.31, 3951.07]
    ]
    
    private var notes: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    init(middleNote: (note: String, octave: Int), graphBounds: (upper: Double, lower: Double), numNotes: Int) {
        self.middleNote = middleNote
        self.graphBounds = graphBounds
        self.numNotes = numNotes
    }
    
    func mapToGraph() -> [(String, Double, Double)] {
        let SCREEN_SPACE: Double = graphBounds.lower - graphBounds.upper
        let WHITE_SPACE: Double = SCREEN_SPACE / Double(numNotes)
        
        var results: [(String, Double, Double)] = []
        var currY: Double = graphBounds.lower - (WHITE_SPACE / 2)
        var currNoteIndex: Int
        var octave: Int = middleNote.octave
        
        for i in 0..<numNotes {
            currNoteIndex = (i + baseNotes[middleNote.note]! - (numNotes / 2))
            
            switch currNoteIndex {
            case ..<0:
                currNoteIndex += notes.count
                octave = middleNote.octave - 1
            case 0...notes.count-1:
                octave = middleNote.octave
            case notes.count...:
                currNoteIndex %= notes.count
                octave = middleNote.octave + 1
            default:
                print("error")
            }
            
            let CURR_NOTE = notes[currNoteIndex]
            let CURR_FREQ = frequencies[octave][currNoteIndex]
            
            results.append((CURR_NOTE, currY, CURR_FREQ))
            currY -= WHITE_SPACE
        }
        return results
    }
}


var mapper = FreqGraphMapper(middleNote: ("C", 4), graphBounds: (0, 300), numNotes: 3)
print(mapper.mapToGraph())
