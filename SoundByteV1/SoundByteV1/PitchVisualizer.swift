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
 */

import SwiftUI

/*
 struct brings all the pieces together to create a graph of the
 current pitch sung by the user and the line representing the
 past pitches sung
 */
struct PitchVisualizer: View {
    // binding variables passed in by ContentView
    @Binding var _isRecording: Bool
    @Binding var _isStop: Bool
    
    @Binding var _selectedNote: String
    @Binding var _selectedOctave: Int
    
    // variables for seeing preview
//    @State var _isRecording: Bool   = true
//    @State var _isStop: Bool        = false
//    
//    @State var _selectedNote: String = "C"
//    @State var _selectedOctave: Int  = 5
    
    // state variables track changing parameters during execution
    @State private var _pitchHistory: [CGPoint]  = []
    @State private var _colorHistory: [Color]    = []
    @State private var _currFreq: Double         = 0.0
    @State private var _screenSize: CGSize       = .zero
    
    // state variables to allow dynamic graph size
    @State private var _numDataStored: Int       = 0
    @State private var _graphSize: Double        = 0.0
    @State private var _horizontalOffset: Double = 0.0
    @State private var _verticalOffset: Double   = 0.0
    
    // state variables to track how the graph is layed out and how the pitch indicator is positioned
    @State private var _mappedFreqs: [(note: String, pos: Double, freq: Double)] = []
    @State private var _positioning: (cents: Double, closestFrequency: Double)   = (0.0, 0.0)
    @State private var _pixelsPerCent: Double                                    = 0.0
    @State private var _indicatorPosY: Double                                    = 0.0
    
    // state variables track what notes are displayed on the graph
    @State private var _centerNote: (note: String, octave: Int)  = ("C", 5)  { didSet { updateGraphNoteAxis() } }
    @State private var _numNotesInRange: Int                     = 7         { didSet { updateGraphNoteAxis() } }
    
