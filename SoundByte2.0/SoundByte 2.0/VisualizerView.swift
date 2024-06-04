//
//  VisualizerView.swift
//  SoundByte 2.0
//
//  Created by Jack Durfee on 5/28/24.
//

import SwiftUI

// view creates the indicator used to show a users live pitch
struct PitchIndicator: View {
    let xPos: Double
    let yPos: Double
    
    // constant to set indicator dot parameters
    let dotSize: Double = 25
    
    // constructor for the pitch indicator
    init(x: Double, y: Double) {
        self.xPos = x
        self.yPos = y
    }
    
    // builds the dot
    var body: some View {
        Image(systemName: "music.note")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: dotSize)
            .position(x: xPos, y: yPos)
            .offset(x: dotSize / 4, y: -15) // offset is to align music note dot to lines
    }
}

// view creates a dot that indicates when the app is recording audio
struct RecordingDot: View {
    // binding variable to track when the app is recording audio
    @Binding var isRecording: Bool
    
    // state variable to track opacity of the dot
    @State var recDotOpacVal = 1.0
    
    // constants that set recording dot parameters
    let dotSize = 20.0
    let dotColorOn = Color.red
    let dotColorOff = Color.secondary
    
    // builds the recording dot
    var body: some View {
        Image(systemName: "record.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: dotSize)
            .foregroundStyle(isRecording ? dotColorOn : dotColorOff)
            .opacity(recDotOpacVal)
            .onChange(of: isRecording) {
                if isRecording { animate() }
                else { recDotOpacVal = 1.0 }
            }
    }
    
    // function to animate the recording dot when the app is recording audio
    func animate() {
        withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
            recDotOpacVal = 0.5
        }
    }
}

// view creates a timer display to show how long the user has been recording for
struct TimerDisplay: View {
    // binding variable to track when the app is recording audio
    @Binding var isRecording: Bool

    let elapsedTime: Double
    let fontSize: Double
    
    // constants that set timer display parameters
    let widthMultiplier = 1.25
    
    // constructor for the timer display
    init(time elapsedTime: Double, size fontSize: Double, isRecording: Binding<Bool>) {
        self.elapsedTime = elapsedTime
        self.fontSize = fontSize
        self._isRecording = isRecording
    }
    
    // builds the timer display
    var body: some View {
        // the components that are going to be displayed in the timer
        let timeComponents = getTimeComponents(from: elapsedTime)
        
        ZStack {
            // displays the border
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.primary, lineWidth: 4)
                .foregroundStyle(.clear)
                .frame(width: fontSize * 5, height: fontSize)
            
            HStack(spacing: 2) {
                RecordingDot(isRecording: $isRecording)
                    .padding(.trailing, 5)
                
                // displays the timer components
                Text(String(format: "%02d", timeComponents.minutes))
                    .font(.system(size: fontSize))
                    .frame(width: fontSize * widthMultiplier)
                Text(":")
                    .font(.system(size: fontSize))
                    .padding(.bottom, fontSize / 8)
                Text(String(format: "%02d", timeComponents.seconds))
                    .font(.system(size: fontSize))
                    .frame(width: fontSize * widthMultiplier)
                Text(".")
                    .font(.system(size: fontSize))
                Text(String(format: "%01d", timeComponents.milliseconds))
                    .font(.system(size: fontSize))
                    .frame(width: fontSize * widthMultiplier / 2)
            }
        }
    }
    
    // decomposes the elapsed time into minutes, seconds and milliseconds
    func getTimeComponents(from elapsedTime: Double) -> (minutes: Int, seconds: Int, milliseconds: Int) {
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        let milliseconds = Int((elapsedTime * 10).truncatingRemainder(dividingBy: 10))
        
        return (minutes, seconds, milliseconds)
    }
}

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

// view constructs a line representing a specific note
struct NoteLine: View {
    let isLedger: Bool
    let isDisplayed: Bool

    // constants that set line parameters
    let spacing = Spacing()
    
    // constructor for line notes
    init(isLedger: Bool = false, isDisplayed: Bool = true) {
        self.isLedger = isLedger
        self.isDisplayed = isDisplayed
    }
    
    // builds the note line
    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 15.0)
                .frame(width: isLedger ? spacing.ledgerLineWidth : .infinity, height: spacing.lineThickness)
                .padding([.top, .bottom], spacing.whiteSpace)
                .opacity(isDisplayed ? 1.0 : 0.0)
        }
    }
}

// view construts the note text that is to be displayed
struct NoteText: View {
    let noteName: String
    
