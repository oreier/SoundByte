//
//  ToolBar.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/15/24.
//

/*
 TO DO:
 - Move timer functions into timer element struct (might be pretty difficult)
 - Timer gets hung up on the first 0.9
 - Separate each element into its own file
 - Oranize all files that create the tool bar into their own folder
 - Create initializers for all of the elements so that you can make variables private
 - Folow coding standards set in the pitch visualizer files and apply new knowledge to these files
 */

import SwiftUI

/*
 struct for making a recording dot element that
 indicates when the device is recording and the
 timer is going
 */
struct RecordingDotElement: View {
    // binding variable references isTiming in main view
    @Binding var isTiming: Bool
    
    // state variable keeps track of the current opacity of the dot
    @State private var recDotOpacVal: CGFloat = 1.0
    
    // constants that set recording dot size and color
    private let REC_DOT_SIZE: CGFloat       = 20
    private let REC_DOT_COLOR_ON: Color     = Color.red
    private let REC_DOT_COLOR_OFF: Color    = Color.secondary
    
    // constructs the recording dot element
    var body: some View {
        Image(systemName: "record.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: REC_DOT_SIZE)
            .foregroundStyle(isTiming ? REC_DOT_COLOR_ON : REC_DOT_COLOR_OFF)
            .opacity(recDotOpacVal)
            .onReceive([isTiming].publisher) { _ in
                if isTiming { animate() }
                else { recDotOpacVal = 1.0 }
            }
    }
    
    // function to animate the recording dot
    private func animate() {
        withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
            recDotOpacVal = 0.5
        }
    }
}

/*
 struct for making the timer element that displays
 how long the user has been recording for
 */
struct TimerElement: View {
    // elapsed time recieved from main view
    let ELAPSED_TIME: Double
    
    // constants set timer size
    private let TIMER_FONT_SIZE: CGFloat    = 42
    private let WIDTH_MULTIPLIER: CGFloat   = 1.25
    
    // constructs the timer element
    var body: some View {
        // text to display timer
        let TIME_COMPONENTS = getTimeComponents(from: ELAPSED_TIME)
        
        HStack(spacing: 2) {
            Text(String(format: "%02d", TIME_COMPONENTS.minutes))
                .font(.system(size: TIMER_FONT_SIZE))
                .frame(width: TIMER_FONT_SIZE * WIDTH_MULTIPLIER)
            Text(":")
                .font(.system(size: TIMER_FONT_SIZE))
                .padding(.bottom, TIMER_FONT_SIZE / 8)
            Text(String(format: "%02d", TIME_COMPONENTS.seconds))
                .font(.system(size: TIMER_FONT_SIZE))
                .frame(width: TIMER_FONT_SIZE * WIDTH_MULTIPLIER)
            Text(".")
                .font(.system(size: TIMER_FONT_SIZE))
            Text(String(format: "%01d", TIME_COMPONENTS.milliseconds))
                .font(.system(size: TIMER_FONT_SIZE))
                .frame(width: TIMER_FONT_SIZE * WIDTH_MULTIPLIER / 2)
        }
    }
    
    // decomposes the elapsed time into minutes, seconds and milliseconds
    private func getTimeComponents(from elapsedTime: Double) -> (minutes: Int, seconds: Int, milliseconds: Int) {
        let MINUTES = Int(elapsedTime / 60)
        let SECONDS = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        let MILLISECONDS = Int((elapsedTime * 10).truncatingRemainder(dividingBy: 10))
        
        return (MINUTES, SECONDS, MILLISECONDS)
    }
}

/*
 struct for displaying the control buttons which
 allows for the user to start, pause and stop the
 timer element
 */
struct ControlsElement: View {
    // binding variable references isTiming in main view
    @Binding var isTiming: Bool
    
    // functions that the buttons can perform
    var playTimer: () -> Void
    var pauseTimer: () -> Void
    var stopTimer: () -> Void
    
    // constants to control color of elements
    private let CONTROLS_SIZE: CGFloat      = 40
    private let PLAY_BUTTON_COLOR: Color    = Color.green
    private let PAUSE_BUTTON_COLOR: Color   = Color.red
    private let STOP_BUTTON_COLOR: Color    = Color.primary
    
