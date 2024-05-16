//
//  Visual.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/15/24.
//

/*
 TO DO:
 - Make tap guestures work by not duplicating the code twice
 - Try to make recording indicator code more concise
 */

import SwiftUI

struct RecordingIndicator: View {
    @Binding var isTiming: Bool
    @State var opacVal = 1.0
    
    let PADDING_SIZE: CGFloat
    private let REC_DOT_COLOR_ON: Color     = Color.red
    private let REC_DOT_COLOR_OFF: Color    = Color.secondary
    private let REC_DOT_SIZE: CGFloat       = 20
    
    var body: some View {
        // recording indicator
        if #available(iOS 17.0, *) {
            Image(systemName: "record.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: REC_DOT_SIZE)
                .foregroundColor(isTiming ? REC_DOT_COLOR_ON : REC_DOT_COLOR_OFF)
                .padding([.top, .leading], PADDING_SIZE)
                .opacity(opacVal)
                .onAppear() {
                    if(isTiming){
                        startAnimation()
                    }else{
                        opacVal = 1.0
                    }
                }
                .onChange(of: isTiming) {
                    if(isTiming) {
                        startAnimation()
                    }else{
                        opacVal = 1.0
                    }
               }
        } else {
            Image(systemName: "record.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: REC_DOT_SIZE)
                .foregroundColor(isTiming ? REC_DOT_COLOR_ON : REC_DOT_COLOR_OFF)
                .padding([.top, .leading], PADDING_SIZE)
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
            opacVal = 0.3
        }
    }
}


struct TimerElement: View {
    var elapsedTime: Double
    let PADDING_SIZE: CGFloat
    private let TIMER_FONT_SIZE: CGFloat    = 42
    
    var body: some View {
        // text to display timer
        Text(timeToString(from: elapsedTime))
            .font(.system(size: TIMER_FONT_SIZE))
            .frame(width: 175, alignment: .leading)
            .padding(.top, PADDING_SIZE)
    }
    
    // converts the elapsed time into an understandable format
    func timeToString(from elapsedTime: Double) -> String {
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        let milliseconds = Int((elapsedTime * 100).truncatingRemainder(dividingBy: 100))
        
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
}

struct Controls: View {
    @Binding var isTiming: Bool
    
    var playTimer: () -> Void
    var pauseTimer: () -> Void
    var stopTimer: () -> Void
    
    let PADDING_SIZE: CGFloat
    // constants to control color of elements
    private let PLAY_BUTTON_COLOR: Color    = Color.green
    private let PAUSE_BUTTON_COLOR: Color   = Color.red
    private let STOP_BUTTON_COLOR: Color    = Color.primary
    private let CONTROLS_SIZE: CGFloat      = 35
    
    var body: some View {
        Button(action: isTiming ? pauseTimer : playTimer) {
            Image(systemName: isTiming ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: CONTROLS_SIZE * 1.25)
        }
        .foregroundColor(isTiming ? PAUSE_BUTTON_COLOR : PLAY_BUTTON_COLOR)
        .padding(.trailing, PADDING_SIZE)
        
        // button to stop/ reset timer
        Button(action: stopTimer) {
            Image(systemName: "stop.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: CONTROLS_SIZE)
        }
        .foregroundColor(STOP_BUTTON_COLOR)
        .padding(.leading, PADDING_SIZE)
    }
}

struct Portrait: View {
    @Binding var isTiming: Bool
    @Binding var elapsedTime: Double
    let PADDING_SIZE: CGFloat
    let recordingIndicator: RecordingIndicator
    
    var playTimer: () -> Void
    var pauseTimer: () -> Void
    var stopTimer: () -> Void
    
    // portrait view
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    // recording indicator
                   // RecordingIndicator(isTiming: $isTiming, PADDING_SIZE: PADDING_SIZE)
                    recordingIndicator
                    TimerElement(elapsedTime: elapsedTime, PADDING_SIZE: PADDING_SIZE)
                }
                
                HStack {
                    // displays the play or pause button depending on isTiming condition
                    Controls(isTiming: $isTiming, playTimer: playTimer, pauseTimer: pauseTimer, stopTimer: stopTimer, PADDING_SIZE: PADDING_SIZE)
                }
                
            
                // moves timer elements to top
                Spacer()
                
                // tapable area for controlling timer
                Color.clear
                    .contentShape(Rectangle())
            }
        }
    }
}

struct Landscape: View {
    
    @Binding var isTiming: Bool
    @Binding var elapsedTime: Double
    let PADDING_SIZE: CGFloat
    let recordingIndicator: RecordingIndicator
    
    var playTimer: () -> Void
    var pauseTimer: () -> Void
    var stopTimer: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    // recording indicator
                    //RecordingIndicator(isTiming: $isTiming, PADDING_SIZE: PADDING_SIZE)
                    recordingIndicator
                    TimerElement(elapsedTime: elapsedTime, PADDING_SIZE: PADDING_SIZE)

                    // displays the play or pause button depending on isTiming condition
                    Controls(isTiming: $isTiming, playTimer: playTimer, pauseTimer: pauseTimer, stopTimer: stopTimer, PADDING_SIZE: PADDING_SIZE)
                }
                
                // moves timer elements to top
                Spacer()
                
                // tapable area for controlling timer
                Color.clear
                    .contentShape(Rectangle())
            }
        }
    }
}

struct Visual: View {
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    @State var isTiming = false
    
    @State var opacVal = 1.0
    
    // tracks the orientation of the device
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // constants to control size of elements
    let PADDING_SIZE: CGFloat       = 10
    
    
    // main view of visuals page
    var body: some View {
        
        let recordingSymbol: RecordingIndicator = RecordingIndicator(isTiming: $isTiming, PADDING_SIZE: PADDING_SIZE)
        
        // selects the type of view based off device orientation
        let VIEW = verticalSizeClass == .compact ? AnyView(Landscape(isTiming: $isTiming, elapsedTime: $elapsedTime, PADDING_SIZE: PADDING_SIZE, recordingIndicator: recordingSymbol, playTimer: playTimer, pauseTimer: pauseTimer, stopTimer: stopTimer)) : AnyView(Portrait(isTiming: $isTiming, elapsedTime: $elapsedTime, PADDING_SIZE: PADDING_SIZE, recordingIndicator: recordingSymbol,playTimer: playTimer, pauseTimer: pauseTimer, stopTimer: stopTimer))
        
        VIEW
            .onTapGesture(count: 2) {
                stopTimer()
            }
            .onTapGesture() {
                if !isTiming {
                    playTimer()
                } else {
                    pauseTimer()
                }
            }
    }
    
    // increments the timer by 0.01 second
    func playTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in elapsedTime += 0.01}
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
    }
}

#Preview {
    Visual()
}
