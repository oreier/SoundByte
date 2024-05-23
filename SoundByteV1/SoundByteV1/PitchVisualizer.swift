//
//  PitchVisualizer.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/20/24.
//

/*
 TO-DO:
 - Make changing orientations scale correctly for history line
 - Change the starting x location to be a certain distance off from the right side of the display
    -> The current method doesn't scale well to iPads
 - Figure out how to make a changing frequency call calculatePosition using didSet
 - Try to better understand how the onPreferenceChange modifier detects the orientation of the display
 - Organize all the files used for the pitch visualizer into one folder
 - Adjust color of line
 - Make work for when the frequency is zero
 */

import SwiftUI

/*
 struct brings all the pieces together to create a graph of the
 current pitch sung by the user and the line representing the
 past pitches sung
 */
struct PitchVisualizer: View {
    // binding variables passed in by ContentView
//    @Binding var isRecording: Bool
//    @Binding var isStop: Bool
//    
//    @Binding var selectedNote: String
//    @Binding var selectedOctave: Int
    
    // variables for seeing preview
    @State var isRecording: Bool   = true
    @State var isStop: Bool        = false
    
    @State var selectedNote: String = "C"
    @State var selectedOctave: Int  = 5
    
    // state variables track changing parameters during execution
    @State private var pitchHistory: [CGPoint]  = []
    @State private var colorHistory: [Color]    = []
    @State private var currFreq: Double         = 440.0
    @State private var screenSize: CGSize       = .zero
    
    // state variables to allow dynamic graph size
    @State private var graphSize: Double        = 0.0
    @State private var horizontalOffset: Double = 0.0
    @State private var verticalOffset: Double   = 0.0
    @State private var numDataStored: Int       = 0
    
    // state variables to track how the graph is layed out and how the pitch indicator is positioned
    @State private var mappedFreqs: [(note: String, pos: Double, freq: Double)] = []
    @State private var positioning: (cents: Double, closestFrequency: Double)   = (0.0, 0.0)
    @State private var pixelsPerCent: Double                                    = 0.0
    @State private var indicatorPosY: Double                                    = 0.0
    
    // state variables track what notes are displayed on the graph
    @State private var centerNote: (note: String, octave: Int)  = ("C", 5)  { didSet { updateGraphNoteAxis() } }
    @State private var numNotesInRange: Int                     = 12        { didSet { updateGraphNoteAxis() } }
    
    // temporary parameter for slider
    @State private var sliderOpacVal: Double    = 1.0
    
    // gets the orientation of the device
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // timer keeps track of sampling rate
    private let TIMER = Timer.publish(every: 0.015, on: .main, in: .common).autoconnect()
    
    // mapper to convert frequencies into y-coordinates
    private let GRAPH_MAPPER = FreqGraphMapper()
    
    // constants used to set various parameters
    private let RIGHT_MARGIN: Double        = 100.0
    private let SHIFT_BY: Double            = 1.5
    
    // constructs the whole graph
    var body: some View {
        ZStack {
            NoteAxis(
                frameHeight: graphSize,
                vOffset: verticalOffset,
                x: horizontalOffset,
                mappedFreq: mappedFreqs
            )
            
            HistoryPath(
                frameHeight: graphSize,
                vOffset: verticalOffset,
                coords: pitchHistory,
                colors: colorHistory
            )
            
            PitchIndicator(
                frameHeight: graphSize,
                vOffset: verticalOffset,
                x: horizontalOffset,
                y: indicatorPosY
            )
            
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
                Slider (value: $currFreq, in: ((mappedFreqs.first?.freq ?? 0) - 10)...((mappedFreqs.last?.freq ?? 0) + 10))
                    .frame(width: 300)
                    .opacity(sliderOpacVal)
                    .onReceive([isRecording].publisher) { _ in
                        withAnimation {
                            sliderOpacVal = isRecording ? 1 : 0
                        }
                    }
            }
        }
        // on build of view, set the center note
        .onAppear() {
            centerNote = (selectedNote, selectedOctave)
        }
        
        // when the timer fires, update neccessary variables
        .onReceive(TIMER) { _ in
            if isRecording {
                calculatePosition()
                updateHistory()
                
            } else if isStop {
                resetHistory()
                self.isStop.toggle()
            }
        }
        
