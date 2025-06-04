//
//  SheetMusicStaff.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 6/4/25.
//

import SwiftUI

struct SheetMusicStaff: View {
    
    var body: some View {
        // Placing the HTMLViewer in a group means we can set allowsHitTesting to false, so a user cannot move the staff around
        Group {
            
            // Set up HTMLViewer with correct filename, scale+rotate+position correctly
            HTMLViewer(fileName: "indexTest")
                .scaleEffect(4, anchor: .bottomLeading)
                .frame(width: 800, height: 100)
                .rotationEffect(Angle(degrees: 90), anchor: .center)
                .offset(x:-80.0, y: 0.0)
            
        }
        .allowsHitTesting(false)
        
    }
}

#Preview {
    SheetMusicStaff()
}
