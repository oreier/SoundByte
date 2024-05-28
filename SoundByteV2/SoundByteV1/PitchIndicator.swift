//
//  PitchIndicator.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/22/24.
//

import SwiftUI

/*
 struct creates the dot used to indicate a users current pitch
 */
struct PitchIndicator: View {
    // struct variables
    private let FRAME_HEIGHT: Double
    private let VERTICAL_FRAME_OFFSET: Double
    private let X_POS: Double
    private let Y_POS: Double
    
    // constant that sets the size of the indicator
    private let DOT_SIZE: Double = 20
    
    // initializes a pitch indicator
    init(frameHeight: Double, vOffset: Double, x: Double, y: Double) {
        self.FRAME_HEIGHT = frameHeight
        self.VERTICAL_FRAME_OFFSET = vOffset
        self.X_POS = x
        self.Y_POS = y
    }
    
    // constructs the indicator dot
    var body: some View {
        GeometryReader { proxy in
            // extra parameters in position modifier are so that the dot on the music notes aligns with the history line
            Image(systemName: "music.note")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: DOT_SIZE)
                .position(x: X_POS + DOT_SIZE / 3, y: Y_POS - DOT_SIZE / 2)
        }
        .frame(height: FRAME_HEIGHT)
        .offset(y: VERTICAL_FRAME_OFFSET)
    }
}

#Preview {
    PitchIndicator(frameHeight: 300, vOffset: 0, x: 100, y: 100)
}
