//
//  PitchVisualizer.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/20/24.
//

/*
 TO-DO:
 - Make changing orientations scale correctly for history line
 - Have the slider be frequencies and transform frequencies to fit the graph
    -> Remember, this is not a linear scale so we will have to account for that
 - Color the line according to how close it is to a note
 */

import SwiftUI

/*
 struct creates the dot used to indicate a users live pitch
 */
struct IndicatorDot: View {
    // parameters specified by the caller
    let FRAME_HEIGHT: Double
    let DOT_X: Double
    let DOT_Y: Double
    let Y_OFFSET: Double
    
    // constant that sets the size of the indicator
    private let INDICATOR_DOT_SIZE: CGFloat = 20
    
    // constructs the indicator dot
    var body: some View {
        GeometryReader { proxy in
            Image(systemName: "music.note")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: INDICATOR_DOT_SIZE)
                .position(x: DOT_X + INDICATOR_DOT_SIZE / 3, y: DOT_Y - INDICATOR_DOT_SIZE / 2)
        }
        .frame(height: FRAME_HEIGHT)
        .offset(y: Y_OFFSET)
    }
}

/*
 struct creates the path which represents the past pitches sung
 */
struct HistoryPath: View {
    // parameters passed by the caller
    let FRAME_HEIGHT: Double
    let START_X: Double
    let HISTORY: [Double]
    let ADVANCE_INTERVAL: Double
    let Y_OFFSET: Double
    
    // constant determines the stroke of the history line
    private let LINE_WIDTH: Double = 2.5
    
    // constructs the history line
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: START_X, y: HISTORY.last ?? FRAME_HEIGHT / 2))
                var j: Double = 0
                    
                // for each entry in the history array draw a line connecting each point
                for i in stride(from: HISTORY.count-2, through: 0, by: -1) {
                    path.addLine(to: CGPoint(x: START_X - j, y: HISTORY[i]))
                    j += ADVANCE_INTERVAL
                }
                
            }
            .stroke(lineWidth: LINE_WIDTH)
            .fill(.primary)
        }
        .frame(height: FRAME_HEIGHT)
        .offset(y: Y_OFFSET)
    }
}

/*
 struct to create the notes axis
 */
struct NotesAxis: View {
    // constants passed to the struct by the caller
    let FRAME_HEIGHT: Double
    let START_X: Double
    let LANDSCAPE_OFFSET: Double
    let NUM_NOTES_IN_RANGE: Int
    let MIDDLE_NOTE: (String, Int)
    
    // constants determine the size of the bars
    private let MAIN_BAR_WIDTH: Double = 5.0
    private let SUB_BAR_HEIGHT: Double = 2.5
    
    // constructs the notes axis
    var body: some View {
        // array to place horizontal bars
        let MAPPER = FreqGraphMapper(middleNote: MIDDLE_NOTE, graphBounds: (0, FRAME_HEIGHT), numNotes: NUM_NOTES_IN_RANGE)
        let PLOT_ARR = MAPPER.mapToGraph()
        
        GeometryReader { proxy in
            // vertical bar on the right
            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                .frame(width: MAIN_BAR_WIDTH, height: FRAME_HEIGHT)
                .offset(x: START_X + 25)
            
            // builds each horizontal bar for each of the offsets
            ForEach(PLOT_ARR.indices, id:\.self) { i in
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .frame(width: START_X + 50, height: SUB_BAR_HEIGHT)
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
                    .offset(y: PLOT_ARR[i].1)
                
                Text(PLOT_ARR[i].0)
                    .font(.system(size: PLOT_ARR[PLOT_ARR.count-1].1 / 1.5))
                    .offset(x: START_X + 55, y: PLOT_ARR[i].1 - PLOT_ARR[PLOT_ARR.count-1].1 / 3)
            }
        }
        .frame(height: FRAME_HEIGHT)
        .offset(y: LANDSCAPE_OFFSET)
    }
}

