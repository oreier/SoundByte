//
//  KeySignature.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/4/24.
//

import SwiftUI

struct KeySignature: View {
    let currentClef: ClefType
    let currentKey: Key
    let spacingData: Spacing
    
    let clefSettings: ClefSettings
    
    init(clef: ClefType, key: Key, spacing: Spacing) {
        self.currentClef = clef
        self.currentKey = key
        self.spacingData = spacing
        
        switch currentClef {
        case .treble:
            clefSettings = TrebleClefSettings()
        case .tenorVocal:
            clefSettings = TenorVocalClefSettings()
        case .bass:
            clefSettings = BassClefSettings()
        }
    }
    
    var body: some View {
        HStack(spacing: -37.5) {
            // displays sharps if there are any
            if currentKey.data.numSharps > 0 {
                ForEach(0..<currentKey.data.numSharps, id: \.self) { i in
                    Image("sharp")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: spacingData.whiteSpaceBetweenLines * 1.35)
                        .offset(y: -clefSettings.sharpsOrder[i] * spacingData.whiteSpaceBetweenNotes)
                }
            }
            
            // displays flats if there are any
            if currentKey.data.numFlats > 0 {
                ForEach(0..<currentKey.data.numSharps, id: \.self) { i in
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

// previewing staff to be able to align key signature correctly
#Preview {
    GeometryReader { proxy in
        Staff(clef: ClefType.treble, key: Key(numSharps: 4, isMajor: true), spacing: Spacing(width: proxy.size.width, height: proxy.size.height))
    }
}