        .overlay(
            GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        
        // when device orientation changes, remake the graph
        .onPreferenceChange(SizePreferenceKey.self) { value in
            screenSize = value
            setUp()
            updateGraphNoteAxis()
        }
    }
    
    // sets parameters for the graph based off device orientation
    func setUp() {
        graphSize = screenSize.height / { verticalSizeClass == .compact ? 1.25 : 1.5 }()
        horizontalOffset = screenSize.width * { verticalSizeClass == .compact ? 7/8 : 3/4 }()
        verticalOffset = { verticalSizeClass == .compact ? screenSize.height / 15 : 0 }()
        numDataStored = Int(screenSize.width / SHIFT_BY)
    }
    
    // updates the mapping of frequencies on the graph
    func updateGraphNoteAxis() {
        mappedFreqs = GRAPH_MAPPER.mapToGraph(midNote: centerNote, bounds: (0, graphSize), numNotes: numNotesInRange)
    }
    
    // calcuates the y-coordinate of the pitch indicator
    func calculatePosition() {
        positioning = centsOff(freq1: currFreq, freq: mappedFreqs.map{ $0.2 })
        pixelsPerCent = (mappedFreqs[0].1 - mappedFreqs[1].1) / 100
        indicatorPosY = mappedFreqs.first(where: { $0.2 == positioning.closestFrequency})!.1 + (pixelsPerCent * positioning.cents)
    }
    
    // adds values to the history arrays
    func updateHistory() {
        if pitchHistory.count > 0 {
            // limits the history arrays to 500 elements or less
            pitchHistory = pitchHistory[(pitchHistory.count < numDataStored ? 0 : 1)...pitchHistory.count-1].map{ $0 }
            colorHistory = colorHistory[(colorHistory.count < numDataStored ? 0 : 1)...colorHistory.count-1].map{ $0 }
            
            // subtracts a value from the x component of every point in this array
            pitchHistory = pitchHistory.map{ CGPoint(x: ($0.x - SHIFT_BY), y: $0.y) }
        }
        
        // append values to the history arrays
        colorHistory.append(calculateColor(centsOff: abs(positioning.cents)))
        pitchHistory.append(CGPoint(x: horizontalOffset, y: indicatorPosY))
    }
    
    // makes the history arrays empty
    func resetHistory() {
        pitchHistory = []
        colorHistory = []
    }
    
    // calculates the cents off a frequency is from it's closest note
    func centsOff(freq1: Double, freq: [Double]) -> (cents: Double, closestFrequency: Double) {
        if freq1 == 0 { return (-1, 0) }
        
        let FREQ2 = freq.min { abs($0 - freq1) < abs($1 - freq1) } ?? 0
        let CENTS = 1200 * log2(FREQ2 / freq1)
        
        return (CENTS, FREQ2)
    }
    
    // calculates the color the line should be when off by a certain amount of cents
    func calculateColor(centsOff: Double) -> Color {
        let CENTS = min(max(centsOff, 0), 50)
        let FACTOR = Double(CENTS / 50)
        
        // Define the RGB values for the colors in the gradient
        let startColor = UIColor(.green)
        let middleColor = UIColor(red: 189.0/255.0, green: 173.0/255.0, blue: 3.0/255.0, alpha: 1.0)
        let endColor = UIColor(.red)
        
        let interpolateColor = UIColor.interpolate(from: startColor, to: endColor, with: FACTOR)
        
        return Color(interpolateColor)
    }
}

extension UIColor {
    static func interpolate(from startColor: UIColor, to endColor: UIColor, with factor: CGFloat) -> UIColor {
        var startRed: CGFloat = 0, startGreen: CGFloat = 0, startBlue: CGFloat = 0, startAlpha: CGFloat = 0
        var endRed: CGFloat = 0, endGreen: CGFloat = 0, endBlue: CGFloat = 0, endAlpha: CGFloat = 0
        
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
        
        let interpolatedRed = startRed + (endRed - startRed) * factor
        let interpolatedGreen = startGreen + (endGreen - startGreen) * factor
        let interpolatedBlue = startBlue + (endBlue - startBlue) * factor
        let interpolatedAlpha = startAlpha + (endAlpha - startAlpha) * factor
        
        return UIColor(red: interpolatedRed, green: interpolatedGreen, blue: interpolatedBlue, alpha: interpolatedAlpha)
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

#Preview {
    PitchVisualizer()
}
