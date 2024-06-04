//
//  SettingsView.swift
//  test2
//
//  Created by Delaney Lim (Student) on 6/3/24.
//

import SwiftUI

enum ClefType: String {
    case treble = "Treble Clef"
    case bass = "Bass Clef"
    case tenor = "Tenor Clef"
}

class UserSettings: ObservableObject {
    @Published var darkModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(darkModeEnabled, forKey: "DarkModeEnabled")
        }
    }
    
    @Published var noteNamesEnabled: Bool {
        didSet {
            UserDefaults.standard.set(noteNamesEnabled, forKey: "noteNamesEnabled")
        }
    }
    
    @Published var isMinor: Bool {
        didSet {
            UserDefaults.standard.set(isMinor, forKey: "isMajor")
        }
    }
    
    @Published var numSharps: Int {
        didSet {
            UserDefaults.standard.set(numSharps, forKey: "numSharps")
        }
    }
    
    @Published var numFlats: Int {
        didSet {
            UserDefaults.standard.set(numFlats, forKey: "numFlats")
        }
        
    }
    
    @Published var clefType: ClefType {
        didSet {
            UserDefaults.standard.set(clefType.rawValue, forKey: "clefType")
        }
    }
    
    
    init() {
        self.darkModeEnabled = UserDefaults.standard.bool(forKey: "DarkModeEnabled")
        self.noteNamesEnabled = UserDefaults.standard.bool(forKey: "noteNamesEnabled")
        self.isMinor = UserDefaults.standard.bool(forKey: "isMajor")
        self.numSharps = UserDefaults.standard.integer(forKey: "numSharps")
        self.numFlats = UserDefaults.standard.integer(forKey: "numFlats")
        if let clefTypeRawValue = UserDefaults.standard.string(forKey: "clefType"), let clefType = ClefType(rawValue: clefTypeRawValue) {
                self.clefType = clefType
        } else {
            self.clefType = .treble // Default to treble clef if not set
        }
    }
}

struct SettingsView: View {
    @ObservedObject var userSettings: UserSettings
    
    let keysMajor = ["C", "G", "D", "A", "E", "B", "F#", "C#", "Gb", "Db", "Ab", "Eb", "Bb", "F"]
    let keysMinor = ["Am", "Em", "Bm", "F#m", "C#m", "Abm", "D#m", "A#m", "Ebm", "Bbm", "Fm", "Cm", "Gb", "Dm"]
    var clefTypes: [ClefType] = [.treble, .tenor, .bass]
    
    var keySignatures: [String] {
        switch userSettings.clefType {
        case .treble:
            return ["C_treble", "G_treble", "D_treble", "A_treble", "E_treble", "B_treble", "F_sharp_treble", "C_sharp_treble", "G_flat_treble", "D_flat_treble", "A_flat_treble", "E_flat_treble", "B_flat_treble", "F_treble"]
        case .bass:
            return ["C_bass", "G_bass", "D_bass", "A_bass", "E_bass", "B_bass", "F_sharp_bass", "C_sharp_bass", "G_flat_bass", "D_flat_bass", "A_flat_bass", "E_flat_bass", "B_flat_bass", "F_bass"]
        case .tenor:
            return ["C_tenor", "G_tenor", "D_tenor", "A_tenor", "E_tenor", "B_tenor", "F_sharp_tenor", "C_sharp_tenor", "G_flat_tenor", "D_flat_tenor", "A_flat_tenor", "E_flat_tenor", "B_flat_tenor", "F_tenor"]
        }
    }

    @State var selectedKeyIndex: Int
    @State private var selectedClefIndex: Int = 0
        
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle(isOn: $userSettings.darkModeEnabled) {
                        Text("Dark Mode")
                    }
                }
                
                Section(header: Text("Graph")) {
                    Toggle(isOn: $userSettings.noteNamesEnabled) {
                        Text("Show Note Names")
                    }
                }
                
                Section(header: Text("Select Musical Key")) {
                    
                    Picker(selection: $selectedClefIndex, label: Text("Clef")) {
                            ForEach(0 ..< clefTypes.count, id: \.self) { index in
                                Text(clefTypes[index].rawValue)
                            }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedClefIndex) {
                        let selectedClef = clefTypes[selectedClefIndex]
                        userSettings.clefType = selectedClef
                        print(userSettings.clefType)
                    }
                    .padding(15)
                    
                    Toggle(isOn: $userSettings.isMinor) {
                        Text(userSettings.isMinor ? "Minor" : "Major")
                    }
                    
                    HStack {
                        
                        Image(keySignatures[selectedKeyIndex])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        
                        Picker(selection: $selectedKeyIndex, label: Text("Key")) {
                            ForEach(0 ..< (userSettings.isMinor ? keysMinor.count : keysMajor.count), id: \.self) { index in
                                    Text(userSettings.isMinor ? keysMinor[index] : keysMajor[index])
                                }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .onChange(of: selectedKeyIndex) {
                            updateSharpsFlats()
                        }
                    }
                }
                
                Section(header: Text("Account")) {
                    Button(action: {
                        // Add action to manage account settings
                    }) {
                        Text("Manage Account")
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }
    
    func updateSharpsFlats() {
        let sharpsFlatsMajor: [String: (Int, Int)] = [
                "C": (0, 0), "G": (1, 0), "D": (2, 0), "A": (3, 0), "E": (4, 0), "B": (5, 0),
                "F#": (6, 0), "C#": (7, 0), "Gb": (0, 6), "Db": (0, 5), "Ab": (0, 4),
                "Eb": (0, 3), "Bb": (0, 2), "F": (0, 1)
        ]
        let sharpsFlatsMinor: [String: (Int, Int)] = [
                "Am": (0, 0), "Em": (1, 0), "Bm": (2, 0), "F#m": (3, 0), "C#m": (4, 0), "Abm": (5, 0),
                "D#m": (6, 0), "A#m": (7, 0), "Ebm": (0, 6), "Bbm": (0, 5), "Fm": (0, 4),
                "Cm": (0, 3), "Gm": (0, 2), "Dm": (0, 1)
        ]
        
        let sharpsFlats = userSettings.isMinor ? sharpsFlatsMinor : sharpsFlatsMajor
        let selectedKey = userSettings.isMinor ? keysMinor[selectedKeyIndex] : keysMajor[selectedKeyIndex]
        let (sharps, flats) = sharpsFlats[selectedKey]!
        userSettings.numSharps = sharps
        userSettings.numFlats = flats
    }
    
}



#Preview {
    SettingsView(userSettings: UserSettings(), selectedKeyIndex: 0)
}
