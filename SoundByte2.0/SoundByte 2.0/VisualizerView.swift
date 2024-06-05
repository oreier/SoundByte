//
//  VisualizerView.swift
//  SoundByte 2.0
//
//  Created by Jack Durfee on 5/28/24.
//

import SwiftUI

// spacings and dimensions used by many views
struct Spacing {
    let ledgerLineWidth = 40.0
    let lineThickness = 2.5
    let whiteSpace = 18.5 // white space above and below each line
    
    var spaceWidth: Double
    var spaceHeight: Double
    
    var whiteSpaceBetweenLines: Double
    var whiteSpaceBetweenNotes: Double
    
    var staffWidth: Double
    var staffHeight: Double
    
    var ledgerOffset: Double
    
    var indicatorX: Double
    var indicatorY: Double
    
    var centerNoteLocationY: Double
    
    init(width spaceWidth: Double = 0, height spaceHeight: Double = 0) {
        self.spaceWidth = spaceWidth
        self.spaceHeight = spaceHeight
        
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

struct DummyData {
    var pitch = 440.0
}

struct Dummy {
    var data = DummyData()
    
    func start() {}
    func stop() {}
}

// visualizer brings together all of the individual visual elements
struct VisualizerView: View {
    // observed object for collecting and processing audio data
//    @ObservedObject var conductor = TunerConductor()
    @State var conductor = Dummy()
    
    // state variable tracks when the app is recording
    @State var isRecording = false
    
    // variables to control the timer
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    
    // important variables for setting up the view
    @State var currentClef = "treble"
    @State var currentKey = Key()
    @State var spacingData = Spacing()
    @State var currentMapping: [Double : Double] = [:]
    @State var sortedFrequencies: [Double] = []
    @State var cents = 0.0
    
    // history arrays to draw history line
    @State var pitchHistory: [CGPoint] = []
    @State var colorHistory: [Color] = [.clear] // starts with a clear line so there isn't a huge jump at the start of recording
        
    // constants for various parameters in the view
    @State var numDataStored = 250
    let shiftBy = 5.0
    let buttonSize = 35.0
    
    let screenWidth: Double
    let screenHeight: Double
    
    let backgroundColor = Color(red: 250 / 255, green: 248 / 255, blue: 243 / 255)
    
    @State var tempArr: [Double] = []
    
    // constructor for visualizer view that sets screen size
    init(width screenWidth: Double = 734, height screenHeight: Double = 372) {
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
    }

    // pulls together all of the visual elements into one view
    var body: some View {
        
        // zstack allows visual elements to be stacked on top of each other
        ZStack {
            
            // displays the staff
            Staff(clef: currentClef, keyData: currentKey.data, spacing: spacingData)
    
            // displays the pitch indicator for viewing in preview
            PitchIndicator(x: spacingData.indicatorX, y: spacingData.indicatorY)
                .onChange(of: conductor.data.pitch) {
                    spacingData.indicatorY = calculatePosition(from: Double(conductor.data.pitch))
                }
            
            // displays the line coming out of the indicator dot
            HistoryPath(coordinates: pitchHistory, colors: colorHistory, start: spacingData.indicatorX)
            
            // vstack displays tool bar elements
            VStack(alignment: .trailing) {
                
                // first hstack displays top tool bar buttons
                HStack(spacing: buttonSize) {
                    
                    // pause and play button
                    Button(action: toggleRecording) {
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
                    Button(action: openSettings) {
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
                    
                    Spacer() // moves temporary slider to the left and timer to the right
                    
//                    InputDevicePicker(device: conductor.initialDevice)
                    TimerDisplay(time: elapsedTime, size: buttonSize, isRecording: $isRecording)
                }
            }
            .padding([.top, .bottom, .trailing]) // padding applies to the tool bar
        }
        .background(backgroundColor)
        .onAppear() { // sets up key, spacing and mapping when view apears
            currentKey = Key(numFlats: 0, isMajor: true)
            spacingData = Spacing(width: screenWidth, height: screenHeight)
            currentMapping = generateMapping()
            sortedFrequencies = currentMapping.keys.sorted()
            numDataStored = Int((spacingData.indicatorX - 100 - 0*20) / shiftBy)
        }
    }
    
    // calculates the y position that the pitch indicator should be at
    func calculatePosition(from frequency: Double) -> Double {
        // if the current frequency is zero return the previous position the indicator was at
        if frequency == 0 {
            // if there is no previous position, the note is centered
            return Double(pitchHistory.first?.y ?? spacingData.spaceHeight / 2)
        }
        
        // otherwise calculate the position the note should be at given the current frequency
        let positioning = centsOff(currentFrequency: Double(frequency), frequencies: sortedFrequencies)
        
        // breaks down the positioning into its individual components
        cents = positioning.cents
        let closestFrequency = positioning.closestFrequency
        let step = round(positioning.step)
        
        // calculates the number of pixels there are between each whitespace
        let pixelsPerCent = spacingData.whiteSpaceBetweenNotes / Double(100 * step)
        
        return (frequency != 0) ? (currentMapping[closestFrequency]! + (cents * pixelsPerCent)) : 0
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
        pitchHistory.append(CGPoint(x: spacingData.indicatorX, y: calculatePosition(from: frequency)))
        colorHistory.append(frequency == 0 ? .clear : calculateColor(centsOff: cents)) // adds clear if the frequency is zero
    }
    
    // generates a mapping of frequencies to positions stored in a dictionary [frequency : position]
    func generateMapping() -> [Double : Double] {
        let newMapper = NotesToGraphMapper()
        
        // sets the middle note of the mapping based on the key
        switch currentClef {
        case "treble":
            newMapper.centerNote = currentKey.data.centerNoteTreble
        case "tenorVocal":
            newMapper.centerNote = currentKey.data.centerNoteTenorVocal
        case "bass":
            newMapper.centerNote = currentKey.data.centerNoteBass
        default:
            newMapper.centerNote = currentKey.data.centerNoteTreble
        }
        
        newMapper.centerNotePosition = spacingData.centerNoteLocationY // position of the center note
        newMapper.notesInKey = currentKey.data.notes // notes in the current key
        newMapper.numNotes = 17 // the maximum number of notes displayed will always be 17
        newMapper.spacing = spacingData.whiteSpaceBetweenNotes // spacing bewteen each note
        
        return newMapper.mapNotes() // returns a mapping of [frequency : position]
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
    
    // toggles the timer and recording session
    func toggleRecording() {
        // toggles the isRecording boolean (sets to false if it's currently true and vice versa)
        self.isRecording.toggle()
        
        isRecording ? playTimer() : pauseTimer()
        isRecording ? conductor.start() : conductor.stop()
    }
    
    // stops the timer and recording session (used to reset elapsed time and history arrays)
    func stopRecording() {
        // if we are currently recording toggle isRecording and pause the timer
        if isRecording {
            self.isRecording.toggle()
            pauseTimer()
        }
        
        // always stop the conductor, and reset the timer and history arrays
        conductor.stop()
        elapsedTime = 0
        pitchHistory = []
        colorHistory = []
    }
    
    // stub function to open the settings page (will be implemented later)
    func openSettings() {
        
    }
    
    // starts the timer and increments it by 0.05 of a second
    func playTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            elapsedTime += 0.05
            updateHistory(with: Double(conductor.data.pitch)) // collects data for the history arrays
        }
    }
    
    // pauses the timer at the time it is at
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
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

#Preview {
    VisualizerView()
}
