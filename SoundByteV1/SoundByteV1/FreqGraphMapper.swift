//
//  Converter.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/21/24.
//

import Foundation

class FreqGraphMapper {
    private var middleNote: (note: String, octave: Int)
    private var graphBounds: (upper: Double, lower: Double)
    private var numNotes: Int
    
    private var baseNotes: Dictionary = ["C":   (0, 16.35),
                                         "C#":  (1, 17.32),
                                         "D":   (2, 18.35),
                                         "D#":  (3, 19.45),
                                         "E":   (4, 20.60),
                                         "F":   (5, 21.83),
                                         "F#":  (6, 23.12),
                                         "G":   (7, 24.50),
                                         "G#":  (8, 25.96),
                                         "A":   (9, 27.50),
                                         "A#":  (10, 29.14),
                                         "B":   (11, 30.87)]
    
    private var notes: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    init(middleNote: (note: String, octave: Int), graphBounds: (upper: Double, lower: Double), numNotes: Int) {
        self.middleNote = middleNote
        self.graphBounds = graphBounds
        self.numNotes = numNotes
    }
    
    func mapToGraph() -> [(String, Double)] {
        let SCREEN_SPACE: Double = graphBounds.lower - graphBounds.upper
        let WHITE_SPACE: Double = SCREEN_SPACE / Double(numNotes)
        
        var results: [(String, Double)] = []
        var currY: Double = graphBounds.lower - (WHITE_SPACE / 2)
        
        for i in 0..<numNotes {
            let CURR_NOTE_INDEX = ((baseNotes[middleNote.note]!.0 - (numNotes / 2)) % notes.count) + i
            let CURR_NOTE = notes[CURR_NOTE_INDEX + (CURR_NOTE_INDEX < 0 ? notes.count : 0)]
//            var currFreq = baseNotes[CURR_NOTE]!.1 * pow(2, Double(startNote.octave) + ((i >= notes.count) ? 1 : 0))
            
            results.append((CURR_NOTE, currY))
            currY -= WHITE_SPACE
        }
        return results
    }
}

