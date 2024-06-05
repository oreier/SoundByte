//
//  SettingsView.swift
//  SoundByte 2.0
//
//  Created by Delaney Lim (Student) on 6/3/24.
//

import SwiftUI
import AudioKit

enum ClefType: String {
    case treble = "Treble Clef"
    case octave = "Octave Clef"
    case bass = "Bass Clef"
}

class UserSettings: ObservableObject {
    @Published var noteNamesEnabled: Bool {
        didSet {
            UserDefaults.standard.set(noteNamesEnabled, forKey: "noteNamesEnabled")
        }
    }
    
    @Published var isMajor: Bool {
        didSet {
            UserDefaults.standard.set(isMajor, forKey: "isMajor")
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
    
    @Published var selectedKeyIndex: Int {
        didSet {
            UserDefaults.standard.setValue(selectedKeyIndex, forKey: "selectedKeyIndex")
        }
    }
    
    @Published var selectedClefIndex: Int {
        didSet {
            UserDefaults.standard.setValue(selectedClefIndex, forKey: "selectedClefIndex")
        }
    }
    
    @Published var selectedModeIndex: Int {
        didSet {
            UserDefaults.standard.setValue(selectedModeIndex, forKey: "selectedModeIndex")
        }
    }
    
    @Published var selectedKey: Key
    
    init() {
        self.noteNamesEnabled = UserDefaults.standard.bool(forKey: "noteNamesEnabled")
        self.isMajor = UserDefaults.standard.bool(forKey: "isMajor")
        self.numSharps = UserDefaults.standard.integer(forKey: "numSharps")
        self.numFlats = UserDefaults.standard.integer(forKey: "numFlats")
        if let clefTypeRawValue = UserDefaults.standard.string(forKey: "clefType"), let clefType = ClefType(rawValue: clefTypeRawValue) {
                self.clefType = clefType
        } else {
            self.clefType = .treble // Default to treble clef if not set
        }
        self.selectedKeyIndex = UserDefaults.standard.integer(forKey: "selectedKeyIndex")
        self.selectedClefIndex = UserDefaults.standard.integer(forKey: "selectedClefIndex")
        self.selectedModeIndex = UserDefaults.standard.integer(forKey: "selectedModeIndex")
        
        self.selectedKey = KeyGenerator().data
        
        // if there is data for a saved key, load that into the selected key variable
        if let data = UserDefaults.standard.data(forKey: "key") {
            do {
                let decoder = JSONDecoder()
                self.selectedKey = try decoder.decode(Key.self, from: data)
            } catch {
                print("Error decoding key: \(error)")
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var userSettings: UserSettings
//    @State var device: Device
    
    let keysMajor = ["C", "G", "D", "A", "E", "B", "F#", "C#", "Gb", "Db", "Ab", "Eb", "Bb", "F"]
    let keysMinor = ["Am", "Em", "Bm", "F#m", "C#m", "Abm", "D#m", "A#m", "Ebm", "Bbm", "Fm", "Cm", "Gb", "Dm"]
    var clefTypes: [ClefType] = [.treble, .octave, .bass]
    
    let modeType = ["Major", "Minor"]
    
    var keySignatures: [String] {
        switch userSettings.clefType {
        case .treble:
            return ["C_treble", "G_treble", "D_treble", "A_treble", "E_treble", "B_treble", "F_sharp_treble", "C_sharp_treble", "G_flat_treble", "D_flat_treble", "A_flat_treble", "E_flat_treble", "B_flat_treble", "F_treble"]
        case .bass:
            return ["C_bass", "G_bass", "D_bass", "A_bass", "E_bass", "B_bass", "F_sharp_bass", "C_sharp_bass", "G_flat_bass", "D_flat_bass", "A_flat_bass", "E_flat_bass", "B_flat_bass", "F_bass"]
        case .octave:
            return ["C_tenor", "G_tenor", "D_tenor", "A_tenor", "E_tenor", "B_tenor", "F_sharp_tenor", "C_sharp_tenor", "G_flat_tenor", "D_flat_tenor", "A_flat_tenor", "E_flat_tenor", "B_flat_tenor", "F_tenor"]
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Musical Key")) {
                    
                    // picker for selecting clef
                    Picker(selection: $userSettings.selectedClefIndex, label: Text("Clef")) {
                        ForEach(0 ..< clefTypes.count, id: \.self) { index in
                            Text(clefTypes[index].rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: userSettings.selectedClefIndex) {
                        userSettings.clefType = clefTypes[userSettings.selectedClefIndex]
                    }
                    
                    // picker for selecting mode
                    Picker(selection: $userSettings.selectedModeIndex, label: Text("Mode")) {
                        ForEach(modeType.indices, id: \.self) { i in
                            Text(modeType[i])
                        }
                    }
                    .padding()
                    .onChange(of: userSettings.selectedModeIndex) {
                        userSettings.isMajor = (userSettings.selectedModeIndex == 0) ? true : false
                    }
                    
                    // hstack displays picker for selecting key and key signature photo
                    HStack {
                        
                        // displays the image of the current key
                        Image(keySignatures[userSettings.selectedKeyIndex])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300)
                            .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                        
                        Spacer() // spacer used to center picker for the key
                        
                        // picker for selecting the key
                        Picker(selection: $userSettings.selectedKeyIndex, label: Text("Key")) {
                            ForEach(0 ..< (userSettings.isMajor ? keysMajor.count : keysMinor.count), id: \.self) { index in
                                Text(userSettings.isMajor ? keysMajor[index] : keysMinor[index])
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .onChange(of: userSettings.selectedKeyIndex) {
                            updateSharpsFlats()
                            saveKey()
                        }
                        
                        Spacer() // spacer used to center picker for the key
                    }
                }
                
                Section(header: Text("Graph")) {
                    
                    // toggle for settings note names
                    Toggle(isOn: $userSettings.noteNamesEnabled) {
                        Text("Show Note Names")
                    }
                }
                
                // picker for the input device
//                Section(header: Text("Input Device")) {
//                    Picker("Input:", selection: $device) {
//                        ForEach(getDevices(), id: \.self) {
//                            Text($0.deviceID)
//                        }
//                    }
//                    .pickerStyle(MenuPickerStyle())
//                    .onChange(of: device) {
//                        setInputDevice(to: device)
//                    }
//                }
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
        
        let sharpsFlats = userSettings.isMajor ? sharpsFlatsMajor : sharpsFlatsMinor
        let selectedKey = userSettings.isMajor ? keysMajor[userSettings.selectedKeyIndex] : keysMinor[userSettings.selectedKeyIndex]
        let (sharps, flats) = sharpsFlats[selectedKey]!
        userSettings.numSharps = sharps
        userSettings.numFlats = flats
    }
    
    // saves the key into the settings
    func saveKey() {
        // generate the key based off the number of sharps or flats
        var keyGenerator = KeyGenerator()
        if userSettings.numSharps > 0 {
            keyGenerator = KeyGenerator(numSharps: userSettings.numSharps, isMajor: userSettings.isMajor)
        } else if userSettings.numFlats > 0 {
            keyGenerator = KeyGenerator(numFlats: userSettings.numFlats, isMajor: userSettings.isMajor)
        }
        
        // update the user settings with the selected key
        userSettings.selectedKey = keyGenerator.data
        
        // save the settings so that when the app is closed and then opened the saved key can be loaded
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(userSettings.selectedKey)
            UserDefaults.standard.set(data, forKey: "key")
        } catch {
            print("Error with saving key: \(error)")
        }
    }
    
//    func getDevices() -> [Device] {
//        AudioEngine.inputDevices.compactMap { $0 }
//    }
//    
//    func setInputDevice(to device: Device) {
//        do {
//            try AudioEngine.setInputDevice(device)
//        } catch let err {
//            print(err)
//        }
//    }
    
}



#Preview {
    SettingsView(userSettings: UserSettings())
}
