//
//  VisualizerView.swift
//  SoundByte 2.0
//
//  Created by Jack Durfee on 5/28/24.
//

/*
 TO-DO:
 - Refactor settings page (remove numSharps and numFlats as a user setting)
 - Calculate the correct number of elements to store
 - Refactor code so that there aren't as many state variables by using settings variables directly
 - Calcuate the correct color
 - Condense currentMapping and the sorted frequencies list into one tuple for conciseness
 - Add tap to start
 - Add scroll view
 - Add functionallity for external microphones
 - Build the imgae of the key with current tools
 - Give default values for when the app first launches (minor is selected at start)
 - Add note names
 - Fix bug: When you put the app into the background and then try recording after reopening it, it stops after a second
 - Move navigation to settings page code into content view
 - Add cents mini display
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
struct Spacing {
    let ledgerLineWidth = 40.0
    let lineThickness = 2.5
    let whiteSpace = 18.5 // white space above and below each line
    
    // the space inherited from the parent view by the child view
    var spaceWidth: Double
    var spaceHeight: Double
    
    // white space in the staff
    var whiteSpaceBetweenLines: Double
    var whiteSpaceBetweenNotes: Double
    
    // staff dimensions
    var staffWidth: Double
    var staffHeight: Double
    
    var ledgerOffset: Double
    
    // pitch indicator parameters
    var indicatorX: Double
    var indicatorY: Double
    
    var centerNoteLocationY: Double
    
    // initializer for a spacing struct
    init(width: Double = 0, height: Double = 0) {
        // set trivial parameters
        self.spaceWidth = width
        self.spaceHeight = height
        
        // set calculated values based off given space
        self.whiteSpaceBetweenNotes = (whiteSpace + lineThickness / 2)
        self.whiteSpaceBetweenLines = (2 * whiteSpace + lineThickness)
        
        self.staffWidth = spaceWidth * (9 / 10)
        self.staffHeight = whiteSpaceBetweenLines * 4
        
        self.ledgerOffset = staffWidth * (5 / 7)
        
        self.indicatorX = staffWidth * (5 / 7) + ledgerLineWidth / 2
        self.indicatorY = spaceHeight / 2
        
        self.centerNoteLocationY = spaceHeight / 2
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
    
    // variables to control and display the timer
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    
    // spacing is determined by the parent view
    @State var spacing: Spacing
    
    @State var currentMapping: [Double : Double] = [:]
    @State var currentFrequenciesSorted: [Double] = []
    @State var cents = 0.0
    
    // history arrays to be able to draw the pitch history line
    @State var pitchHistory: [CGPoint] = []
    @State var colorHistory: [Color] = [.clear] // starts with a clear line so there isn't a huge jump at the start of recording
        
    // constants for various parameters in the view
    @State var numDataStored = 250
    
    // tracks the life cycle of the app (sent to background or inactive)
    @Environment(\.scenePhase) var scenePhase
    
    // variable tracks if we are running in the preview or on an actual device
    var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    let shiftBy = 1.0
    let buttonSize = 35.0
    let backgroundColor = Color(red: 250 / 255, green: 248 / 255, blue: 243 / 255)
        
    // constructor for visualizer view that sets up the spacing based off parent view size (defaults are for iPhone 15 Pro)
    init(width: Double, height: Double) {
        self.spacing = Spacing(width: width, height: height)
    }

    // pulls together all of the visual elements into one view
    var body: some View {
        
        NavigationStack {
            
            // zstack allows visual elements to be stacked on top of each other
            ZStack {
                
                // displays the staff
                Staff(clef: userSettings.clefType, key: userSettings.selectedKey, spacing: spacing)
                
                // displays the line coming out of the indicator dot
                HistoryPath(coordinates: pitchHistory, colors: colorHistory, xStart: spacing.indicatorX)
                
                // displays the pitch indicator for viewing in preview
                PitchIndicator(x: spacing.indicatorX, y: spacing.indicatorY)
                    .onChange(of: conductor.data.pitch) {
                        spacing.indicatorY = calculatePosition(from: Double(conductor.data.pitch))
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
                    
                    CentsIndicator(cents: cents)
                    
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
                setUpMapping()
                                
                numDataStored = Int((spacing.indicatorX - 100 - 0*20) / shiftBy)
            }
            
            // pauses the timer when the app is exited
            .onReceive([scenePhase].publisher) { _ in
                if (scenePhase == .background && isRecording && !isPreview) { pauseRecording() }
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

    // sets up the current mapping based off the user-selected key
    func setUpMapping() {
        let newMapper = NotesToGraphMapper()
        
        // sets the middle note of the mapping based on the clef
        switch userSettings.clefType {
        case .treble:
            newMapper.centerNote = userSettings.selectedKey.centerNoteTreble ?? Note(note: "B", octave: 4)
        case .octave:
            newMapper.centerNote = userSettings.selectedKey.centerNoteOctave ?? Note(note: "B", octave: 3)
        case .bass:
            newMapper.centerNote = userSettings.selectedKey.centerNoteBass ?? Note(note: "D", octave: 3)
        }
                
        newMapper.centerNotePosition = spacing.centerNoteLocationY // position of the center note
        newMapper.notesInKey = userSettings.selectedKey.notes // notes in the current key
        newMapper.numNotes = 17 // the maximum number of notes displayed will always be 17
        newMapper.spacing = spacing.whiteSpaceBetweenNotes // spacing bewteen each note
        
        currentMapping = newMapper.mapNotes()
        currentFrequenciesSorted = currentMapping.keys.sorted()
    }
    
    // calculates the cents off a frequency is from it's closest note
    func centsOff(currentFrequency: Double, frequencies: [Double]) -> (cents: Double, closestFrequency: Double, step: Double) {
        if currentFrequency == 0 { return (-1, 0, 1) }
        
        // finds the closest frequency and index of that frequency
        let closestFrequency = frequencies.min { abs($0 - currentFrequency) < abs($1 - currentFrequency) } ?? 0
        let closestFrequencyIndex = frequencies.firstIndex(of: closestFrequency) ?? 1
        
        // finds the cents off the current frequency is from the closest freqencu
        let cents = 1200 * log2(closestFrequency / currentFrequency)
        
        // finds the second closest frequency using the cents calculated and the index of the closest frequency
        var secondClosestFrequencyIndex = 0
        
        if closestFrequencyIndex == 0 {
            secondClosestFrequencyIndex = closestFrequencyIndex + 1
        } else if closestFrequencyIndex == frequencies.count - 1 {
            secondClosestFrequencyIndex = closestFrequencyIndex - 1
        } else {
            secondClosestFrequencyIndex = (closestFrequencyIndex) + ((cents > 0) ? -1 : 1)
        }
        
        let secondClosestFrequency = frequencies[secondClosestFrequencyIndex]
                
        // calculates the number of half steps between the closest frequency and the current frequency
        let step = abs(log2(closestFrequency / secondClosestFrequency) * 12)
        
        return (cents, closestFrequency, step)
    }
    
    // calculates the y position that the pitch indicator should be at
    func calculatePosition(from frequency: Double) -> Double {
        // if the current frequency is zero return the previous position the indicator was at
        if frequency == 0 {
            // if there is no previous position, the note is centered
            return Double(pitchHistory.first?.y ?? spacing.spaceHeight / 2)
        }
        
        // otherwise calculate the position the note should be at given the current frequency
        let positioning = centsOff(currentFrequency: Double(frequency), frequencies: currentFrequenciesSorted)
        
        // breaks down the positioning into its individual components
        cents = positioning.cents
        let closestFrequency = positioning.closestFrequency
        let step = round(positioning.step)
        
        // calculates the number of pixels there are between each whitespace
        let pixelsPerCent = spacing.whiteSpaceBetweenNotes / Double(100 * step)
        
        return (frequency != 0) ? (currentMapping[closestFrequency]! + (cents * pixelsPerCent)) : 0
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
    
    // adds values to the history arrays
    func updateHistory(with frequency: Double) {
        if pitchHistory.count > 0 {
            // limits the history arrays to the first numDataStored elements
            pitchHistory = pitchHistory[(pitchHistory.count < numDataStored ? 0 : 1)...pitchHistory.count-1].map{ $0 }
            colorHistory = colorHistory[(colorHistory.count < numDataStored ? 0 : 1)...colorHistory.count-1].map{ $0 }
            
            // subtracts a value from the x component of every point in this array
            pitchHistory = pitchHistory.map{ CGPoint(x: ($0.x - shiftBy), y: $0.y) }
        }
        
        // append values to the front of the history arrays
        pitchHistory.append(CGPoint(x: spacing.indicatorX, y: calculatePosition(from: frequency)))
        colorHistory.append(frequency == 0 ? .clear : calculateColor(centsOff: cents)) // adds clear if the frequency is zero
    }
    
    // starts recording audio
    func startRecording() {
        // set isRecording state variable to true
        self.isRecording = true
        
        // start the recording process
        conductor.start()
                
        // play the timer
        playTimer()
    }
    
    // pauses recording audio
    func pauseRecording() {
        // set isRecording state variable to false
        self.isRecording = false
        
        // stop the recording process
        conductor.stop()
        
        // pause the timer
        pauseTimer()
    }
    
    // stops the timer and recording session (used to reset elapsed time and history arrays)
    func stopRecording() {
        // if we are currently recording, set isRecording to false and pause the timer
        if isRecording {
            self.isRecording = false
            pauseTimer()
        }
        
        // always stop the conductor, and reset the timer and history arrays
        conductor.stop()
        elapsedTime = 0
        pitchHistory = []
        colorHistory = []
    }
    
    // starts the timer and increments it by 0.01 of a second
    func playTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            elapsedTime += 0.01
            updateHistory(with: Double(conductor.data.pitch)) // collects data for the history arrays
        }
    }
    
    // pauses the timer at the time it is at
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
