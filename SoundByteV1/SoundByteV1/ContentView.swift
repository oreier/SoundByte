//
//  ContentView.swift
//  SoundByteV1
//
//  Created by Delaney Lim (Student) on 5/15/24.
//

import SwiftUI

/*
 main view for the app that brings all individual views into one
 */
struct ContentView: View {
    @State var isRecording: Bool = false
    @State var isStop: Bool = false
    
    // constructs app UI
    var body: some View {
        ZStack {
            PitchVisualizer(isRecording: $isRecording, isStop: $isStop)
            ToolBar(isTiming: $isRecording, isStop: $isStop)
            StartScreen()
        }
    }
}

#Preview {
    ContentView()
}