    // constants that set note text parameters
    let fontSize = 18.5
    let noteSpace = 1.0
    
    // constructor for note text
    init(noteName: String) {
        self.noteName = noteName
    }
    
    // builds the note text
    var body: some View {
        Text(noteName)
            .font(.system(size: fontSize))
            .padding([.top, .bottom], noteSpace)
    }
}

// protocol defines the settings each clef should have
protocol ClefSettings {
    var imageFile: String { get } // the name of the image file
    var frameHeight: Double { get } // how tall the image should apear
    var offsetX: Double { get } // the x offset to display the image at
    var offsetY: Double { get } // the y offset to display the image at
    var keySignatureOffsetX: Double { get }
    var sharpsOrder: [Double] { get } // the order in which sharps are added to the clef from the middle note
    var flatsOrder: [Double] { get } // the order in which flats are added to the clef from the middle note
}

// settings for the treble cleff
struct TrebleClefSettings: ClefSettings {
    var imageFile = "trebleClef"
    var frameHeight = 260.0
    var offsetX = -80.0
    var offsetY = 10.0
    var keySignatureOffsetX = 80.0
    var sharpsOrder = [4.0, 1.0, 5.0, 2.0, -1.0, 3.0, 0.0]
    var flatsOrder = [0.0, 3.0, -1.0, 2.0, -2.0, 1.0, -3.0]
}

// settings for the tenor vocal cleff
struct TenorVocalClefSettings: ClefSettings {
    var imageFile = "tenorVocalClef"
    var frameHeight = 300.0
    var offsetX = -100.0
    var offsetY = 28.0
    var keySignatureOffsetX = 80.0
    var sharpsOrder = [4.0, 1.0, 5.0, 2.0, -1.0, 3.0, 0.0]
    var flatsOrder = [0.0, 3.0, -1.0, 2.0, -2.0, 1.0, -3.0]
}

// settings for the bass cleff
struct BassClefSettings: ClefSettings {
    var imageFile = "bassClef"
    var frameHeight = 130.0
    var offsetX = -10.0
    var offsetY = -15.0
    var keySignatureOffsetX = 110.0
    var sharpsOrder = [2.0, -1.0, 3.0, 0.0, -3.0, 1.0, -2.0]
    var flatsOrder = [-2.0, 1.0, -3.0, 0.0, -4.0, -1.0, -5.0]
}

// view constructs the image of the clef that is to be displayed
struct ClefImage: View {
    let clef: String
    let clefSettings: ClefSettings
    let numSharps: Int
    let numFlats: Int
    let spacingData: Spacing
    
    // constructor for clef image
    init(_ clef: String, numSharps: Int = 0, numFlats: Int = 0, spacing spacingData: Spacing) {
        self.clef = clef
        
        switch clef {
        case "treble":
            clefSettings = TrebleClefSettings()
        case "tenorVocal":
            clefSettings = TenorVocalClefSettings()
        case "bass":
            clefSettings = BassClefSettings()
        default:
            clefSettings = TrebleClefSettings()
            print("Error: invalidClefType")
        }
        
        self.numSharps = numSharps
        self.numFlats = numFlats
        self.spacingData = spacingData
    }
    
    // builds the clef image
    var body: some View {
        ZStack(alignment: .leading) {
            // displays image of the clef
            Image(clefSettings.imageFile)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: clefSettings.frameHeight)
                .offset(x: clefSettings.offsetX, y: clefSettings.offsetY)
            
            HStack(spacing: -37.5) {
                // displays sharps if there are any
                if numSharps > 0 {
                    ForEach(0..<numSharps, id: \.self) { i in
                        Image("sharp")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: spacingData.whiteSpaceBetweenLines * 1.35)
                            .offset(y: -clefSettings.sharpsOrder[i] * spacingData.whiteSpaceBetweenNotes)
                    }
                }
                
                // displays flats if there are any
                if numFlats > 0 {
                    ForEach(0..<numFlats, id: \.self) { i in
                        Image("flat")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: spacingData.whiteSpaceBetweenLines * 1.35)
                            .offset(y: -clefSettings.flatsOrder[i] * spacingData.whiteSpaceBetweenNotes - spacingData.whiteSpaceBetweenNotes / 1.5)
                    }
                }
            }
            .offset(x: clefSettings.keySignatureOffsetX)
        }
    }
}

// view constructs the staff by bringing together the clef, notes and key signature
struct StaffView: View {
    let clefFile: String
    let keyData: KeyData
    let spacingData: Spacing
    
