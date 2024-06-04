//
//  NotesToGraphMapper.swift
//  SoundByte 2.0
//
//  Created by Jack Durfee on 5/30/24.
//

import Foundation

// errors that can be thrown when performing a mapping or setting up the mapper
enum NotesToGraphMapperInitError: Error {
    // errors for variables that are not set
    case centerNoteNotSet
    case notesInKeyNotSet
    
    // errors for variables that are set incorrectly
    case invalidCenterNote
    case invalidNotesInKey
}

// creates a mapping from a series of notes to a one dimensional axis
class NotesToGraphMapper {
    // variables to generate the mapping off of
    var centerNote = (note: "", octave: 0)
    var centerNotePosition = 0.0
    var notesInKey: [String] = []
    var numNotes = 0
    var spacing = 0.0
    
    // frequencies of all 0th octave notes
    private let frequencies = ["C♭" : 15.40, "C"  : 16.35, "C♯" : 17.32,
                               "D♭" : 17.32, "D"  : 18.35, "D♯" : 19.45,
                               "E♭" : 19.45, "E"  : 20.60, "E♯" : 21.83,
                               "F♭" : 20.60, "F"  : 21.83, "F♯" : 23.12,
                               "G♭" : 23.12, "G"  : 24.50, "G♯" : 25.96,
                               "A♭" : 25.96, "A"  : 27.50, "A♯" : 29.14,
                               "B♭" : 29.14, "B"  : 30.87, "B♯" : 32.70]
    
    // indicies to reference the notesInKey array by
    private let noteIndicies = ["C♭" : 0, "C"  : 0, "C♯" : 0,
                                "D♭" : 1, "D"  : 1, "D♯" : 1,
                                "E♭" : 2, "E"  : 2, "E♯" : 2,
                                "F♭" : 3, "F"  : 3, "F♯" : 3,
                                "G♭" : 4, "G"  : 4, "G♯" : 4,
                                "A♭" : 5, "A"  : 5, "A♯" : 5,
                                "B♭" : 6, "B"  : 6, "B♯" : 6]
    
    // maps notes onto a one dimensional axis and returns a dictionary, [frequency : position]
    func mapNotes() -> [Double : Double] {
        // dictionary represents [frequency : position]
        var results: [Double : Double] = [:]
        
        // in a do-catch block to check for any errors there may be with set up
        do {
            // check that there aren't any invalid inputs before we start mapping values
            try checkForErrors()
            
            // get the index of the center note
            let centerNoteIndex = noteIndicies[centerNote.note]!
            
            // calculate mapping for notes above center note
            for i in 0..<(numNotes / 2) {
                let noteMapping = mapNoteAbove(startIndex: centerNoteIndex, notesAbove: i)
                results[noteMapping.frequency] = noteMapping.position
            }
            
            // calculate mapping for center note
            results[calculateFreqency(of: centerNote)] = centerNotePosition
            
            // calculate mapping for notes below middle note
            for i in 0..<(numNotes / 2) {
                let noteMapping = mapNoteBelow(startIndex: centerNoteIndex, notesBelow: i)
                results[noteMapping.frequency] = noteMapping.position
            }
            
        } catch {
            print("Error: \(error)")
        }
        
        return results
    }
    
    // checks for any input errors to the variables that control the mapping
    func checkForErrors() throws {
        // ensures that the center note and notes in key array are set to some value
        guard centerNote != (note: "", octave: 0) else { throw NotesToGraphMapperInitError.centerNoteNotSet }
        guard notesInKey.count != 0 else { throw NotesToGraphMapperInitError.notesInKeyNotSet }
        
        // ensures that the center note is valid
        guard noteIndicies[centerNote.note] != nil else { throw NotesToGraphMapperInitError.invalidCenterNote }
        guard centerNote.octave >= 0 else { throw NotesToGraphMapperInitError.invalidCenterNote }
        
        // ensures that the number of notes in the notes in key array is seven
        guard notesInKey.count == 7 else { throw NotesToGraphMapperInitError.invalidNotesInKey }
        
        // ensures that each note in notes in key array are valid
        for note in notesInKey {
            guard noteIndicies[note] != nil else { throw NotesToGraphMapperInitError.invalidNotesInKey }
        }
    }
    
    // maps the ith note above the center note
    func mapNoteAbove(startIndex centerNoteIndex: Int, notesAbove i: Int) -> (frequency: Double, position: Double) {
        // calculates the index of the next note above
        let upperNoteIndex = (centerNoteIndex + (i + 1)) % 7

        // calculates the name and octave of the next note above
        let upperNoteName = notesInKey[upperNoteIndex]
        let upperNoteOctave = centerNote.octave + (centerNoteIndex + (i + 1)) / 7

        // calculates the frequency and position of the next note above
        let upperNoteFrequency = calculateFreqency(of: (upperNoteName, upperNoteOctave))
        let upperNotePosition = centerNotePosition - (spacing * Double(i + 1))
        
        return (upperNoteFrequency, upperNotePosition)
    }
    
    // maps the ith note below the center note
    private func mapNoteBelow(startIndex centerNoteIndex: Int, notesBelow i: Int) -> (frequency: Double, position: Double) {
        // calculates the index of the next note below
        var lowerNoteIndex = centerNoteIndex - (i + 1)
        
        var lowerNoteOctave = centerNote.octave
        
        // if the lower note index is negative, adjust it
        if lowerNoteIndex < 0 {
            lowerNoteOctave -= 1 - lowerNoteIndex / 8
            lowerNoteIndex += 7 * (1 - lowerNoteIndex / 8)
        }
        
        // calculates the name of the next note below
        let lowerNoteName = notesInKey[lowerNoteIndex]
        
        // calculates the frequency and position of the next note below
        let lowerNoteFrequency = calculateFreqency(of: (lowerNoteName, lowerNoteOctave))
        let lowerNotePosition = centerNotePosition + (spacing * Double(i + 1))
        
        return (lowerNoteFrequency, lowerNotePosition)
    }
    
    // helper function that calculates the frequency of a given note
    func calculateFreqency(of note: (note: String, octave: Int)) -> Double {
        return frequencies[note.note]! * pow(2, Double(note.octave))
    }
    
}
