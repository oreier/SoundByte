//
//  RootView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 5/29/25.
//
//  Starts on tap screen to start and fades away to main view overlays. The views are all initialized from the RootView to keep variables from changing due to initialization errors that show up otherwise. The RootView determines which views are visible depending on the buttons pressed on the main menu page by changing the mode.
//

import SwiftUI

// Enum for main app navigation modes
enum AppMode {
    case start
    case sheetMusic
    case tuner
}

// Enum for grading modes
enum GradeMode {
    case tuning
    case learning
    case playing
}

struct RootView: View {
    @State private var currentMode: AppMode = .start // Tracks which view is active
    @State private var currentGradeMode: GradeMode = .playing // Tracks grading state (learning vs playing)
    @State private var showStartScreen: Bool = true // Controls visibility of the startup overlay

    var body: some View {
        ZStack {
            // Main app content switches based on currentMode
            switch currentMode {
            case .start:
                HomeView(
                    onRecordTap: {
                        // Transition to sheet music mode
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentMode = .sheetMusic
                        }
                    },
                    onTunerTap: {
                        // Transition to tuner mode
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentMode = .tuner
                        }
                    },
                    onLearningTap: { // Toggle between learning and playing modes
                        withAnimation(.easeInOut(duration: 0.5)) {
                            switch currentGradeMode {
                            case .learning:
                                currentGradeMode = .playing
                            case .playing:
                                currentGradeMode = .learning
                            case .tuning:
                                currentGradeMode = .playing
                            }
                        }
                    }
                )
                .transition(.opacity)

            case .sheetMusic: // Show the sheet music view with current grading mode
                SheetMusicContentView(mode: .sheetMusic, gradeMode: currentGradeMode)
                    .transition(.opacity)

            case .tuner: // Show the tuner view
                TunerContentView(mode: .tuner)
                    .transition(.opacity)
            }

            // Splash screen overlay shown at launch
            if showStartScreen {
                Color.white
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 20) {
                            Image("Soundbyte_Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)

                            Text("Tap Screen to Start")
                                .font(.title2)
                                .foregroundColor(.black)
                                .padding(.top, 10)
                        }
                    )
                    .onTapGesture {
                        // Hide start screen with animation
                        withAnimation(.easeOut(duration: 0.5)) {
                            showStartScreen = false
                        }
                    }
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    RootView()
}
