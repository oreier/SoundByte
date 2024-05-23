//
//  HistoryPath.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/22/24.
//

import SwiftUI

/*
creates a line of the previous pitches sung by the user
 */
struct HistoryPath: View {
    // struct variables
    private let FRAME_HEIGHT: Double
    private let VERTICAL_FRAME_OFFSET: Double
    private let COORDINATES: [CGPoint]
    private let COLOR_ARR: [Color]
    
    // constant determines the stroke of the history line
    private let LINE_WIDTH: Double = 2.5
    
    // initializes a history path
    init(frameHeight: Double, vOffset: Double, coords: [CGPoint], colors: [Color]) {
        self.FRAME_HEIGHT = frameHeight
        self.VERTICAL_FRAME_OFFSET = vOffset
        self.COORDINATES = coords
        self.COLOR_ARR = colors
    }
    
    // constructs the history line
    var body: some View {
        GeometryReader { proxy in
            
            // for each coordinate, draw a path from the current point to the next (this allows you to color each segment differently)
            ForEach(COORDINATES.indices.reversed(), id:\.self) { i in
                if i > 0 {
                    Path { path in
                        path.move(to: COORDINATES[i])
                        path.addLine(to: COORDINATES[i-1])
                    }                    
                    .stroke(lineWidth: LINE_WIDTH)
                    .fill(COLOR_ARR[i])
                }
            }
        }
        .frame(height: FRAME_HEIGHT)
        .offset(y: VERTICAL_FRAME_OFFSET)
    }
}

#Preview {
    HistoryPath(frameHeight: 300, vOffset: 0, coords: [CGPoint(x: 350, y: 50), CGPoint(x: 50, y: 50)], colors: [.red, .blue])
}
