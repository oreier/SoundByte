//
//  PitchVisualizer.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/20/24.
//

/*
 TO-DO:
 - Make changing orientations scale correctly for history line
 - Add axis labels
 - Make axis generic so that it can be scaled
 - Have the slider be frequencies and transform frequencies to fit the graph
    -> Remember, this is not a linear scale so we will have to account for that
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
    let Y_OFFSET: Double
    
    // constants determine the size of the bars
    private let MAIN_BAR_WIDTH: Double = 5.0
    private let SUB_BAR_HEIGHT: Double = 2.5
    
    // constructs the notes axis
    var body: some View {
        // array to place horizontal bars
        let OFFSET_ARRAY: [Double] = Array(stride(from: 0, through: FRAME_HEIGHT, by: 40))
        
        GeometryReader { proxy in
            // vertical bar on the right
            RoundedRectangle(cornerRadius: 25.0, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .frame(width: MAIN_BAR_WIDTH, height: FRAME_HEIGHT)
                .offset(x: START_X + 25)
            
            // builds each horizontal bar for each of the offsets
            ForEach(OFFSET_ARRAY, id:\.self) { offset in
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: .continuous)
                    .frame(width: START_X + 50, height: SUB_BAR_HEIGHT)
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
                    .offset(y: offset)
            }
        }
        .frame(height: FRAME_HEIGHT)
        .offset(y: Y_OFFSET)
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
    @Binding var isRecording: Bool
    @Binding var isStop: Bool
    
    // variables for seeing preview
//    @State var isRecording: Bool   = true
//    @State var isStop: Bool        = false
    
    // state variables to track various aspects of the live indicator and history line
    @State private var screenSize: CGSize = .zero
    @State private var yCoord: Double = 0
    @State private var history: [Double] = []
    @State private var advanceBy: Double = 2
    @State private var sliderOpacVal: Double = 1.0
    
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
            NotesAxis(FRAME_HEIGHT: GRAPH_SIZE, START_X: DOT_START_X, Y_OFFSET: VERTICAL_OFFSET)
            
            // indicator records information to the history array every time the timer object fires and resets the array when recording is stopped
            IndicatorDot(FRAME_HEIGHT: GRAPH_SIZE, DOT_X: DOT_START_X, DOT_Y: yCoord, Y_OFFSET: VERTICAL_OFFSET)
                .onReceive(TIMER) { _ in
                    if isRecording {
                        history.append(yCoord)
                    } else if isStop {
                        history = []
                        self.isStop.toggle()
                    }
                }
            
            // history path
            HistoryPath(FRAME_HEIGHT: GRAPH_SIZE, START_X: DOT_START_X, HISTORY: history, ADVANCE_INTERVAL: advanceBy, Y_OFFSET: VERTICAL_OFFSET)
            
            // temporary slider for controlling movement of dot
            VStack {
                Spacer()
                
                Slider (value: $yCoord, in: 0...GRAPH_SIZE)
                    .frame(width: 300)
                    .opacity(sliderOpacVal)
                    .onReceive([isRecording].publisher) { _ in
                        withAnimation {
                            sliderOpacVal = isRecording ? 1 : 0
                        }
                    }
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

//#Preview {
//    PitchVisualizer()
//}