/*
 struct supports the proccess of retriving the dimensions of
 the screen in any orientation
 */
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

/*
 struct brings all the pieces together to create a graph of the
 current pitch sung by the user and the line representing the
 past pitches sung
 */
struct PitchVisualizer: View {
    // binding variables passed by ContentView
//    @Binding var isRecording: Bool
//    @Binding var isStop: Bool
    
    // variables for seeing preview
    @State var isRecording: Bool   = true
    @State var isStop: Bool        = false
    
    // state variables to track various aspects of the live indicator and history line
    @State private var screenSize: CGSize = .zero
    @State private var yCoord: Double = 0
    @State private var history: [Double] = []
    @State private var advanceBy: Double = 2
    @State private var sliderOpacVal: Double = 1.0
    @State private var currFreq: Double = 0
    
    // gets the orientation of the device
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // constants used to set various parameters
    private let TIMER = Timer.publish(every: 0.025, on: .main, in: .common).autoconnect()
    private let RIGHT_MARGIN: Double = 100
    
    // constructs the whole graph
    var body: some View {
        // constants set various aspects of the graph based on orinetation and screen size
        let GRAPH_SIZE: Double = screenSize.height / { return verticalSizeClass == .compact ? 1.5 : 2 }()
        let DOT_START_X: Double = screenSize.width - RIGHT_MARGIN
        let VERTICAL_OFFSET: Double = { return verticalSizeClass == .compact ? screenSize.height / 15 : 0 }()
        
        ZStack {
            // displays the axis and note labels
            NotesAxis(FRAME_HEIGHT: GRAPH_SIZE,
                      START_X: DOT_START_X,
                      LANDSCAPE_OFFSET: VERTICAL_OFFSET,
                      NUM_NOTES_IN_RANGE: 7,
                      MIDDLE_NOTE: ("C", 5))
            
            // displays indicator of where the current pitch is
            IndicatorDot(FRAME_HEIGHT: GRAPH_SIZE,
                         DOT_X: DOT_START_X,
                         DOT_Y: yCoord,
                         Y_OFFSET: VERTICAL_OFFSET)
                .onReceive(TIMER) { _ in
                    if isRecording {
                        history.append(yCoord)
                    } else if isStop {
                        history = []
                        self.isStop.toggle()
                    }
                }
            
            // displays the history path as a line
            HistoryPath(FRAME_HEIGHT: GRAPH_SIZE,
                        START_X: DOT_START_X,
                        HISTORY: history,
                        ADVANCE_INTERVAL: advanceBy,
                        Y_OFFSET: VERTICAL_OFFSET)
            
            // temporary slider for controlling movement of dot
            VStack {
                Spacer()
                
                HStack {
                    Text("Current Frequency:")
                    Text("\(String(format: "%.0f", currFreq)) Hz")
                        .frame(width: 100)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                }
                
                // for controlling y-coordinate through frequency
                Slider (value: $currFreq, in: 440...622.25)
                    .frame(width: 300)
                    .opacity(sliderOpacVal)
                    .onReceive([isRecording].publisher) { _ in
                        withAnimation {
                            sliderOpacVal = isRecording ? 1 : 0
                        }
                    }
                
                // for controlling y-coordinate directly
//                Slider (value: $yCoord, in: 0...GRAPH_SIZE)
//                    .frame(width: 300)
//                    .opacity(sliderOpacVal)
//                    .onReceive([isRecording].publisher) { _ in
//                        withAnimation {
//                            sliderOpacVal = isRecording ? 1 : 0
//                        }
//                    }
            }
        }
        .overlay(
            GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { value in
            screenSize = value
        }
    }
}

#Preview {
    PitchVisualizer()
//    NotesAxis(FRAME_HEIGHT: 300, START_X: 300, LANDSCAPE_OFFSET: 0, NUM_NOTES_IN_RANGE: 5)
}
