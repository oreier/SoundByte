//
//  HistoryPath.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 6/3/24.
//

import SwiftUI

// creates a line to show the past pitches a user has sung
struct HistoryPath: View {
    let points: [CGPoint]
    let colors: [Color]
    let xStart: Double
    
    // constants set the stroke and width of each history line segment
    let lineStroke = 3.5
    
    // constructor for the history path
    init(points: [CGPoint], colors: [Color], xStart: Double) {
        self.points = points
        self.colors = colors
        self.xStart = xStart
    }
    
    // builds the history line
    var body: some View {
        // for each coordinate, draw a path from the current point to the next (this allows you to color each segment differently)
        ForEach(points.indices.reversed(), id:\.self) { i in
            if i > 0 {
                Path { path in
                    path.move(to: points[i-1])
                    path.addLine(to: points[i])
                }
                .stroke(lineWidth: lineStroke)
                .fill(colors[i])
            }
        }
    }
}

#Preview {
    HistoryPath(points: [CGPoint(x: 350, y: 50), CGPoint(x: 50, y: 50)], colors: [.red, .blue], xStart: 100)
}
