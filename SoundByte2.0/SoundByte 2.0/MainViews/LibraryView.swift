//
//  LibraryView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 5/22/25.
//
//  Hard coded and disconnected library section for the app
//

import SwiftUI

struct LibraryView: View {
    @State private var searchText = ""

    // Track expanded state for each category
    @State private var isSheetMusicExpanded = false
    @State private var isBacktrackExpanded = false

    // Data for dropdowns
    let sheetMusicSongs = ["Song 1", "Song 2", "Song 3"]
    let backtrackSongs = ["Song 1", "Song 2", "Song 3"]

    // Filter function for search
    func filteredSongs(_ songs: [String]) -> [String] {
        if searchText.isEmpty {
            return songs
        }
        return songs.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search bar
            TextField("Search songs...", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            // Sheet Music dropdown
            VStack(alignment: .leading, spacing: 5) {
                Button(action: {
                    withAnimation {
                        isSheetMusicExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text("Sheet Music")
                            .font(.headline)
                        Spacer()
                        Image(systemName: isSheetMusicExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }

                if isSheetMusicExpanded {
                    let filtered = filteredSongs(sheetMusicSongs)
                    if filtered.isEmpty {
                        Text("No songs found")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        ForEach(filtered, id: \.self) { song in
                            Button(action: {
                                print("Selected Sheet Music song: \(song)")
                            }) {
                                Text(song)
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(.horizontal)

            // Backtrack Audio dropdown
            VStack(alignment: .leading, spacing: 5) {
                Button(action: {
                    withAnimation {
                        isBacktrackExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text("Backtrack Audio")
                            .font(.headline)
                        Spacer()
                        Image(systemName: isBacktrackExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }

                if isBacktrackExpanded {
                    let filtered = filteredSongs(backtrackSongs)
                    if filtered.isEmpty {
                        Text("No songs found")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        ForEach(filtered, id: \.self) { song in
                            Button(action: {
                                print("Selected Backtrack song: \(song)")
                            }) {
                                Text(song)
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Library")
    }
}

#Preview {
    LibraryView()
}
