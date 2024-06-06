//
//  PitchIndicator.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/4/24.
//

import SwiftUI

// view creates the indicator used to show a users live pitch
struct PitchIndicator: View {
    let xPosition: Double
    let yPosition: Double
    
    // constant to set indicator dot parameters
    let dotSize: Double = 25
    
    // constructor for the pitch indicator
    init(x: Double, y: Double) {
        self.xPosition = x
        self.yPosition = y
    }
    
    // builds the dot
    var body: some View {
        Image(systemName: "music.note")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: dotSize)
            .position(x: xPosition, y: yPosition)
            .offset(x: dotSize / 4, y: -15) // offset is to align music note dot to lines
    }
}

#Preview {
    GeometryReader { proxy in
        PitchIndicator(x: proxy.size.width / 2, y: proxy.size.height / 2)
    }
}