    // temporary parameter for slider
    @State private var sliderOpacVal: Double    = 1.0
    @State private var isFreqZero: Bool         = false
    
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
                frameHeight: _graphSize,
                vOffset: _verticalOffset,
                x: _horizontalOffset,
                mappedFreq: _mappedFreqs
            )
            
            HistoryPath(
                frameHeight: _graphSize,
                vOffset: _verticalOffset,
                coords: _pitchHistory,
                colors: _colorHistory
            )
            
            PitchIndicator(
                frameHeight: _graphSize,
                vOffset: _verticalOffset,
                x: _horizontalOffset,
                y: _indicatorPosY
            )
            
            // temporary slider for controlling movement of dot
            VStack {
                Spacer()
                
                HStack {
                    Text("Current Frequency:")
                    Text("\(String(format: "%.0f", _currFreq)) Hz")
                        .frame(width: 100)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                }
                
                // for controlling y-coordinate through frequency
                HStack {
                    Toggle("", isOn: $isFreqZero)
                        .frame(width: 50)
                        .padding()
                    Spacer()
                    Slider (value: $_currFreq, in: ((_mappedFreqs.first?.freq ?? 0) - 10)...((_mappedFreqs.last?.freq ?? 0) + 10))
                        .frame(width: 250)
                        .opacity(sliderOpacVal)
                        .padding()
                        .onReceive([_isRecording].publisher) { _ in
                            withAnimation {
                                sliderOpacVal = _isRecording ? 1 : 0
                            }
                    }
                }
            }
        }
        // on build of view, set the center note
        .onAppear() {
            _centerNote = (_selectedNote, _selectedOctave)
        }
        
        // when the timer fires, update neccessary variables
        .onReceive(TIMER) { _ in
            // temp code for setting frequency to zero
            if isFreqZero { _currFreq = 0.0 }
            
            if _isRecording {
                if currFreq != 0 { calculatePosition() }
                updateHistory()
                
            } else if _isStop {
                resetHistory()
                self._isStop.toggle()
            }
        }
        
        .overlay(
            GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        
        // when device orientation changes, remake the graph
        .onPreferenceChange(SizePreferenceKey.self) { value in
            _screenSize = value
            setUp()
            updateGraphNoteAxis()
        }
    }
    
    // sets parameters for the graph based off device orientation
    func setUp() {
        _numDataStored = Int(screenSize.width / SHIFT_BY)
        _graphSize = _screenSize.height / { verticalSizeClass == .compact ? 1.5 : 2 }()
        _horizontalOffset = _screenSize.width * { verticalSizeClass == .compact ? 7/8 : 3/4 }()
        _verticalOffset = { verticalSizeClass == .compact ? _screenSize.height / 15 : 0 }()
    }
    
    // updates the mapping of frequencies on the graph
    func updateGraphNoteAxis() {
        _mappedFreqs = GRAPH_MAPPER.mapToGraph(midNote: _centerNote, bounds: (0, _graphSize), numNotes: _numNotesInRange)
    }
    
    // calcuates the y-coordinate of the pitch indicator
    func calculatePosition() {
        _positioning = centsOff(freq1: _currFreq, freq: _mappedFreqs.map{ $0.2 })
        _pixelsPerCent = (_mappedFreqs[0].1 - _mappedFreqs[1].1) / 100
        _indicatorPosY = _mappedFreqs.first(where: { $0.2 == _positioning.closestFrequency})!.1 + (_pixelsPerCent * _positioning.cents)
    }
    
    // adds values to the history arrays
    func updateHistory() {
        if _pitchHistory.count > 0 {
            // limits the history arrays to 500 elements or less
            _pitchHistory = _pitchHistory[(_pitchHistory.count < _numDataStored ? 0 : 1)..._pitchHistory.count-1].map{ $0 }
            _colorHistory = _colorHistory[(_colorHistory.count < _numDataStored ? 0 : 1)..._colorHistory.count-1].map{ $0 }
            
            // subtracts a value from the x component of every point in this array
            _pitchHistory = _pitchHistory.map{ CGPoint(x: ($0.x - SHIFT_BY), y: $0.y) }
        }
        
        // append values to the history arrays
        _colorHistory.append(_currFreq != 0 ? calculateColor(centsOff: abs(_positioning.cents)) : .clear)
        _pitchHistory.append(CGPoint(x: _horizontalOffset, y: _indicatorPosY))
    }
    
    // makes the history arrays empty
    func resetHistory() {
        _pitchHistory = []
        _colorHistory = []
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
        
        // defines the RGB values for the colors in the gradient
        let START_COLOR = UIColor(.green)
        let MIDDLE_COLOR = UIColor(.yellow)
        let END_COLOR = UIColor(.red)
        
        let INTERPOLATE_COLOR: UIColor
        
        // determines what gradient to calculate
        if CENTS <= 35 {
            let FACTOR = CGFloat(CENTS / 35.0)
            INTERPOLATE_COLOR = UIColor.interpolate(from: START_COLOR, to: MIDDLE_COLOR, with: FACTOR)
        } else {
            let FACTOR = CGFloat((CENTS - 35) / 25.0)
            INTERPOLATE_COLOR = UIColor.interpolate(from: MIDDLE_COLOR, to: END_COLOR, with: FACTOR)
        }
                    
        return Color(INTERPOLATE_COLOR)
    }
    
    // Getters and setters
    internal var isRecording: Bool {
        get { return _isRecording }
        set { _isRecording = newValue }
    }
    internal var isStop: Bool {
        get { return _isStop }
        set { _isStop = newValue }
    }
    internal var pitchHistory: [CGPoint] {
        get { return _pitchHistory }
        set { _pitchHistory = newValue }
    }
    internal var colorHistory: [Color] {
            get { return _colorHistory }
            set { _colorHistory = newValue }
    }
    internal var currFreq: Double {
        get { return _currFreq }
        set { _currFreq = newValue }
    }
    internal var screenSize: CGSize {
        get { return _screenSize }
        set { _screenSize = newValue }
    }
    internal var numDataStore: Int {
        get { return _numDataStored }
        set { _numDataStored = newValue }
    }
    internal var graphSize: Double {
        get { return _graphSize }
        set { _graphSize = newValue }
    }
    internal var horizontalOffset: Double {
        get { return _horizontalOffset }
        set { _horizontalOffset = newValue }
    }
    internal var verticalOffset: Double {
        get { return _verticalOffset }
        set { _verticalOffset = newValue }
    }
    internal var mappedFreqs: [(note: String, pos: Double, freq: Double)] {
        get { return _mappedFreqs }
        set { _mappedFreqs = newValue }
    }
    internal var positioning: (cents: Double, closestFrequency: Double) {
        get { return _positioning }
        set { _positioning = newValue }
    }
    internal var pixelsPerCent: Double {
        get { return _pixelsPerCent }
        set { _pixelsPerCent = newValue }
    }
    internal var indicatorPosY: Double {
        get { return _indicatorPosY }
        set { _indicatorPosY = newValue }
    }
    internal var centerNote: (note: String, octave: Int) {
        get { return _centerNote }
        set { _centerNote = newValue }
    }
    internal var numNotesInRange: Int {
        get { return _numNotesInRange }
        set { _numNotesInRange = newValue }
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



//#Preview {
//    PitchVisualizer()
//}
