//
//  KeySignature.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/4/24.
//

import SwiftUI

protocol AccidentalSettings {
    var numAccidentals: Int { get }
    var imageFile: String { get }
    var imageWidth: Double { get }
    var yOffset: Double { get }
    var displayOrder: [Double] { get set }
}

struct SharpSettings: AccidentalSettings {
    var numAccidentals: Int
    var imageFile = "sharp"
    var imageWidth = 22.5
    var yOffset = 0.0
    var displayOrder: [Double] = []
}

struct FlatSettings: AccidentalSettings {
    var numAccidentals: Int
    var imageFile = "flat"
    var imageWidth = 20.0
    var yOffset = -12.5
    var displayOrder: [Double] = []
}

struct KeySignature: View {
    let currentClef: ClefType
    let currentKey: Key
    let layout: UILayout
    
    let clefSettings: ClefSettings
    var accidentalSettings: AccidentalSettings
    
    init(clef: ClefType, key: Key, layout: UILayout) {
        self.currentClef = clef
        self.currentKey = key
        self.layout = layout
        
        // sets the settings for the clef
        switch currentClef {
        case .treble:
            clefSettings = TrebleClefSettings()
        case .octave:
            clefSettings = OctaveClefSettings()
        case .bass:
            clefSettings = BassClefSettings()
        }
        
        // sets the settings for the accidental
        if key.numSharps > 0 {
            accidentalSettings = SharpSettings(numAccidentals: key.numSharps)
        } else {
            accidentalSettings = FlatSettings(numAccidentals: key.numFlats)
        }
        
        accidentalSettings.displayOrder = key.numSharps > 0 ? clefSettings.sharpsOrder : clefSettings.flatsOrder
    }
    
    var body: some View {
        HStack(spacing: -5) {
            
            // for loop places the accidentals in the correct order
            ForEach(0..<accidentalSettings.numAccidentals, id: \.self) { i in
                Image(accidentalSettings.imageFile)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: accidentalSettings.imageWidth)
                    .offset(y: -accidentalSettings.displayOrder[i] * layout.spaceBetweenNotes + accidentalSettings.yOffset)
            }
        }
    }
}

// previewing staff to be able to align key signature correctly
#Preview {
    GeometryReader { proxy in
        Staff(clef: ClefType.treble, key: KeyGenerator(numFlats: 4, isMajor: true).data, layout: UILayout(width: proxy.size.width, height: proxy.size.height))
    }
}
