//
//  KeySignature.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/4/24.
//

import SwiftUI

struct KeySignature: View {
    let currentClef: String
    let currentKey: KeyData
    let spacingData: Spacing
    
    let clefSettings: ClefSettings
    
    init(clef currentClef: String, key currentKey: KeyData, spacing: Spacing) {
        self.currentClef = currentClef
        self.currentKey = currentKey
        self.spacingData = spacing
        
        switch currentClef {
        case "treble":
            clefSettings = TrebleClefSettings()
        case "tenorVocal":
            clefSettings = TenorVocalClefSettings()
        case "bass":
            clefSettings = BassClefSettings()
        default:
            clefSettings = TrebleClefSettings()
            print("Error: invalidClefType")
        }
    }
    
    var body: some View {
        HStack(spacing: -37.5) {
            // displays sharps if there are any
            if currentKey.numSharps > 0 {
                ForEach(0..<currentKey.numSharps, id: \.self) { i in
                    Image("sharp")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: spacingData.whiteSpaceBetweenLines * 1.35)
                        .offset(y: -clefSettings.sharpsOrder[i] * spacingData.whiteSpaceBetweenNotes)
                }
            }
            
            // displays flats if there are any
            if currentKey.numFlats > 0 {
                ForEach(0..<currentKey.numSharps, id: \.self) { i in
                    Image("flat")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: spacingData.whiteSpaceBetweenLines * 1.35)
                        .offset(y: -clefSettings.flatsOrder[i] * spacingData.whiteSpaceBetweenNotes - spacingData.whiteSpaceBetweenNotes / 1.5)
                }
            }
        }
        .offset(x: clefSettings.keySignatureOffsetX)
    }
}

#Preview {
    KeySignature(clef: "treble", key: Key().data, spacing: Spacing())
}
