//
//  Key.swift
//  SoundByte 2.0
//
//  Created by Jack Durfee on 5/30/24.
//

/*
 TO-DO:
 - Write code so that when a user inputs the name of the key it can generate the notes that are in that key
 - Write code to organize key based off the note in the key
 - Write code to figure out the name of the key based off the number of flats or sharps
 */

import Foundation

// errors that can be thrown when generating a key
enum KeyInitError: Error {
    case invalidNote
    case invalidAccidental
    case invalidNumberOfSharps
    case invalidNumberOfFlats
}

// organized way to store information about a key
struct KeyData {
    // note name / identifier of the key
    var note        = ""
    var accidental  = ""
    var isMajor     = true
    
    // number of accidentals in the key
    var numSharps   = 0
    var numFlats    = 0
    
    // the notes that are in the key
    var notes: [String] = []
    
    // the center staff note in each of the clefs we are representing
    var centerNoteTreble        = (note: "", octave: 0)
    var centerNoteTenorVocal    = (note: "", octave: 0)
    var centerNoteBass          = (note: "", octave: 0)
}

// generates a key object based off the information that is passed to it
class Key {
    // stores data about the key
    var data = KeyData()
    
    // sharps and flats in order of how they are generated in a key
    private let sharpsInOrder   = ["F", "C", "G", "D", "A", "E", "B"]
    private let flatsInOrder    = ["B", "E", "A", "D", "G", "C", "F"]
    
    // accidentals used for key construction
    private let accidentals = ["♮", "♯", "♭"]
    
    // default constructor initializes key to C major
    init() {
        // sets trivial data about the key
        self.data.note          = "C"
        self.data.accidental    = "♮"
        self.data.isMajor       = true
        
        // sets more complex data about the key
        self.generateNotes()
        self.setMiddleNotes()
    }
    
    // constructor initializes key based off the name of the key
    init(note: String, accidental: String, isMajor: Bool) throws {
        // ensures that a valid note is passed to the initializer
        guard sharpsInOrder.contains(note) else { throw KeyInitError.invalidNote }
        
        // ensures that a valid accidental is passed to the initializer
        guard accidentals.contains(accidental) else { throw KeyInitError.invalidAccidental }
        
        // sets trivial data about the key
        self.data.note          = note
        self.data.accidental    = accidental
        self.data.isMajor       = isMajor
    }
    
    // constructor that initializes key based off the number of sharps
    init(numSharps: Int, isMajor: Bool) throws {
        // ensures that a valid number of sharps are passed to the initializer
        guard (numSharps >= 0 && numSharps <= 7) else { throw KeyInitError.invalidNumberOfSharps }
        
        // sets trivial data about the key
        self.data.numSharps = numSharps
        self.data.isMajor   = isMajor
        
        // sets more complex data about the key
        self.generateNotes()
        self.setMiddleNotes()
    }
    
    // constructor that initializes key based off the number of flats
    init(numFlats: Int, isMajor: Bool) throws {
        // ensures that a valid number of flats are passed to the initializer
        guard (numFlats >= 0 && numFlats <= 7) else { throw KeyInitError.invalidNumberOfFlats }
        
        // sets trivial data about the key
        self.data.numFlats  = numFlats
        self.data.isMajor   = isMajor
        
        // sets more complex data about the key
        self.generateNotes()
        self.setMiddleNotes()
    }
    
    // generates the notes in the given key
    private func generateNotes() {
        // generates the notes that are in the key
        if data.numSharps != 0 {
            data.notes.append(contentsOf: sharpsInOrder[0..<data.numSharps].map{ $0 + "♯" })
            data.notes.append(contentsOf: sharpsInOrder[data.numSharps...])
        } else if data.numFlats != 0 {
            data.notes.append(contentsOf: flatsInOrder[0..<data.numFlats].map{ $0 + "♭" })
            data.notes.append(contentsOf: flatsInOrder[data.numFlats...])
        } else {
            data.notes.append(contentsOf: sharpsInOrder)
        }
        
        // sorts notes in key alphabetically
        data.notes.sort()
        
        // arranges notes in key to begin with C
        data.notes = Array(data.notes[2...] + data.notes.prefix(2))
    }
    
    // sets the notes that fall in the center of a clef
    private func setMiddleNotes() {
        // sets the center note of the treble clef to B
        data.centerNoteTreble = (data.notes.first(where: { $0.contains("B") })!, 4)
        
        // sets the center note of the tenor vocal clef to B
        data.centerNoteTenorVocal = (data.notes.first(where: { $0.contains("B") })!, 3)
        
        // sets the center note of the bass clef to D
        data.centerNoteBass = (data.notes.first(where: { $0.contains("D") })!, 3)
    }
}
