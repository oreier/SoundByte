//
//  SheetMusicStaff.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 6/4/25.
//

import SwiftUI

struct SheetMusicStaff: View {
    
    var fileName: String
    var xOffset: Double
    
    var body: some View {
        // Placing the HTMLViewer in a group means we can set allowsHitTesting to false, so a user cannot move the staff around
        Group {
            
            // Set up HTMLViewer with correct filename, scale+rotate+position correctly
            HTMLViewer(fileName: fileName)
                .offset(x: xOffset)
                .scaleEffect(4, anchor: .bottomLeading)
                .frame(width: 800, height: 150)
                .offset(y: 290.0)
            
        }
        .allowsHitTesting(false)
        
    }
    
    mutating func scroll(tempo: Double, increment: Double) {
        // Assume constant velocity of html
        let htmlVelocity = 100.0
        // Increase offset in correct direction by correct value per increment to scroll sheet music
        xOffset -= ((tempo / 60.0) * increment) * htmlVelocity
    }
}

#Preview {
   SheetMusicStaff(fileName: "index", xOffset: -40.0)
}