    // constructs the controls element
    var body: some View {
        // play/ pause button
        HStack(spacing: 40) {
            Button(action: isTiming ? pauseTimer : playTimer) {
                Image(systemName: isTiming ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: CONTROLS_SIZE * 1.25)
                    .foregroundStyle(isTiming ? PAUSE_BUTTON_COLOR : PLAY_BUTTON_COLOR)
            }
            
            // stop button that pauses and resets the timer
            Button(action: stopTimer) {
                Image(systemName: "stop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: CONTROLS_SIZE)
                    .foregroundStyle(STOP_BUTTON_COLOR)
            }
        }
    }
}

/*
 struct for laying out controls when users device
 is in portrait mode
 */
struct Portrait: View {
    // visual elements passed by caller
    let REC_DOT_ELEMENT: RecordingDotElement
    let TIMER_ELEMENT: TimerElement
    let CONTROLS_ELEMENT: ControlsElement
    
    // constructs portrait view
    var body: some View {
        VStack (spacing: 10){
            // top level for recording dot and timer
            HStack {
                REC_DOT_ELEMENT
                TIMER_ELEMENT
            }

            // bottom level for controls element
            CONTROLS_ELEMENT
        }
    }
}

/*
 struct for laying out controls when users device
 is in landscape mode
 */
struct Landscape: View {
    // visual elements passed by caller
    let REC_DOT_ELEMENT: RecordingDotElement
    let TIMER_ELEMENT: TimerElement
    let CONTROLS_ELEMENT: ControlsElement
    
    private let PADDING_SIZE: CGFloat = 10
    
    // constructs landscape view
    var body: some View {
        HStack(spacing: 30) {
            // this HStack pushes the recording dot and timer closer together
            HStack {
                // recording indicator
                REC_DOT_ELEMENT
                TIMER_ELEMENT
            }
            
            // displays the play or pause button depending on isTiming condition
            CONTROLS_ELEMENT
        }
            .padding(.top, PADDING_SIZE)
    }
}


/*
 struct for displaying the correct view based off
 of the device's orientation
 */
struct ToolBar: View {
    // state variables to keep track of the timer
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    @Binding var isTiming: Bool
    @Binding var isStop: Bool
    
    // tracks the orientation of the device
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // tracks the life cycle of the app (sent to background or inactive)
    @Environment(\.scenePhase) private var scenePhase
    
    // variable tracks if we are running in the preview or on an actual device
    var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    // visual elements to display
    private var recDotElement: RecordingDotElement { return RecordingDotElement(isTiming: $isTiming) }
    private var timerElement: TimerElement { return TimerElement(ELAPSED_TIME: elapsedTime) }
    private var controlsElement: ControlsElement { return ControlsElement(isTiming: $isTiming,
                                                                  playTimer: playTimer,
                                                                  pauseTimer: pauseTimer,
                                                                  stopTimer: stopTimer) }
    
    // the type of tool bar that will be displayed
    private var toolBar: some View {
        return (verticalSizeClass == .compact) ?
        AnyView(Landscape(REC_DOT_ELEMENT: recDotElement,
                          TIMER_ELEMENT: timerElement,
                          CONTROLS_ELEMENT: controlsElement)) :
        AnyView(Portrait(REC_DOT_ELEMENT: recDotElement,
                         TIMER_ELEMENT: timerElement,
                         CONTROLS_ELEMENT: controlsElement))
    }

    // main view that puts the tool bar in the right place
    var body: some View {
        
        ZStack {
            // color layer to be able to tap on
            Color(.clear)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) { stopTimer() }
                .onTapGesture() { _ in isTiming ? pauseTimer() : playTimer() }
            
            VStack {
                toolBar
                Spacer()
            }
        }
            // pauses the timer when the app is exited
            .onReceive([scenePhase].publisher) { _ in if (scenePhase == .background && isTiming && !isPreview) { pauseTimer() } }
    }
    
    // increments the timer by 0.01 second
    func playTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in elapsedTime += 0.1}
        self.isTiming.toggle()
    }
    
    // pauses the timer at the time it's at
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        self.isTiming.toggle()
    }
    
    // stops the timer and resets the elapsed time
    func stopTimer() {
        if isTiming {
            pauseTimer()
        }
        elapsedTime = 0
        self.isStop.toggle()
    }
}

//#Preview {
//    ToolBar()
//}
