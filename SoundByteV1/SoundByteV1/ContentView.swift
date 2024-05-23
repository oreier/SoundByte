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
    @State var isRecording: Bool    = false
    @State var isStop: Bool         = false
    
    @State var selectedNote: String = "C"
    @State var selectedOctave: Int  = 0
    
    @State var isSubmit:Bool = false
    
    // constructs app UI
    var body: some View {
        NavigationStack {
            ZStack {
                NoteSelecter(
                    selectedNote: $selectedNote,
                    selectedOctave: $selectedOctave,
                    isSubmit: $isSubmit
                )
                .navigationDestination(isPresented: $isSubmit) {
                    ZStack {
                        PitchVisualizer(
                            _isRecording: $isRecording,
                            _isStop: $isStop,
                            _selectedNote: $selectedNote,
                            _selectedOctave: $selectedOctave
                        )
                        
                        ToolBar(
                            isTiming: $isRecording,
                            isStop: $isStop
                        )
                    }
                    .navigationBarBackButtonHidden(true)
                }
                
                StartScreen()
            }
        }
    }
}

#Preview {
    ContentView()
}
