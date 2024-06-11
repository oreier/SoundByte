//
//  VisualizerView.swift
//  SoundByte 2.0
//
//  Created by Jack Durfee on 5/28/24.
//

/*
 TO-DO:
 - Calcuate the correct color
 - Build the imgae of the key with current tools
 - Add note names
 - Fix bug: When you put the app into the background and then try recording after reopening it, it stops after a second
 - Add cents mini display and make it togglable
 - Add functionality for portrait mode
 */

import SwiftUI

// dummy struct to be able to use the same variable names for recording mode
struct Dummy {
    struct DummyData {
        var pitch = 440.0
    }
    
    var data = DummyData()
    
    func start() {}
    func stop() {}
}

// spacings and dimensions used by many views
struct UILayout {
    // dimensions of the UI
    var width: CGFloat
    var height: CGFloat
    
    let ledgerLineWidth = 40.0
    let lineThickness = 2.5
    
    // white space in the staff
    let whiteSpace = 18.5 // padding above and below each line
    var spaceBetweenLines: CGFloat
    var spaceBetweenNotes: CGFloat
    
    // staff dimensions
    var staffWidth: CGFloat
    var staffHeight: CGFloat
    var endOfAccidentals: CGFloat = 0
    
    var ledgerOffset: CGFloat
    
    // pitch indicator parameters
    var indicatorX: CGFloat
    var indicatorY: CGFloat
    
    var centerNoteLocationY: CGFloat

    // calculates the initial values for variables in the struct based off the width and height
    init(width: CGFloat = 0, height: CGFloat = 0) {
        self.width = width
        self.height = height
        
        // set calculated values based off given space
        self.spaceBetweenNotes = (whiteSpace + lineThickness / 2)
        self.spaceBetweenLines = (2 * whiteSpace + lineThickness)
        
        self.staffWidth = width * (9 / 10)
        self.staffHeight = spaceBetweenLines * 4
        
        self.ledgerOffset = staffWidth * (5 / 7)
        
        self.indicatorX = staffWidth * (5 / 7) + ledgerLineWidth / 2
        self.indicatorY = height / 2
        
        self.centerNoteLocationY = height / 2
    }
}

// holds the history arrays used for displaying previous frequencies
struct History {
    var points: [CGPoint] = []
    var colors: [Color] = []
    
    // resets the history arrays
    mutating func reset() {
        points = []
        colors = []
    }
    
    // combines the history arrays into one for the history view
    func combine() -> [(CGFloat, Color)] {
        // ensures that both arrays contain the same number of elements
        guard points.count == colors.count else { fatalError() }
        
        var combined: [(CGFloat, Color)] = []
        
        // combines both history arrays into [(yPos, color)]
        for (point, color) in zip(points, colors) {
            combined.append((point.y, color))
        }
        
        return combined
    }
}

// visualizer brings together all of the individual visual elements
struct VisualizerView: View {
//    @ObservedObject var conductor = TunerConductor() // observed object for collecting and processing audio data
    @State var conductor = Dummy() // dummy variable for ease of viewing in preview
    
    // object holds all of the user preferences
    @StateObject var userSettings = UserSettings()
    
    @State var goToSettings = false // tracks when the app needs to go to the settings view
    @State var isRecording = false // tracks when the app is recording
    
    // variables to control the timer
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    
    // layout is determined by the parent view
    @State var layout: UILayout
    
    // variables for storing the current mapping
    @State var currentMapping: [Double : Double] = [:]
    @State var sortedFrequencies: [Double] = []
    @State var cents = 0.0
    
    // history struct to visualize past frequencies
    @State var history = History()
        
    // sets the number of data elements to display in the pitch history line
    @State var maxData = 0
    
    // tracks the life cycle of the app (sent to background or inactive)
    @Environment(\.scenePhase) var scenePhase
    
    // variable tracks if we are running in the preview or on an actual device
    var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    let shiftBy = 2.0 // size of each "mini" path in the history line
    let buttonSize = 35.0 // size of the buttons
    let backgroundColor = Color(red: 250 / 255, green: 248 / 255, blue: 243 / 255) // color of the background
        
    // sets up the layout given parent view dimensions
    init(width: CGFloat, height: CGFloat) {
        self.layout = UILayout(width: width, height: height)
    }

