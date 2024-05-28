//
//  NoteAxis.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/22/24.
//

import SwiftUI

/*
creates the note axis on the right hand side of the screen
 */
struct NoteAxis: View {
    // struct variables
    private let FRAME_HEIGHT: Double
    private let VERTICAL_FRAME_OFFSET: Double
    private let START_X: Double
    private let MAPPED_FREQ: [(note: String, pos: Double, freq: Double)]
    
    // constants determine the proberties of the main bar
    private let MAIN_BAR_WIDTH: Double      = 5.0
    private let MAIN_BAR_COLOR: Color       = .primary
    private let MAIN_BAR_OPACITY: Double    = 1.0
    
    // constants determine the properties of the sub bars
    private let SUB_BAR_HEIGHT: Double      = 2.5
    private let SUB_BAR_COLOR: Color        = .secondary
    private let SUB_BAR_OPACITY: Double     = 0.5
    
    // initializes a note axis
    init(frameHeight: Double, vOffset: Double, x: Double, mappedFreq: [(note: String, pos: Double, freq: Double)]) {
        self.FRAME_HEIGHT = frameHeight
        self.VERTICAL_FRAME_OFFSET = vOffset
        self.START_X = x
        self.MAPPED_FREQ = mappedFreq
    }
    
    // constructs the notes axis
    var body: some View {
        GeometryReader { proxy in
            // builds the vertical bar on the right
            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                .frame(width: MAIN_BAR_WIDTH, height: FRAME_HEIGHT)
                .foregroundStyle(MAIN_BAR_COLOR)
                .opacity(MAIN_BAR_OPACITY)
                .offset(x: START_X + 25)
            
            // builds each horizontal bar and the note labels
            ForEach(MAPPED_FREQ.indices, id:\.self) { i in
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .frame(width: START_X + 50, height: SUB_BAR_HEIGHT)
                    .foregroundStyle(SUB_BAR_COLOR)
                    .opacity(SUB_BAR_OPACITY)
                    .offset(y: MAPPED_FREQ[i].pos)
                
                Text(MAPPED_FREQ[i].note)
                    .font(.system(size: MAPPED_FREQ[MAPPED_FREQ.count-1].pos / 1.5))
                    .offset(x: START_X + 55, y: MAPPED_FREQ[i].pos - MAPPED_FREQ[MAPPED_FREQ.count-1].pos / 3)
            }
        }
        .frame(height: FRAME_HEIGHT)
        .offset(y: VERTICAL_FRAME_OFFSET)
    }
}

#Preview {
    NoteAxis(frameHeight: 300, vOffset: 0, x: 300, mappedFreq: FreqGraphMapper().mapToGraph(midNote: ("C", 4), bounds: (0, 300), numNotes: 7))
}
