//
//  Visual.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/15/24.
//

import SwiftUI

struct Visual: View {
    @State private var startDate = Date.now
    @State private var timeElapsed: Double = 0.0
    
    @State private var timer: Timer?
    
    @State private var isTiming = false
    
    var body: some View {
        ZStack {
            HStack {
                VStack {
                    Text(timeToString(from: timeElapsed))
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    Spacer()
                }
                .padding([.top, .leading], 10.0)
                Spacer()
            }
            
            Color.clear
                .contentShape(Rectangle())
        }
        .onTapGesture(count: 2) {
            if !isTiming {
                timeElapsed = 0.0
                self.isTiming.toggle()
            }
        }
        .onTapGesture() {
            if !isTiming {
                startTimer()
                self.isTiming.toggle()
            } else {
                stopTimer()
                self.isTiming.toggle()
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in timeElapsed += 0.01}
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
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
