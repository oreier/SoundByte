//
//  ClefImage.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/4/24.
//

import SwiftUI

// protocol defines the settings each clef should have
protocol ClefSettings {
    var imageFile: String { get } // the name of the image file
    var frameHeight: Double { get } // how tall the image should apear
    var offsetX: Double { get } // the x offset to display the image at
    var offsetY: Double { get } // the y offset to display the image at
    var keySignatureOffsetX: Double { get }
    var sharpsOrder: [Double] { get } // the order in which sharps are added to the clef from the middle note
    var flatsOrder: [Double] { get } // the order in which flats are added to the clef from the middle note
}

// settings for the treble cleff
struct TrebleClefSettings: ClefSettings {
    var imageFile = "trebleClef"
    var frameHeight = 260.0
    var offsetX = -80.0
    var offsetY = 10.0
    var keySignatureOffsetX = 80.0
    var sharpsOrder = [4.0, 1.0, 5.0, 2.0, -1.0, 3.0, 0.0]
    var flatsOrder = [0.0, 3.0, -1.0, 2.0, -2.0, 1.0, -3.0]
}

// settings for the tenor vocal cleff
struct OctaveClefSettings: ClefSettings {
    var imageFile = "tenorVocalClef"
    var frameHeight = 300.0
    var offsetX = -100.0
    var offsetY = 28.0
    var keySignatureOffsetX = 80.0
    var sharpsOrder = [4.0, 1.0, 5.0, 2.0, -1.0, 3.0, 0.0]
    var flatsOrder = [0.0, 3.0, -1.0, 2.0, -2.0, 1.0, -3.0]
}

// settings for the bass cleff
struct BassClefSettings: ClefSettings {
    var imageFile = "bassClef"
    var frameHeight = 130.0
    var offsetX = -10.0
    var offsetY = -15.0
    var keySignatureOffsetX = 110.0
    var sharpsOrder = [2.0, -1.0, 3.0, 0.0, -3.0, 1.0, -2.0]
    var flatsOrder = [-2.0, 1.0, -3.0, 0.0, -4.0, -1.0, -5.0]
}

// view constructs the image of the clef that is to be displayed
struct ClefImage: View {
    let currentClef: ClefType
    let clefSettings: ClefSettings
    
    // constructor for clef image
    init(clef: ClefType) {
        self.currentClef = clef
        
        switch currentClef {
        case .treble:
            clefSettings = TrebleClefSettings()
        case .octave:
            clefSettings = OctaveClefSettings()
        case .bass:
            clefSettings = BassClefSettings()
        }
    }
    
    // builds the clef image
    var body: some View {
        ZStack(alignment: .leading) {
            // displays image of the clef
            Image(clefSettings.imageFile)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: clefSettings.frameHeight)
                .offset(x: clefSettings.offsetX, y: clefSettings.offsetY)
        }
    }
}

// previewing staff to be able to align clef correctly
#Preview {
    GeometryReader { proxy in
        Staff(clef: ClefType.treble, key: KeyGenerator().data, spacing: Spacing(width: proxy.size.width, height: proxy.size.height))
    }
}
