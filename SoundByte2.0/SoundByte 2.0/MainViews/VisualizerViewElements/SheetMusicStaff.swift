//
//  SheetMusicStaff.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 6/4/25.
//

import SwiftUI
import WebKit

struct SheetMusicStaff: View {
    
    var fileName: String
    var xOffset: Double
    var htmlViewer: HTMLViewer
    
    var body: some View {
        // Placing the HTMLViewer in a group means we can set allowsHitTesting to false, so a user cannot move the staff around
        Group {
            // Set up HTMLViewer with correct filename, scale+rotate+position correctly
            htmlViewer
                .offset(x: xOffset)
                .scaleEffect(4.0, anchor: .topLeading)
                .frame(maxWidth: .infinity)
                .offset(y: -25.0)
        }
        .allowsHitTesting(false) // Used to disallow user scrolling of sheet music
    }
    
    init(fileName: String, xOffset: Double) {
        self.fileName = fileName
        self.xOffset = xOffset
        self.htmlViewer = HTMLViewer(fileName: fileName)
    }
    
    mutating func scroll(tempo: Double, increment: Double) {
        // Assume constant velocity of html
        let htmlVelocity = 40.0
        // Increase offset in correct direction by correct value per increment to scroll sheet music
        xOffset -= ((tempo / 60.0) * increment) * htmlVelocity
        // Attempt at making the html scroll instead of the view (didn't work when first implemented)
        //let scrollPoint = CGPoint(x: CGFloat(xOffset), y: 0)
        //self.htmlViewer.scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    mutating func reset() {
        xOffset = 0.0
    }
}

#Preview {
   SheetMusicStaff(fileName: "rendererTest", xOffset: -40.0)
}
