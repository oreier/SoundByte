//
//  TimerDisplay.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/4/24.
//

import SwiftUI

// view displays a timer to show how long the user has been recording for
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
        
        // zstack to overlay border ontop of timer display
        ZStack {
            // displays the border
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.primary, lineWidth: 4)
                .foregroundStyle(.clear)
                .frame(width: fontSize * 5, height: fontSize)
            
            // hstack to display timer components next to each other
            HStack(spacing: 2) {
                // indicator that shows when the user is recording
                RecordingIndicator(isRecording: $isRecording)
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

#Preview {
    TimerDisplay(time: 50, size: 35, isRecording: .constant(true))
}
