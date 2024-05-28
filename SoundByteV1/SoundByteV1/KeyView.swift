//
//  KeySelecter.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/24/24.
//

import SwiftUI

struct KeyData {
    var note = "C"
    var accidental = "♮"
    var degree = "M"
}

class KeyGenerator: ObservableObject {
    @Published var data = KeyData()
    
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    
    func generateKey() -> [String] {
        var notesInKey = [data.note + (data.accidental != "♮" ? data.accidental : "")] // first note in key
        
        
        return notesInKey
    }
}

struct KeyView: View {
    @StateObject var generator = KeyGenerator()
    
    var body: some View {
        Text("Key Selection")
            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
        KeyPicker(pick: $generator.data)
        Text("Notes in \(generator.data.note)\(generator.data.accidental != "♮" ? generator.data.accidental : "")\(generator.data.degree != "M" ? generator.data.degree : ""):")
        ForEach(generator.generateKey(), id: \.self) {
            Text($0)
        }
    }
}

struct KeyPicker: View {
    @Binding var data: KeyData
    
    @State var note: String = "C"
    @State var accidental: String = "♮"
    @State var degree: String = "M"
    
    let notes = ["C", "D", "E", "F", "G", "A", "B"]
    let accidentals = ["♮", "♯", "♭"]
    let degress = ["M", "m"]
    
    init(pick data: Binding<KeyData>) {
        _data = data
    }
    
    var body: some View {
        HStack {
            Picker("Note:", selection: $note) {
                ForEach(notes, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .onChange(of: note) { setKey() }
            .frame(width: 50)
            
            Picker("Accidental:", selection: $accidental) {
                ForEach(accidentals, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .onChange(of: accidental) { setKey() }
            .frame(width: 50)
            
            Picker("Degree:", selection: $degree) {
                ForEach(degress, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .onChange(of: degree) { setKey() }
            .frame(width: 50)
        }
    }
    
    func setKey() {
        data.note = self.note
        data.accidental = self.accidental
        data.degree = self.degree
    }
}

#Preview {
    KeyView()
}
