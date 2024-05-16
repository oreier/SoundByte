//
//  Visual.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/15/24.
//

/*
 TO DO:
 - Clean up code for changing orientations so that they are in different structs
    -> This might not be possible/ hard to do but it would make the code cleaner and more readable
 - Make tap guestures work by not duplicating the code twice
 */

import SwiftUI

struct Visual: View {
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    
    @State var isTiming = false
    
    // tracks the orientation of the device
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // constants to control size of elements
    let REC_DOT_SIZE: CGFloat       = 20
    let CONTROLS_SIZE: CGFloat      = 35
    let TIMER_FONT_SIZE: CGFloat    = 42
    let PADDING_SIZE: CGFloat       = 10
    
    // constants to control color of elements
    let REC_DOT_COLOR_ON: Color     = Color.red
    let REC_DOT_COLOR_OFF: Color    = Color.secondary
    let PLAY_BUTTON_COLOR: Color    = Color.green
    let PAUSE_BUTTON_COLOR: Color   = Color.red
    let STOP_BUTTON_COLOR: Color    = Color.primary
    
    // main view of visuals page
    var body: some View {
        // selects the type of view based off device orientation
        if verticalSizeClass == .compact {
            landscape
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
        } else {
            portrait
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
    }
    
    // portrait view
    var portrait: some View {
        ZStack {
            VStack {
                HStack {
                    // recording indicator
                    Image(systemName: "record.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: REC_DOT_SIZE)
                        .foregroundColor(isTiming ? REC_DOT_COLOR_ON : REC_DOT_COLOR_OFF)
                        .padding([.top, .leading], PADDING_SIZE)
                    
                    // text to display timer
                    Text(timeToString(from: elapsedTime))
                        .font(.system(size: TIMER_FONT_SIZE))
                        .frame(width: 175, alignment: .leading)
                        .padding(.top, PADDING_SIZE)
                }
                
                HStack {
                    // displays the play or pause button depending on isTiming condition
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
                // moves timer elements to top
                Spacer()
                
                // tapable area for controlling timer
                Color.clear
                    .contentShape(Rectangle())
            }
        }
    }
    
    // landscape view
    var landscape: some View {
        ZStack {
            VStack {
                HStack {
                    // recording indicator
                    Image(systemName: "record.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: REC_DOT_SIZE)
                        .foregroundColor(isTiming ? REC_DOT_COLOR_ON : REC_DOT_COLOR_OFF)
                        .padding([.top, .leading], PADDING_SIZE)
                    
                    // text to display timer
                    Text(timeToString(from: elapsedTime))
                        .font(.system(size: TIMER_FONT_SIZE))
                        .frame(width: 175, alignment: .leading)
                        .padding(.top, PADDING_SIZE)
                    
                    // displays the play or pause button depending on isTiming condition
                    Button(action: isTiming ? pauseTimer : playTimer) {
                        Image(systemName: isTiming ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: CONTROLS_SIZE * 1.25)
                    }
                    .foregroundColor(isTiming ? PAUSE_BUTTON_COLOR : PLAY_BUTTON_COLOR)
                    .padding([.top, .leading], PADDING_SIZE)
                    
                    // button to stop/ reset timer
                    Button(action: stopTimer) {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: CONTROLS_SIZE)
                    }
                    .foregroundColor(STOP_BUTTON_COLOR)
                    .padding([.top, .leading], PADDING_SIZE)
                }
                // moves timer elements to top
                Spacer()
                
                // tapable area for controlling timer
                Color.clear
                    .contentShape(Rectangle())
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
    
    // converts the elapsed time into an understandable format
    func timeToString(from elapsedTime: Double) -> String {
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        let milliseconds = Int((elapsedTime * 100).truncatingRemainder(dividingBy: 100))
        
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
}

#Preview {
    Visual()
}
