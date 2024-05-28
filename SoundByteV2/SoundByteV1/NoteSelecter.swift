//
//  NoteSelecter.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/23/24.
//

import SwiftUI

struct NoteSelecter: View {
    // binding variables correspond to state variables in ContentView
    @Binding var selectedNote: String
    @Binding var selectedOctave: Int
    @Binding var isSubmit: Bool
    
    // temporary variables for the preview
//    @State private var selectedNote: String = "C"
//    @State private var selectedOctave: Int  = 0
//    @State private var isSubmit: Bool       = false
    
    // notes and octaves to choose from
    private let NOTES: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private let OCTAVES: [Int]  = [0, 1, 2, 3, 4, 5, 6]
    
    // constants set size of pickers
    private let PICKER_HEIGHT: Double   = 150.0
    private let PICKER_WIDTH: Double    = 100.0
    
    // tracks the color scheme of the device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack{
            // sets the background color based off device color scheme
            Color(uiColor: colorScheme == .dark ? .black : .white)
                .ignoresSafeArea()
            
            VStack {
                Text("Select a center note and an octave:")
                    .font(.headline)
                    .padding()
                
                HStack {
                    // note picker
                    VStack {
                        Text("Note:")
                        Picker(selection: $selectedNote, label: Text("Note Picker")) {
                            ForEach(NOTES, id:\.self) { note in
                                Text(note)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                        .frame(width: PICKER_WIDTH, height: PICKER_HEIGHT)
                        .clipped()
                        .padding()
                    }
                    
                    // octave picker
                    VStack {
                        Text("Octave:")
                        Picker(selection: $selectedOctave, label: Text("Octave Picker")) {
                            ForEach(OCTAVES, id:\.self) { octave in
                                Text(String(octave))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                        .frame(width: PICKER_WIDTH, height: PICKER_HEIGHT)
                        .clipped()
                        .padding()
                    }
                }
                
                // button to remove the view
                Button("Submit") {
                    self.isSubmit.toggle()
                }
                .frame(width: 80, height: 30)
                .foregroundStyle(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 10.0)
                        .foregroundStyle(.secondary)
                        .opacity(0.3)
                )
                .offset(y: 30)
            }
        }
    }
}

//#Preview {
//    NoteSelecter()
//}