    // constructor for the staff view
    init(clef clefFile: String, keyData: KeyData, spacing spacingData: Spacing) {
        self.clefFile = clefFile
        self.keyData = keyData
        self.spacingData = spacingData
    }
    
    // builds the staff with the specified clef and key
    var body: some View {
        // controller for displaying the ledger lines
        let ledgerLineController = ledgerLineDisplayController()
        
        // vstack for displaying all of the staff lines
        VStack(alignment: .leading, spacing: 0) {
            // top ledger lines
            NoteLine(isLedger: true, isDisplayed: ledgerLineController.secondTop)
                .offset(x: spacingData.ledgerOffset)
            NoteLine(isLedger: true, isDisplayed: ledgerLineController.firstTop)
                .offset(x: spacingData.ledgerOffset)
            
            // staff lines
            ForEach(0..<5) { _ in
                NoteLine()
            }
            
            // bottom ledger lines
            NoteLine(isLedger: true, isDisplayed: ledgerLineController.firstBottom)
                .offset(x: spacingData.ledgerOffset)
            NoteLine(isLedger: true, isDisplayed: ledgerLineController.secondBottom)
                .offset(x: spacingData.ledgerOffset)
        }
        .frame(width: spacingData.staffWidth) // sets the width of the staff lines
        .overlay(alignment: .trailing) { // overlays the bar at the end of the staff
            Rectangle().frame(width: 10, height: spacingData.staffHeight)
        }
        .overlay(alignment: .leading) { // overlays the image of the clef
            ClefImage(clefFile, numSharps: keyData.numSharps, numFlats: keyData.numFlats, spacing: spacingData)
        }
        .position(x: spacingData.spaceWidth / 2, y: spacingData.spaceHeight / 2) // positions staff to the center
        .offset(x: -(spacingData.spaceWidth - spacingData.staffWidth) / 2) // offsets staff so it's aligned to leading edge
    }
    
    // determines what ledger lines should be visible (displays if indicator is at the space below the ledger line)
    func ledgerLineDisplayController() -> (secondTop: Bool, firstTop: Bool, firstBottom: Bool, secondBottom: Bool) {
        var results: (secondTop: Bool, firstTop: Bool, firstBottom: Bool, secondBottom: Bool) = (false, false, false, false)
        
        // first two if-statements determine the visibility of the top ledger lines
        if spacingData.indicatorY < spacingData.centerNoteLocationY - spacingData.whiteSpaceBetweenLines * 3.5 {
            results.secondTop = true
        }
        if spacingData.indicatorY < spacingData.centerNoteLocationY - spacingData.whiteSpaceBetweenLines * 2.5 {
            results.firstTop = true
        }
        
        // second two if-statements determine the visibility of the bottom ledger lines
        if spacingData.indicatorY > spacingData.centerNoteLocationY + spacingData.whiteSpaceBetweenLines * 2.5 {
            results.firstBottom = true
        }
        if spacingData.indicatorY > spacingData.centerNoteLocationY + spacingData.whiteSpaceBetweenLines * 3.5 {
            results.secondBottom = true
        }
        
        return results
    }
}

/*
 TO-DO:
 - Add opacity controls to ledger lines and notes that are not directly on the staff
 */

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
    
    // history arrays to draw history line
    @State var pitchHistory: [CGPoint] = []
    @State var colorHistory: [Color] = [.clear] // starts with a clear line so there isn't a huge jump at the start of recording
        
    // constants for various parameters in the view
    let numDataStored = 250
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
            StaffView(clef: currentClef, keyData: currentKey.data, spacing: spacingData)
    
            // displays the pitch indicator for viewing in preview
            PitchIndicator(x: spacingData.indicatorX, y: spacingData.indicatorY)
                .onChange(of: conductor.data.pitch) {
                    spacingData.indicatorY = calculatePosition(from: conductor.data.pitch)
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
            do {
                currentKey = try Key(numFlats: 0, isMajor: true)
                spacingData = Spacing(width: screenWidth, height: screenHeight)
                currentMapping = generateMapping()
                sortedFrequencies = currentMapping.keys.sorted()
            } catch {
                print("Error: \(error)")
            }
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
        let cents = positioning.cents
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
        colorHistory.append(frequency == 0 ? .clear : .black) // adds clear if the frequency is zero
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
            updateHistory(with: conductor.data.pitch) // collects data for the history arrays
        }
    }
    
    // pauses the timer at the time it is at
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    VisualizerView()
}
