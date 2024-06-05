//
//  KeyGenerator.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/5/24.
//

/*
 TO-DO:
 - Write code so that when a user inputs the name of the key it can generate the notes that are in that key
 - Write code to figure out the name of the key based off the number of flats or sharps
 */

import Foundation

// organized struct to store information about a note
struct Note: Codable {
    var note: String
    var octave: Int
}

// organized struct to store information about a key
struct Key: Codable {
    // identifiers of the key
    var noteName: String?
    var accidental: String?
    var isMajor: Bool?
    
    // number of accidentals in the key
    var numSharps: Int = 0
    var numFlats: Int = 0
    
    // the notes that are in the key
    var notes: [String] = []
    
    // the center staff note in each of the clefs we are representing
    var centerNoteTreble: Note?
    var centerNoteOctave: Note?
    var centerNoteBass: Note?
}

// generates a key object based off the information that is passed to it
class KeyGenerator {
    // stores data about the key
    var data = Key()
    
    // sharps and flats in order of how they are generated in a key
    private let sharpsInOrder   = ["F", "C", "G", "D", "A", "E", "B"]
    private let flatsInOrder    = ["B", "E", "A", "D", "G", "C", "F"]
    
    // accidentals used for key construction
    private let accidentals = ["♮", "♯", "♭"]
    
    // default constructor initializes key to C major
    init() {
        // set key name
        self.data.noteName = "C"
        self.data.accidental = "♮"
        self.data.isMajor = true
        
        // sets more complex data about the key
        self.generateNotes()
        self.setMiddleNotes()
    }
    
    // constructor initializes key based off the name of the key
    init(note: String, accidental: String, isMajor: Bool) {
        // sets key identifier
        self.data.noteName = note
        self.data.accidental = accidental
        self.data.isMajor = isMajor
    }
    
    // constructor that initializes key based off the number of sharps
    init(numSharps: Int, isMajor: Bool) {
        // sets trivial data about the key
        self.data.numSharps = numSharps
        self.data.isMajor   = isMajor
        
        // sets more complex data about the key
        self.generateNotes()
        self.setMiddleNotes()
    }
    
    // constructor that initializes key based off the number of flats
    init(numFlats: Int, isMajor: Bool) {
        // sets trivial data about the key
        self.data.numFlats  = numFlats
        self.data.isMajor   = isMajor
        
        // sets more complex data about the key
        self.generateNotes()
        self.setMiddleNotes()
    }
    
    // generates the notes in the given key
    private func generateNotes() {
        data.notes = []
        
        // generates the notes that are in the key
        if data.numSharps != 0 {
            data.notes.append(contentsOf: sharpsInOrder[0..<(data.numSharps)].map{ $0 + "♯" })
            data.notes.append(contentsOf: sharpsInOrder[(data.numSharps)...])
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
        data.centerNoteTreble = Note(note: data.notes.first(where: { $0.contains("B") }) ?? "B", octave: 4)
        
        // sets the center note of the octave clef to B
        data.centerNoteOctave = Note(note: data.notes.first(where: { $0.contains("B") }) ?? "B", octave: 3)
        
        // sets the center note of the bass clef to D
        data.centerNoteBass = Note(note: data.notes.first(where: { $0.contains("D") }) ?? "D", octave: 3)
    }
}
