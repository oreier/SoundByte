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
    var imageWidth: Double { get } // how wide the image is
    var offsetX: Double { get } // the x offset to display the image at
    var offsetY: Double { get } // the y offset to display the image at
    var keySignatureOffsetX: Double { get }
    var sharpsOrder: [Double] { get } // the order in which sharps are added to the clef from the middle note
    var flatsOrder: [Double] { get } // the order in which flats are added to the clef from the middle note
}

// settings for the treble cleff
struct TrebleClefSettings: ClefSettings {
    var imageFile = "trebleClef"
    var imageWidth = 105.0
    var offsetX = 0.0
    var offsetY = 0.0
    var keySignatureOffsetX = 80.0
    var sharpsOrder = [4.0, 1.0, 5.0, 2.0, -1.0, 3.0, 0.0]
    var flatsOrder = [0.0, 3.0, -1.0, 2.0, -2.0, 1.0, -3.0]
}

// settings for the tenor vocal cleff
struct OctaveClefSettings: ClefSettings {
    var imageFile = "octaveClef"
    var imageWidth = 105.0
    var offsetX = 0.0
    var offsetY = 16.75
    var keySignatureOffsetX = 80.0
    var sharpsOrder = [4.0, 1.0, 5.0, 2.0, -1.0, 3.0, 0.0]
    var flatsOrder = [0.0, 3.0, -1.0, 2.0, -2.0, 1.0, -3.0]
}

// settings for the bass cleff
struct BassClefSettings: ClefSettings {
    var imageFile = "bassClef"
    var imageWidth = 115.0
    var offsetX = 0.0
    var offsetY = -12.5
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
                .foregroundStyle(.primary)
                .frame(width: clefSettings.imageWidth)
                .offset(x: clefSettings.offsetX, y: clefSettings.offsetY)
        }
    }
}

// previewing staff to be able to align clef correctly
#Preview {
    GeometryReader { proxy in
        Staff(clef: ClefType.bass, key: KeyGenerator().data, layout: UILayout(width: proxy.size.width, height: proxy.size.height))
    }
}