    // pulls together all of the visual elements into one view
    var body: some View {
        
        // navigation stack allows us to move to the settings page
        NavigationStack {
            
            // zstack allows visual elements to be stacked on top of each other
            ZStack {
                
                // displays the staff
                Staff(clef: userSettings.clef, key: userSettings.key, layout: layout)
                
                // displays live indicators when recording is in progress
                if isRecording {
                    // displays the history line
                    let startIndex = max(0, (history.points.count-maxData))
                    let points = Array(history.points[startIndex...])
                    let colors = Array(history.colors[startIndex...])
                    
                    HistoryPath(points: points, colors: colors, xStart: layout.indicatorX)
                    
                    // displays the pitch indicator
                    PitchIndicator(x: layout.indicatorX, y: layout.indicatorY)
                }
                
                // displays the scroll view when recording is paused
                if !isRecording {
                    HistoryView(history: history.combine(), shift: shiftBy, layout: layout)
                    
                        // positions the history view so that it's trailing edge aligns with the pitch indicator
                        .position(x: layout.indicatorX - (layout.indicatorX - layout.endOfAccidentals) / 2, y: layout.height / 2)
                }
                
                // vstack displays tool bar elements
                VStack(alignment: .trailing) {
                    
                    // first hstack displays top tool bar buttons
                    HStack(spacing: buttonSize) {
                        
                        Spacer() // moves tool bar buttons to the right
                        
                        // pause and play button
                        Button(action: isRecording ? pauseRecording : startRecording) {
                            Image(systemName: isRecording ? "pause.fill" : "play.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: isRecording ? buttonSize * 0.85 : buttonSize)
                                .foregroundStyle(isRecording ? Color.red : Color.green)
                        }
                        
                        // stop button
                        Button(action: stopRecording) {
                            Image(systemName: "stop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: buttonSize)
                                .foregroundStyle(Color.primary)
                        }
                        
                        // settings button
                        Button(action: { pauseRecording(); goToSettings.toggle() }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: buttonSize)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                                        
                    Spacer() // moves tool bar buttons to the top and timer to the bottom
                    
                    // second hstack displays the timer
                    HStack {
                        
                        // temporary slider and text for controlling preview
                        Slider(value: $conductor.data.pitch, in: (200...1100))
                            .frame(width: 200)
                        Text("Freq: " + String(format:"%.0f", conductor.data.pitch))
                        
                        Spacer() // moves timer display to the right
                        
                        TimerDisplay(time: elapsedTime, size: buttonSize, isRecording: $isRecording)
                    }
                }
                .padding([.top, .bottom, .trailing]) // padding applies to the tool bar
            }
            .background(backgroundColor)

            // sets up important variables when view apears
            .onAppear() {
                updateMapping()
                updateMaxData()
            }
            
            // pauses the timer when the app is sent to the background
            .onChange(of: scenePhase) {
                if (scenePhase == .background && !isPreview) {
                    pauseRecording()
                }
            }
            
            // navigates to settings view when gear icon is pressed
            .navigationDestination(isPresented: $goToSettings) {
                SettingsView(userSettings: userSettings)
            }
//            .navigationDestination(isPresented: $goToSettings) {
//                 SettingsView(userSettings: userSettings, device: conductor.initialDevice)
//            }
        }
    }
    
    // calculates the cents off a frequency is from it's closest note
    func calculateCents(currentFrequency: Double, frequencies: [Double]) -> (cents: Double, closestFrequency: Double, step: Int) {
        if currentFrequency == 0 { return (-1, 0, 1) }
        
        // finds the closest frequency and index of that frequency
        let closestFrequency = frequencies.min { abs($0 - currentFrequency) < abs($1 - currentFrequency) } ?? 0
        let closestFrequencyIndex = frequencies.firstIndex(of: closestFrequency) ?? 1
        
        // finds the cents off the current frequency is from the closest freqencu
        let cents = 1200 * log2(closestFrequency / currentFrequency)
        
        // finds the second closest frequency using the cents calculated and the index of the closest frequency
        var secondClosestFrequencyIndex = 0
        
        // sets the index of the second frequency manually if it's going to be out of bounds
        if closestFrequencyIndex == 0 {
            secondClosestFrequencyIndex = closestFrequencyIndex + 1
        } else if closestFrequencyIndex == frequencies.count - 1 {
            secondClosestFrequencyIndex = closestFrequencyIndex - 1
        } else {
            secondClosestFrequencyIndex = (closestFrequencyIndex) + ((cents > 0) ? -1 : 1)
        }
        
        let secondClosestFrequency = frequencies[secondClosestFrequencyIndex]
                
        // calculates the number of half steps between the closest frequency and the current frequency
        let step = Int(round(abs(log2(closestFrequency / secondClosestFrequency) * 12)))
        
        return (cents, closestFrequency, step)
    }
    
    // calculates the color the line should be when off by a certain amount of cents
    func calculateColor(centsOff: Double) -> Color {
        let cents = min(max(centsOff, 0), 50)
        
        // defines the RGB values for the colors in the gradient
        let startColor = UIColor(.green)
        let middleColor = UIColor(.yellow)
        let endColor = UIColor(.red)
        
        let interpolateColor: UIColor
        
        // determines what gradient to calculate
        if cents <= 35 {
            let factor = CGFloat(cents / 35.0)
            interpolateColor = UIColor.interpolate(from: startColor, to: middleColor, with: factor)
        } else {
            let factor = CGFloat((cents - 35) / 25.0)
            interpolateColor = UIColor.interpolate(from: middleColor, to: endColor, with: factor)
        }
                    
        return Color(interpolateColor)
    }

    // calculates the y position that the pitch indicator should be at
    func calculatePosition(_ pitch: CGFloat) -> CGFloat {
        // if the current pitch is zero return the previous position the indicator was at
        if pitch == 0 {
            // defaults to center if there is no history
            guard let previousPitch = history.points.last?.y else {
                return layout.height / 2
            }
            
            return previousPitch
        }
        
        // calculate positioning given the current frequency
        let positioning = calculateCents(currentFrequency: Double(pitch), frequencies: sortedFrequencies)
        
        // breaks down the positioning into its individual components
        cents = positioning.cents
        let closestFrequency = positioning.closestFrequency
        let step = positioning.step
        
        // calculates the number of pixels there are between each whitespace
        let pixelsPerCent = layout.spaceBetweenNotes / Double(100 * step)
        
        return (currentMapping[closestFrequency]! + (cents * pixelsPerCent))
    }
    
    // adds values to the history arrays
    func updateHistory(pitch: Double, cents: Double) {
        let startIndex = max(0, (history.points.count-maxData))
        
        // subtracts the shift from x points in the points array
        for i in startIndex..<history.points.count {
            history.points[i].x -= shiftBy
        }
        
        layout.indicatorY = calculatePosition(pitch)
        
        // adds new values to the history arrays
        let newPoint = CGPoint(x: layout.indicatorX, y: layout.indicatorY)
        let newColor = (pitch == 0) ? .clear : calculateColor(centsOff: cents)
        history.points.append(newPoint)
        history.colors.append(newColor)
    }
    
    // sets up the current mapping based off the user-selected key
    func updateMapping() {
        let newMapper = NotesToGraphMapper()
        
        // sets the middle note of the mapping based on the clef
        switch userSettings.clef {
        case .treble:
            newMapper.centerNote = userSettings.key.centerNoteTreble ?? Note(note: "B", octave: 4)
        case .octave:
            newMapper.centerNote = userSettings.key.centerNoteOctave ?? Note(note: "B", octave: 3)
        case .bass:
            newMapper.centerNote = userSettings.key.centerNoteBass ?? Note(note: "D", octave: 3)
        }
                
        newMapper.centerNotePosition = layout.centerNoteLocationY // position of the center note
        newMapper.notesInKey = userSettings.key.notes // notes in the current key
        newMapper.numNotes = 17 // the maximum number of notes displayed will always be 17
        newMapper.spacing = layout.spaceBetweenNotes // spacing bewteen each note
        
        currentMapping = newMapper.mapNotes()
        sortedFrequencies = currentMapping.keys.sorted()
    }
    
    // calcualtes the amount of data that should be stored based off the key signature
    func updateMaxData() {
        // determines the clef settings to use
        var clefSettings: ClefSettings
        switch userSettings.clef {
        case .treble:
            clefSettings = TrebleClefSettings()
        case .octave:
            clefSettings = OctaveClefSettings()
        case .bass:
            clefSettings = BassClefSettings()
        }
        
        // determines the accidental to use
        var accidentalSettings: AccidentalSettings
        if userSettings.key.numSharps > 0 {
            accidentalSettings = SharpSettings(numAccidentals: userSettings.key.numSharps)
        } else {
            accidentalSettings = FlatSettings(numAccidentals: userSettings.key.numFlats)
        }
        accidentalSettings.displayOrder = userSettings.key.numSharps > 0 ? clefSettings.sharpsOrder : clefSettings.flatsOrder
        
        // calculates the amount of space available to display the history line
        layout.endOfAccidentals = clefSettings.imageWidth + (Double(accidentalSettings.numAccidentals) * accidentalSettings.imageWidth)
        let availableSpace = layout.indicatorX - layout.endOfAccidentals
        maxData = Int(availableSpace) / Int(shiftBy)
    }
    
    // starts recording audio
    func startRecording() {
        self.isRecording = true
        
        // start timing and recording
        playTimer()
        conductor.start()
    }
    
    // pauses recording audio
    func pauseRecording() {
        self.isRecording = false
        
        // stop timing and recording
        pauseTimer()
        conductor.stop()
    }
    
    // stops recording audio and resets history
    func stopRecording() {
        // only need to pause recording / timer if that's the current state
        if isRecording {
            self.isRecording = false
            pauseTimer()
        }
        
        // reset history and stop recording
        history.reset()
        elapsedTime = 0
        conductor.stop()
    }
    
    // starts the timer
    func playTimer() {
        let increment = 0.02
        
        // creates timer that updates with a specified increment
        timer = Timer.scheduledTimer(withTimeInterval: increment, repeats: true) { _ in
            updateHistory(pitch: Double(conductor.data.pitch), cents: cents)
            elapsedTime += increment
        }
    }
    
    // pauses the timer
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// extension allows us to calculate a color gradient (chat wrote this)
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

#Preview {
    VisualizerView(width: 734, height: 372)
}
