//
//  ContentView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 5/22/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showImportOptions = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                VStack {
                    // Top bar
                    HStack {
                        Button(action: {
                            withAnimation {
                                showImportOptions.toggle()
                            }
                        }) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 25))
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        Button(action: {
                            // Settings action
                        }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 25))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()

                    Spacer()

                    // Record Button -> SheetMusicView
                    NavigationLink(destination: SheetMusicView()) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 150, height: 150)
                                .shadow(radius: 10)
                            Image(systemName: "mic.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 40))
                        }
                    }
                    .padding()

                    // Library and History Buttons
                    HStack(spacing: 40) {
                        // Library button
                        NavigationLink(destination: LibraryView()) {
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 60)
                                        .shadow(radius: 4)
                                    Image(systemName: "books.vertical")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(.black)
                                }
                                Text("Library")
                                    .foregroundColor(.primary)
                            }
                        }

                        // History button
                        NavigationLink(destination: HistoryView()) {
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 60)
                                        .shadow(radius: 4)
                                    Image(systemName: "clock.arrow.circlepath")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(.black)
                                }
                                Text("History")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding()

                    Spacer()
                }
                .padding()

                // Floating dropdown
                if showImportOptions {
                    VStack(alignment: .leading, spacing: 10) {
                        Button("Import Sheet Music") {
                            print("Importing sheet music")
                            showImportOptions = false
                        }
                        Button("Import Backtrack Audio") {
                            print("Importing backtrack audio")
                            showImportOptions = false
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                    .offset(x: 16, y: 70)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
