//
//  RootView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 5/29/25.
//

import SwiftUI

enum AppMode {
    case start
    case sheetMusic
    case tuner
}

enum GradeMode {
    case tuning
    case learning
    case playing
}

struct RootView: View {
    @State private var currentMode: AppMode = .start
    @State private var currentGradeMode: GradeMode = .playing
    @State private var showStartScreen: Bool = true

    var body: some View {
        ZStack {
            // Main app content
            switch currentMode {
            case .start:
                HomeView(
                    onRecordTap: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentMode = .sheetMusic
                        }
                    },
                    onTunerTap: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentMode = .tuner
                        }
                    },
                    onLearningTap: {
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

            case .sheetMusic:
                SheetMusicContentView(mode: .sheetMusic, gradeMode: currentGradeMode)
                    .transition(.opacity)

            case .tuner:
                TunerContentView(mode: .tuner)
                    .transition(.opacity)
            }

            // Start screen overlay
            // Start screen overlay
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
