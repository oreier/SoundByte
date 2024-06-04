//
//  HistoryPath.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 6/3/24.
//

import SwiftUI

// creates a line to show the past pitches a user has sung
struct HistoryPath: View {
    // arrays that store how the line is going to be built
    let coordinates: [CGPoint]
    let colors: [Color]
    let start: Double
    
    // constants set the stroke and width of each history line segment
    let lineStroke = 3.5
    
    // constructor for the history path
    init(coordinates: [CGPoint], colors: [Color], start: Double) {
        self.coordinates = coordinates
        self.colors = colors
        self.start = start
    }
    
    // builds the history line
    var body: some View {
        // for each coordinate, draw a path from the current point to the next (this allows you to color each segment differently)
        ForEach(coordinates.indices.reversed(), id:\.self) { i in
            if i > 0 {
                Path { path in
                    path.move(to: coordinates[i-1])
                    path.addLine(to: coordinates[i])
                }
                .stroke(lineWidth: lineStroke)
                .fill(colors[i])
            }
        }
    }
}

#Preview {
    HistoryPath(coordinates: [CGPoint(x: 350, y: 50), CGPoint(x: 50, y: 50)], colors: [.red, .blue], start: 100)
}
